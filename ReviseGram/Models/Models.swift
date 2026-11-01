import Foundation

struct SubjectInfo: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let code: String
    let syllabusVersion: String
    let shortName: String
    let qualificationRouteNote: String?

    init(
        id: String,
        name: String,
        code: String,
        syllabusVersion: String,
        shortName: String? = nil,
        qualificationRouteNote: String? = nil
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.syllabusVersion = syllabusVersion
        self.shortName = shortName ?? name
        self.qualificationRouteNote = qualificationRouteNote
    }
}

enum SubjectCatalogue {
    static let subjects: [SubjectInfo] = [
        SubjectInfo(
            id: "physics",
            name: "Physics",
            code: "0625",
            syllabusVersion: "2026–2028",
            shortName: "Physics"
        ),
        SubjectInfo(
            id: "mathematics",
            name: "Mathematics",
            code: "0580",
            syllabusVersion: "2025–2027",
            shortName: "Mathematics"
        ),
        SubjectInfo(
            id: "chemistry",
            name: "Chemistry",
            code: "0620",
            syllabusVersion: "2026–2028",
            shortName: "Chemistry"
        ),
        SubjectInfo(
            id: "business",
            name: "Business",
            code: "0264",
            syllabusVersion: "2027–2029",
            shortName: "Business",
            qualificationRouteNote: "Standard Cambridge IGCSE Business (0264) 2027–2029 examination route (distinct from the 9–1 school-specific route 0774)."
        ),
        SubjectInfo(
            id: "economics",
            name: "Economics",
            code: "0455",
            syllabusVersion: "2027–2029",
            shortName: "Economics"
        ),
        SubjectInfo(
            id: "ict",
            name: "Information and Communication Technology (ICT)",
            code: "0417",
            syllabusVersion: "2026–2028",
            shortName: "ICT"
        ),
        SubjectInfo(
            id: "english_first_language",
            name: "English – First Language",
            code: "0500",
            syllabusVersion: "2027–2029",
            shortName: "English – First Language"
        )
    ]

    static var defaultSubjectIds: [String] {
        subjects.map(\.id)
    }

    static func normalizeSubjectId(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch trimmed {
        case "maths", "math", "0580":
            return "mathematics"
        case "0625":
            return "physics"
        case "0620":
            return "chemistry"
        case "0264", "0450", "business_studies", "business studies":
            return "business"
        case "0455":
            return "economics"
        case "0417", "information and communication technology (ict)", "information and communication technology":
            return "ict"
        case "0500", "english", "english first language", "english - first language", "english – first language":
            return "english_first_language"
        default:
            return trimmed
        }
    }

    static func getSubject(by idOrCode: String) -> SubjectInfo? {
        let normalized = normalizeSubjectId(idOrCode)
        return subjects.first {
            $0.id.caseInsensitiveCompare(normalized) == .orderedSame ||
            $0.code.caseInsensitiveCompare(idOrCode) == .orderedSame ||
            $0.name.caseInsensitiveCompare(idOrCode) == .orderedSame ||
            $0.shortName.caseInsensitiveCompare(idOrCode) == .orderedSame
        }
    }
}

struct UserStats: Codable, Equatable {
    var streakDays: Int = 0
    var lastStudyTimestamp: TimeInterval = 0
    var revisePoints: Int = 0
    var totalQuizzesAnswered: Int = 0
    var correctQuizzesCount: Int = 0
    var storiesCompletedCount: Int = 0
    var userLevel: Int = 1
    var userTitle: String = "IGCSE Candidate"
    var selectedAvatar: String = "IG"
    var streakShieldsActive: Int = 1
}

struct PostItem: Identifiable, Codable, Equatable {
    var id: Int64
    var subjectId: String
    var subjectName: String
    var subjectCode: String
    var topicId: String
    var authorHandle: String
    var authorAvatar: String
    var topicTitle: String
    var chapterName: String
    var mainContent: String
    var formulaOrKeyPoint: String?
    var quizQuestion: String?
    var quizOptions: [String]
    var quizCorrectIndex: Int
    var quizExplanation: String?
    var userSelectedAnswerIndex: Int = -1
    var likesCount: Int = 0
    var commentsCount: Int = 0
    var isLiked: Bool = false
    var isSaved: Bool = false
    var timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
    var postType: String = "POST" // POST, QUIZ, FORMULA, EXAM_TIP, AI_NOTE
    var difficulty: String = "Extended"

    var hasValidQuiz: Bool {
        guard let q = quizQuestion?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty else {
            return false
        }
        let nonBlank = quizOptions.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return nonBlank.count >= 2 && quizOptions.indices.contains(quizCorrectIndex)
    }
}

struct PostComment: Identifiable, Codable, Equatable {
    var id: Int64
    var postId: Int64
    var userName: String
    var userAvatar: String
    var commentText: String
    var timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
}

struct StorySlide: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var subtitle: String
    var content: String
    var formulaOrTip: String?
    var quizQuestion: String?
    var quizOptions: [String]?
    var quizCorrectIndex: Int = -1
    var explanation: String?

    var hasValidQuiz: Bool {
        guard let q = quizQuestion?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty,
              let opts = quizOptions, opts.count >= 2 else {
            return false
        }
        return opts.indices.contains(quizCorrectIndex)
    }
}

struct StoryItem: Identifiable, Codable, Equatable {
    var id: String { subjectId }
    var subjectId: String
    var subjectName: String
    var subjectCode: String
    var iconEmoji: String
    var primaryColorHex: String
    var slides: [StorySlide]
    var isViewed: Bool = false
}

struct FlashcardItem: Identifiable, Codable, Equatable {
    var id: Int64
    var subjectId: String
    var subjectCode: String
    var subjectName: String
    var topicId: String = ""
    var topic: String
    var difficulty: String = "Core"
    var front: String
    var back: String
    var repetitionCount: Int = 0
    var intervalDays: Int = 1
    var nextReviewTimestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
    var easeFactor: Double = 2.5
    var consecutiveCorrect: Int = 0
    var isMastered: Bool = false
}

struct PastPaperAttempt: Identifiable, Codable, Equatable {
    var id: Int64
    var subjectId: String
    var subjectCode: String
    var subjectName: String
    var topicId: String = ""
    var year: Int
    var session: String
    var paperCode: String
    var questionNumber: String
    var scoreObtained: Int
    var maxScore: Int
    var topic: String
    var mistakesNotes: String = ""
    var timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
}

struct QuizAttempt: Identifiable, Codable, Equatable {
    var id: Int64
    var postId: Int64
    var subjectId: String
    var subjectCode: String
    var topicId: String
    var topic: String
    var subtopic: String?
    var isCorrect: Bool
    var timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
}

struct CollectionFolder: Identifiable, Codable, Equatable {
    var id: Int64
    var name: String
    var iconEmoji: String = "📁"
    var description: String = "Curated revision materials"
    var postIds: [Int64] = []
}

struct RewardItem: Identifiable, Codable, Equatable {
    var id: String { itemId }
    var itemId: String
    var title: String
    var description: String
    var pointCost: Int
    var iconEmoji: String
    var itemType: String // AVATAR, BADGE, SHIELD
    var isUnlocked: Bool = false
    var isEquipped: Bool = false
}

struct DailyMission: Identifiable, Codable, Equatable {
    var id: Int64
    var title: String
    var description: String
    var subjectId: String?
    var topicId: String = ""
    var topic: String?
    var rewardPoints: Int = 25
    var targetCount: Int = 1
    var currentCount: Int = 0
    var isCompleted: Bool = false
    var isClaimed: Bool = false
    var missionType: String // QUIZ, FLASHCARD, TUTOR, PAST_PAPER
}

struct ChatMessage: Identifiable, Codable, Equatable {
    var id: Int64
    var subjectId: String
    var senderName: String
    var messageText: String
    var isFromUser: Bool
    var timestamp: TimeInterval = Date().timeIntervalSince1970 * 1000
}

struct GeneratedAiContent: Equatable {
    let title: String
    let content: String
    let formulaOrKeyPoint: String
    let quizQuestion: String?
    let quizOptions: [String]?
    let quizCorrectIndex: Int
    let quizExplanation: String?
    let flashcardFront: String?
    let flashcardBack: String?
}

struct AiMarkingResult: Equatable {
    let score: Int
    let maxScore: Int
    let correctPoints: [String]
    let missingPoints: [String]
    let incorrectPoints: [String]
    let improvementTips: String
    let modelAnswer: String
    let isSuccess: Bool
}

struct AiProgressAnalysis: Equatable {
    let summary: String
    let strengths: [String]
    let weaknesses: [String]
    let commonMistakes: [String]
    let priorityActionPlan: [String]
}

struct ExamResultData: Equatable {
    let subjectId: String
    let subjectName: String
    let subjectCode: String
    let totalScore: Int
    let maxScore: Int
    let percentage: Int
    let grade: String
    let weakTopics: [String]
    let recommendations: [String]
}

enum NavTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case explore = "Explore"
    case create = "Create"
    case progress = "Progress"
    case profile = "Profile"

    var id: String { rawValue }

    var systemIcon: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "magnifyingglass"
        case .create: return "plus.square.fill"
        case .progress: return "chart.bar.xaxis"
        case .profile: return "person.crop.circle"
        }
    }
}
