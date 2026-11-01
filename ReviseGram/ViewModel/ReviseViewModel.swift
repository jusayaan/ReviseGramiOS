import Foundation
import SwiftUI

structPersistedStore: Codable {
    var userStats: UserStats
    var posts: [PostItem]
    var comments: [PostComment]
    var stories: [StoryItem]
    var flashcards: [FlashcardItem]
    var pastPaperAttempts: [PastPaperAttempt]
    var quizAttempts: [QuizAttempt]
    var collections: [CollectionFolder]
    var rewards: [RewardItem]
    var dailyMissions: [DailyMission]
    var chatMessages: [ChatMessage]
}

@MainActor
final class ReviseViewModel: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var isDarkTheme: Bool {
        didSet { UserDefaults.standard.set(isDarkTheme, forKey: "revisegram_dark_theme") }
    }
    @Published var customApiKey: String {
        didSet { UserDefaults.standard.set(customApiKey, forKey: "revisegram_gemini_api_key") }
    }
    @Published var selectedSubjectIds: [String]
    @Published var selectedTab: NavTab = .home
    @Published var selectedSubjectFilter: String = "ALL"
    @Published var searchQuery: String = ""

    // Persisted Entities
    @Published var userStats: UserStats
    @Published var posts: [PostItem]
    @Published var comments: [PostComment]
    @Published var stories: [StoryItem]
    @Published var flashcards: [FlashcardItem]
    @Published var pastPaperAttempts: [PastPaperAttempt]
    @Published var quizAttempts: [QuizAttempt]
    @Published var collections: [CollectionFolder]
    @Published var rewards: [RewardItem]
    @Published var dailyMissions: [DailyMission]
    @Published var chatMessages: [ChatMessage]

    // Active Overlays & Sheets
    @Published var activeStory: StoryItem?
    @Published var activeStorySlideIndex: Int = 0
    @Published var activeCommentsPost: PostItem?
    @Published var showFlashcardsSheet: Bool = false
    @Published var showPastPapersSheet: Bool = false
    @Published var showExamModeSheet: Bool = false
    @Published var showAiTutorSheet: Bool = false
    @Published var showAiGeneratorSheet: Bool = false
    @Published var showAiMarkingSheet: Bool = false
    @Published var showSettingsSheet: Bool = false

    // Flashcards State
    @Published var selectedFlashcardSubject: String = "ALL"
    @Published var currentFlashcardIndex: Int = 0
    @Published var isFlashcardFlipped: Bool = false

    // Exam Mode State
    @Published var isExamRunning: Bool = false
    @Published var examTimeRemaining: Int = 0
    @Published var examQuestions: [PostItem] = []
    @Published var examCurrentIndex: Int = 0
    @Published var examUserAnswers: [Int: Int] = [:]
    @Published var examResult: ExamResultData?
    private var examTimerTask: Task<Void, Never>?

    // AI Tutor & Tools State
    @Published var selectedChatSubjectId: String = "physics"
    @Published var isSendingMessage: Bool = false
    @Published var isGeneratingAi: Bool = false
    @Published var aiGeneratedContent: GeneratedAiContent?
    @Published var isMarkingAnswer: Bool = false
    @Published var markingResult: AiMarkingResult?

    // Banner / Toast Feedback
    @Published var feedbackMessage: String?

    private let storeURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("ReviseGramStore_v1.json")
    }()

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "revisegram_onboarding_completed")
        self.isDarkTheme = UserDefaults.standard.bool(forKey: "revisegram_dark_theme")
        self.customApiKey = UserDefaults.standard.string(forKey: "revisegram_gemini_api_key") ?? ""
        let savedSubjects = UserDefaults.standard.stringArray(forKey: "revisegram_selected_subjects") ?? []
        self.selectedSubjectIds = savedSubjects.isEmpty ? SubjectCatalogue.defaultSubjectIds : savedSubjects

        if let data = try? Data(contentsOf: storeURL),
           let decoded = try? JSONDecoder().decode(structPersistedStore.self, from: data) {
            self.userStats = decoded.userStats
            self.posts = decoded.posts
            self.comments = decoded.comments
            self.stories = decoded.stories
            self.flashcards = decoded.flashcards
            self.pastPaperAttempts = decoded.pastPaperAttempts
            self.quizAttempts = decoded.quizAttempts
            self.collections = decoded.collections
            self.rewards = decoded.rewards
            self.dailyMissions = decoded.dailyMissions
            self.chatMessages = decoded.chatMessages
        } else {
            self.userStats = InitialData.initialUserStats()
            self.posts = InitialData.initialPosts()
            self.comments = InitialData.initialComments()
            self.stories = InitialData.initialStories()
            self.flashcards = InitialData.initialFlashcards()
            self.pastPaperAttempts = []
            self.quizAttempts = []
            self.collections = InitialData.initialCollections()
            self.rewards = InitialData.initialRewards()
            self.dailyMissions = InitialData.initialDailyMissions()
            self.chatMessages = InitialData.initialChatMessages()
            persist()
        }
    }

    var selectedSubjects: [SubjectInfo] {
        let set = Set(selectedSubjectIds.map { SubjectCatalogue.normalizeSubjectId($0) })
        return SubjectCatalogue.subjects.filter { set.contains($0.id) }
    }

    var filteredPosts: [PostItem] {
        let activeSet = Set(selectedSubjectIds.map { SubjectCatalogue.normalizeSubjectId($0) })
        return posts.filter { post in
            let normSub = SubjectCatalogue.normalizeSubjectId(post.subjectId)
            guard activeSet.contains(normSub) else { return false }
            let matchesSubject = selectedSubjectFilter == "ALL" ||
                normSub == SubjectCatalogue.normalizeSubjectId(selectedSubjectFilter)
            let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesQuery = q.isEmpty ||
                post.topicTitle.localizedCaseInsensitiveContains(q) ||
                post.chapterName.localizedCaseInsensitiveContains(q) ||
                post.mainContent.localizedCaseInsensitiveContains(q) ||
                post.subjectName.localizedCaseInsensitiveContains(q) ||
                post.subjectCode.localizedCaseInsensitiveContains(q)
            return matchesSubject && matchesQuery
        }
    }

    var savedPosts: [PostItem] {
        posts.filter(\.isSaved)
    }

    func completeOnboarding(with subjectIds: [String]) {
        let valid = subjectIds.map { SubjectCatalogue.normalizeSubjectId($0) }
            .filter { id in SubjectCatalogue.subjects.contains(where: { $0.id == id }) }
        guard !valid.isEmpty else {
            showToast("Please select at least one IGCSE subject.")
            return
        }
        selectedSubjectIds = valid
        UserDefaults.standard.set(valid, forKey: "revisegram_selected_subjects")
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "revisegram_onboarding_completed")
    }

    func showToast(_ message: String) {
        feedbackMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 2_800_000_000)
            if feedbackMessage == message {
                feedbackMessage = nil
            }
        }
    }

    private func recordStudyStreakAndPoints(points: Int) {
        let now = Date().timeIntervalSince1970 * 1000
        if userStats.lastStudyTimestamp <= 0 {
            userStats.streakDays = max(1, userStats.streakDays + 1)
            userStats.revisePoints += points + 25
        } else {
            let lastDate = Date(timeIntervalSince1970: userStats.lastStudyTimestamp / 1000)
            let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: lastDate), to: Calendar.current.startOfDay(for: Date())).day ?? 0
            if days == 1 {
                userStats.streakDays += 1
                userStats.revisePoints += points + 25
            } else if days >= 2 {
                if userStats.streakShieldsActive > 0 {
                    userStats.streakShieldsActive -= 1
                    userStats.streakDays += 1
                } else {
                    userStats.streakDays = 1
                }
                userStats.revisePoints += points + 10
            } else {
                userStats.revisePoints += points
            }
        }
        userStats.lastStudyTimestamp = now
        userStats.userLevel = (userStats.revisePoints / 200) + 1
    }

    func toggleLike(_ post: PostItem) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx].isLiked.toggle()
        posts[idx].likesCount = max(0, posts[idx].likesCount + (posts[idx].isLiked ? 1 : -1))
        persist()
    }

    func toggleSave(_ post: PostItem) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[idx].isSaved.toggle()
        showToast(posts[idx].isSaved ? "Saved to Bookmarks" : "Removed from Bookmarks")
        persist()
    }

    func submitQuizAnswer(post: PostItem, optionIndex: Int) {
        guard let idx = posts.firstIndex(where: { $0.id == post.id }) else { return }
        guard posts[idx].userSelectedAnswerIndex == -1, posts[idx].hasValidQuiz else { return }
        guard posts[idx].quizOptions.indices.contains(optionIndex) else { return }

        posts[idx].userSelectedAnswerIndex = optionIndex
        let isCorrect = (optionIndex == posts[idx].quizCorrectIndex)

        let attempt = QuizAttempt(
            id: Int64(Date().timeIntervalSince1970 * 1000),
            postId: post.id,
            subjectId: post.subjectId,
            subjectCode: post.subjectCode,
            topicId: post.topicId,
            topic: post.chapterName,
            subtopic: post.topicTitle,
            isCorrect: isCorrect
        )
        quizAttempts.insert(attempt, at: 0)
        userStats.totalQuizzesAnswered += 1
        if isCorrect { userStats.correctQuizzesCount += 1 }
        recordStudyStreakAndPoints(points: isCorrect ? 15 : 5)
        incrementMission(type: "QUIZ")
        showToast(isCorrect ? "Correct Answer! +15 RevisePoints" : "Recorded attempt! +5 RevisePoints")
        persist()
    }

    func addComment(postId: Int64, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newId = (comments.map(\.id).max() ?? 0) + 1
        comments.append(
            PostComment(
                id: newId,
                postId: postId,
                userName: "Student · \(userStats.selectedAvatar)",
                userAvatar: userStats.selectedAvatar,
                commentText: trimmed
            )
        )
        if let idx = posts.firstIndex(where: { $0.id == postId }) {
            posts[idx].commentsCount += 1
        }
        recordStudyStreakAndPoints(points: 5)
        showToast("Study note added! +5 RevisePoints")
        persist()
    }

    func createPost(
        subject: SubjectInfo,
        topicTitle: String,
        chapterName: String,
        mainContent: String,
        formulaOrKeyPoint: String?,
        quizQuestion: String?,
        quizOptions: [String],
        quizCorrectIndex: Int,
        quizExplanation: String?,
        postType: String,
        difficulty: String
    ) {
        let cleanTitle = topicTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanBody = mainContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty && !cleanBody.isEmpty else {
            showToast("Please enter a topic title and content.")
            return
        }
        let validOptions = quizOptions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let hasValidQuiz = !(quizQuestion?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) && validOptions.count >= 2
        let newId = (posts.map(\.id).max() ?? 0) + 1

        let post = PostItem(
            id: newId,
            subjectId: subject.id,
            subjectName: subject.name,
            subjectCode: subject.code,
            topicId: "\(subject.id)_custom",
            authorHandle: "Student · \(userStats.selectedAvatar)",
            authorAvatar: subject.code,
            topicTitle: cleanTitle,
            chapterName: chapterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "General \(subject.shortName)" : chapterName,
            mainContent: cleanBody,
            formulaOrKeyPoint: formulaOrKeyPoint?.trimmingCharacters(in: .whitespacesAndNewlines),
            quizQuestion: hasValidQuiz ? quizQuestion : nil,
            quizOptions: hasValidQuiz ? validOptions : [],
            quizCorrectIndex: hasValidQuiz ? min(max(0, quizCorrectIndex), validOptions.count - 1) : -1,
            quizExplanation: hasValidQuiz ? quizExplanation : nil,
            postType: postType,
            difficulty: difficulty
        )
        posts.insert(post, at: 0)
        recordStudyStreakAndPoints(points: 20)
        selectedTab = .home
        showToast("Published \(postType)! +20 RevisePoints")
        persist()
    }

    func reviewFlashcard(_ card: FlashcardItem, gotIt: Bool) {
        guard let idx = flashcards.firstIndex(where: { $0.id == card.id }) else { return }
        var updated = flashcards[idx]
        updated.repetitionCount += 1
        if gotIt {
            updated.consecutiveCorrect += 1
            updated.intervalDays = updated.consecutiveCorrect == 1 ? 1 : (updated.consecutiveCorrect == 2 ? 3 : max(6, Int(Double(updated.intervalDays) * updated.easeFactor)))
            updated.easeFactor = min(3.0, updated.easeFactor + 0.1)
            updated.isMastered = updated.consecutiveCorrect >= 4
        } else {
            updated.consecutiveCorrect = 0
            updated.intervalDays = 1
            updated.easeFactor = max(1.3, updated.easeFactor - 0.2)
            updated.isMastered = false
        }
        flashcards[idx] = updated
        isFlashcardFlipped = false

        let deck = activeFlashcards
        if !deck.isEmpty {
            currentFlashcardIndex = (currentFlashcardIndex + 1) % deck.count
        }
        recordStudyStreakAndPoints(points: gotIt ? 8 : 3)
        incrementMission(type: "FLASHCARD")
        showToast(gotIt ? "Card recalled! +8 RevisePoints" : "Scheduled for review soon")
        persist()
    }

    var activeFlashcards: [FlashcardItem] {
        if selectedFlashcardSubject == "ALL" { return flashcards }
        let norm = SubjectCatalogue.normalizeSubjectId(selectedFlashcardSubject)
        return flashcards.filter { SubjectCatalogue.normalizeSubjectId($0.subjectId) == norm }
    }

    func createFlashcard(subject: SubjectInfo, topic: String, difficulty: String, front: String, back: String) {
        let newId = (flashcards.map(\.id).max() ?? 0) + 1
        let item = FlashcardItem(
            id: newId,
            subjectId: subject.id,
            subjectCode: subject.code,
            subjectName: subject.name,
            topicId: "\(subject.id)_cards",
            topic: topic.isEmpty ? "General \(subject.shortName)" : topic,
            difficulty: difficulty,
            front: front,
            back: back
        )
        flashcards.append(item)
        recordStudyStreakAndPoints(points: 15)
        showToast("Flashcard saved! +15 RevisePoints")
        persist()
    }

    func recordPastPaper(
        subject: SubjectInfo,
        year: Int,
        session: String,
        paperCode: String,
        questionNumber: String,
        scoreObtained: Int,
        maxScore: Int,
        topic: String,
        mistakesNotes: String
    ) {
        let safeMax = max(1, maxScore)
        let safeScore = min(max(0, scoreObtained), safeMax)
        let newId = (pastPaperAttempts.map(\.id).max() ?? 0) + 1
        let attempt = PastPaperAttempt(
            id: newId,
            subjectId: subject.id,
            subjectCode: subject.code,
            subjectName: subject.name,
            year: year,
            session: session,
            paperCode: paperCode,
            questionNumber: questionNumber.isEmpty ? "Q1" : questionNumber,
            scoreObtained: safeScore,
            maxScore: safeMax,
            topic: topic.isEmpty ? subject.shortName : topic,
            mistakesNotes: mistakesNotes
        )
        pastPaperAttempts.insert(attempt, at: 0)
        recordStudyStreakAndPoints(points: 25)
        incrementMission(type: "PAST_PAPER")
        showToast("Past paper logged! +25 RevisePoints")
        persist()
    }

    // MARK: - Exam Mode (Validated Quiz Questions Only)
    func startExam(subjectId: String, difficulty: String, durationMinutes: Int) {
        examTimerTask?.cancel()
        let normSubject = SubjectCatalogue.normalizeSubjectId(subjectId)
        let validForSubject = posts.filter { post in
            let matchesSub = subjectId == "ALL" || SubjectCatalogue.normalizeSubjectId(post.subjectId) == normSubject
            return matchesSub && post.hasValidQuiz
        }

        guard !validForSubject.isEmpty else {
            isExamRunning = false
            examQuestions = []
            examResult = nil
            showToast("No valid quiz questions found for this subject. Create or generate a quiz first!")
            return
        }

        let exactDiff = validForSubject.filter { $0.difficulty.caseInsensitiveCompare(difficulty) == .orderedSame }.shuffled()
        let fallbackDiff = validForSubject.filter { $0.difficulty.caseInsensitiveCompare(difficulty) != .orderedSame }.shuffled()

        examQuestions = Array((exactDiff + fallbackDiff).prefix(6))
        examCurrentIndex = 0
        examUserAnswers = [:]
        examResult = nil
        examTimeRemaining = max(1, durationMinutes) * 60
        isExamRunning = true
        showExamModeSheet = true

        examTimerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled && self.isExamRunning && self.examTimeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled && self.isExamRunning && self.examTimeRemaining > 0 {
                    self.examTimeRemaining -= 1
                }
            }
            if !Task.isCancelled && self.isExamRunning && !self.examQuestions.isEmpty {
                self.finishExam()
            }
        }
    }

    func finishExam() {
        examTimerTask?.cancel()
        isExamRunning = false
        guard !examQuestions.isEmpty else { return }

        var correct = 0
        var weak: [String] = []
        for (idx, q) in examQuestions.enumerated() {
            let ans = examUserAnswers[idx] ?? -1
            if ans == q.quizCorrectIndex {
                correct += 1
            } else {
                weak.append(q.topicTitle)
            }
        }

        let total = examQuestions.count
        let pct = Int((Double(correct) / Double(max(1, total))) * 100.0)
        let grade: String
        switch pct {
        case 90...100: grade = "A*"
        case 80..<90: grade = "A"
        case 70..<80: grade = "B"
        case 60..<70: grade = "C"
        case 50..<60: grade = "D"
        default: grade = "U"
        }

        let first = examQuestions[0]
        examResult = ExamResultData(
            subjectId: first.subjectId,
            subjectName: first.subjectName,
            subjectCode: first.subjectCode,
            totalScore: correct,
            maxScore: total,
            percentage: pct,
            grade: grade,
            weakTopics: Array(Set(weak)),
            recommendations: weak.isEmpty
                ? ["Strong performance! Log timed Paper 2 and Paper 4 past papers next."]
                : ["Review flashcards on: \(weak.joined(separator: ", "))"]
        )
        recordStudyStreakAndPoints(points: 50)
        showToast("Exam Completed: Grade \(grade) (\(pct)%) · +50 RevisePoints")
        persist()
    }

    // MARK: - AI Tutor & Marking
    func sendChatMessage(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSendingMessage else { return }
        let subject = SubjectCatalogue.getSubject(by: selectedChatSubjectId) ?? SubjectCatalogue.subjects[0]
        let nextId = (chatMessages.map(\.id).max() ?? 0) + 1
        chatMessages.append(
            ChatMessage(id: nextId, subjectId: subject.id, senderName: "You", messageText: trimmed, isFromUser: true)
        )
        isSendingMessage = true
        persist()

        let history = chatMessages
            .filter { SubjectCatalogue.normalizeSubjectId($0.subjectId) == subject.id }
            .map { ($0.messageText, $0.isFromUser) }
        let contextStr = "Quizzes answered: \(userStats.totalQuizzesAnswered), Streak: \(userStats.streakDays)d"
        let apiKeySnapshot = customApiKey

        Task {
            defer { isSendingMessage = false }
            do {
                let reply = try await GeminiService.askSubjectTutor(
                    subjectName: subject.name,
                    subjectCode: subject.code,
                    userQuestion: trimmed,
                    chatHistory: history,
                    apiKey: apiKeySnapshot,
                    userContext: contextStr
                )
                let replyId = (chatMessages.map(\.id).max() ?? 0) + 1
                chatMessages.append(
                    ChatMessage(
                        id: replyId,
                        subjectId: subject.id,
                        senderName: "\(subject.shortName) Tutor · \(subject.code)",
                        messageText: reply,
                        isFromUser: false
                    )
                )
                recordStudyStreakAndPoints(points: 5)
                incrementMission(type: "TUTOR")
                persist()
            } catch is CancellationError {
                return
            } catch {
                showToast("Could not reach AI Tutor. Please try again.")
            }
        }
    }

    func generateAiSyllabusItem(subject: SubjectInfo, topic: String, contentType: String, difficulty: String) {
        guard !isGeneratingAi else { return }
        isGeneratingAi = true
        let apiKeySnapshot = customApiKey
        Task {
            defer { isGeneratingAi = false }
            do {
                let generated = try await GeminiService.generateSyllabusContent(
                    subjectName: subject.name,
                    subjectCode: subject.code,
                    topic: topic.isEmpty ? subject.shortName : topic,
                    contentType: contentType,
                    difficulty: difficulty,
                    apiKey: apiKeySnapshot
                )
                aiGeneratedContent = generated
                showToast("Generated \(contentType)!")
            } catch is CancellationError {
                return
            } catch {
                showToast("Could not generate syllabus content.")
            }
        }
    }

    func markAnswerWithAi(subject: SubjectInfo, topic: String, questionText: String, studentAnswer: String) {
        guard !isMarkingAnswer, !studentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isMarkingAnswer = true
        let apiKeySnapshot = customApiKey
        Task {
            defer { isMarkingAnswer = false }
            do {
                let result = try await GeminiService.markStudentAnswer(
                    subjectName: subject.name,
                    subjectCode: subject.code,
                    topic: topic,
                    questionText: questionText,
                    studentAnswer: studentAnswer,
                    maxScore: 4,
                    apiKey: apiKeySnapshot
                )
                markingResult = result
                if result.isSuccess {
                    recordStudyStreakAndPoints(points: 20)
                    incrementMission(type: "TUTOR")
                    persist()
                    showToast("Marked: \(result.score)/\(result.maxScore)")
                } else {
                    showToast(result.improvementTips)
                }
            } catch is CancellationError {
                return
            } catch {
                showToast("Unable to mark answer right now.")
            }
        }
    }

    func claimMission(_ mission: DailyMission) {
        guard let idx = dailyMissions.firstIndex(where: { $0.id == mission.id }) else { return }
        guard dailyMissions[idx].isCompleted && !dailyMissions[idx].isClaimed else { return }
        dailyMissions[idx].isClaimed = true
        recordStudyStreakAndPoints(points: dailyMissions[idx].rewardPoints)
        showToast("Claimed +\(dailyMissions[idx].rewardPoints) RevisePoints!")
        persist()
    }

    private func incrementMission(type: String) {
        for idx in dailyMissions.indices {
            if !dailyMissions[idx].isCompleted && dailyMissions[idx].missionType == type {
                dailyMissions[idx].currentCount += 1
                if dailyMissions[idx].currentCount >= dailyMissions[idx].targetCount {
                    dailyMissions[idx].isCompleted = true
                }
            }
        }
    }

    func createCollection(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newId = (collections.map(\.id).max() ?? 0) + 1
        collections.insert(CollectionFolder(id: newId, name: trimmed), at: 0)
        showToast("Folder '\(trimmed)' created")
        persist()
    }

    func purchaseOrEquipReward(_ reward: RewardItem) {
        guard let idx = rewards.firstIndex(where: { $0.itemId == reward.itemId }) else { return }
        if rewards[idx].isUnlocked {
            for i in rewards.indices where rewards[i].itemType == reward.itemType {
                rewards[i].isEquipped = (rewards[i].itemId == reward.itemId)
            }
            if reward.itemType == "AVATAR" {
                userStats.selectedAvatar = reward.iconEmoji
            } else if reward.itemType == "BADGE" {
                userStats.userTitle = reward.title
            }
            showToast("Equipped \(reward.title)")
        } else if userStats.revisePoints >= reward.pointCost {
            userStats.revisePoints -= reward.pointCost
            rewards[idx].isUnlocked = true
            if reward.itemType == "SHIELD" {
                userStats.streakShieldsActive += 1
            }
            showToast("Unlocked \(reward.title)!")
        } else {
            showToast("Need \(reward.pointCost - userStats.revisePoints) more RevisePoints")
        }
        persist()
    }

    private func persist() {
        let snapshot = structPersistedStore(
            userStats: userStats,
            posts: posts,
            comments: comments,
            stories: stories,
            flashcards: flashcards,
            pastPaperAttempts: pastPaperAttempts,
            quizAttempts: quizAttempts,
            collections: collections,
            rewards: rewards,
            dailyMissions: dailyMissions,
            chatMessages: chatMessages
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            try? data.write(to: storeURL, options: .atomic)
        }
    }
}
