import SwiftUI

struct StoryViewerSheet: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    let story: StoryItem
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOption: Int = -1

    var body: some View {
        let slides = story.slides
        if slides.isEmpty {
            VStack {
                Text("No story slides available.")
                Button("Close") { dismiss() }
            }
        } else {
            let safeIndex = min(max(0, viewModel.activeStorySlideIndex), slides.count - 1)
            let slide = slides[safeIndex]

            NavigationStack {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 4) {
                        ForEach(slides.indices, id: \.self) { idx in
                            Capsule()
                                .fill(idx <= safeIndex ? DesignTokens.primaryBrand : Color.secondary.opacity(0.25))
                                .frame(height: 4)
                        }
                    }

                    Text("\(story.subjectName) (\(story.subjectCode)) · Slide \(safeIndex + 1) of \(slides.count)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(DesignTokens.primaryBrand)

                    Text(slide.title)
                        .font(.title2.weight(.bold))

                    Text(slide.subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)

                    Text(slide.content)
                        .font(.body)

                    if let tip = slide.formulaOrTip, !tip.isEmpty {
                        Text(tip)
                            .font(.system(.footnote, design: .monospaced))
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(DesignTokens.primaryBrand.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if slide.hasValidQuiz, let q = slide.quizQuestion, let opts = slide.quizOptions {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Quick Check: \(q)")
                                .font(.subheadline.weight(.semibold))
                            ForEach(Array(opts.enumerated()), id: \.offset) { idx, opt in
                                Button {
                                    selectedOption = idx
                                } label: {
                                    HStack {
                                        Text(opt)
                                            .font(.footnote)
                                        Spacer()
                                        if selectedOption != -1 {
                                            if idx == slide.quizCorrectIndex {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(DesignTokens.successGreen)
                                            } else if idx == selectedOption {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(DesignTokens.errorRed)
                                            }
                                        }
                                    }
                                    .padding(10)
                                    .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Spacer()

                    HStack {
                        if safeIndex > 0 {
                            Button("Previous") {
                                selectedOption = -1
                                viewModel.activeStorySlideIndex -= 1
                            }
                            .buttonStyle(.bordered)
                        }
                        Spacer()
                        Button(safeIndex + 1 < slides.count ? "Next Slide" : "Complete Story (+10 Pts)") {
                            selectedOption = -1
                            if safeIndex + 1 < slides.count {
                                viewModel.activeStorySlideIndex += 1
                            } else {
                                dismiss()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.primaryBrand)
                    }
                }
                .padding(20)
                .navigationTitle(story.subjectName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
            }
        }
    }
}

struct CommentsSheetView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    let post: PostItem
    @Environment(\.dismiss) private var dismiss
    @State private var commentText: String = ""

    var body: some View {
        let postComments = viewModel.comments.filter { $0.postId == post.id }
        NavigationStack {
            VStack {
                List(postComments) { c in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(c.userName)
                            .font(.caption.weight(.bold))
                        Text(c.commentText)
                            .font(.subheadline)
                    }
                }
                HStack {
                    TextField("Add a syllabus note or question...", text: $commentText)
                        .textFieldStyle(.roundedBorder)
                    Button("Post") {
                        viewModel.addComment(postId: post.id, text: commentText)
                        commentText = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DesignTokens.primaryBrand)
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .navigationTitle("Study Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FlashcardsDeckView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let cards = viewModel.activeFlashcards
        let safeIdx = cards.isEmpty ? 0 : min(max(0, viewModel.currentFlashcardIndex), cards.count - 1)
        let currentCard = cards.isEmpty ? nil : cards[safeIdx]

        NavigationStack {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        SubjectFilterPill(label: "All Decks", isSelected: viewModel.selectedFlashcardSubject == "ALL") {
                            viewModel.selectedFlashcardSubject = "ALL"
                            viewModel.currentFlashcardIndex = 0
                            viewModel.isFlashcardFlipped = false
                        }
                        ForEach(viewModel.selectedSubjects) { sub in
                            SubjectFilterPill(
                                label: "\(sub.shortName) (\(sub.code))",
                                isSelected: viewModel.selectedFlashcardSubject == sub.id
                            ) {
                                viewModel.selectedFlashcardSubject = sub.id
                                viewModel.currentFlashcardIndex = 0
                                viewModel.isFlashcardFlipped = false
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                if let card = currentCard {
                    Text("Card \(safeIdx + 1) of \(cards.count) · Interval: \(card.intervalDays)d")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.isFlashcardFlipped.toggle()
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("\(card.subjectName) (\(card.subjectCode))")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(DesignTokens.primaryBrand)
                                Spacer()
                                Text(viewModel.isFlashcardFlipped ? "ANSWER & MARK SCHEME" : "QUESTION PROMPT")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.secondary)
                            }
                            Text(card.topic)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(viewModel.isFlashcardFlipped ? card.back : card.front)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text("Tap card to flip")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, maxHeight: 340)
                        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 12) {
                        Button {
                            viewModel.reviewFlashcard(card, gotIt: false)
                        } label: {
                            Text("Need Review")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .tint(DesignTokens.errorRed)

                        Button {
                            viewModel.reviewFlashcard(card, gotIt: true)
                        } label: {
                            Text("Got It (+8 Pts)")
                                .font(.subheadline.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.successGreen)
                    }
                    .padding(.horizontal)
                } else {
                    Spacer()
                    Text("No flashcards in this subject deck.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.vertical)
            .navigationTitle("Flashcard Mastery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct ExamSimulatorView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubjectId: String = "physics"
    @State private var selectedDifficulty: String = "Extended"
    @State private var selectedDuration: Int = 10

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let result = viewModel.examResult {
                    VStack(spacing: 14) {
                        Text("Grade \(result.grade)")
                            .font(.largeTitle.weight(.heavy))
                            .foregroundColor(result.percentage >= 80 ? DesignTokens.successGreen : DesignTokens.primaryBrand)
                        Text("Score: \(result.totalScore) / \(result.maxScore) (\(result.percentage)%)")
                            .font(.headline)
                        ForEach(result.recommendations, id: \.self) { rec in
                            Text("• \(rec)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Button("Start Another Exam") {
                            viewModel.examResult = nil
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(DesignTokens.primaryBrand)
                    }
                    .padding()
                } else if viewModel.isExamRunning, !viewModel.examQuestions.isEmpty {
                    let qIdx = min(max(0, viewModel.examCurrentIndex), viewModel.examQuestions.count - 1)
                    let question = viewModel.examQuestions[qIdx]

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Question \(qIdx + 1) of \(viewModel.examQuestions.count)")
                                .font(.caption.weight(.bold))
                            Spacer()
                            Text(String(format: "⏱ %02d:%02d", viewModel.examTimeRemaining / 60, viewModel.examTimeRemaining % 60))
                                .font(.system(.caption, design: .monospaced).weight(.bold))
                                .foregroundColor(viewModel.examTimeRemaining < 60 ? DesignTokens.errorRed : DesignTokens.successGreen)
                        }

                        Text(question.quizQuestion ?? question.mainContent)
                            .font(.headline)

                        ForEach(Array(question.quizOptions.enumerated()), id: \.offset) { optIdx, optText in
                            let isSel = viewModel.examUserAnswers[qIdx] == optIdx
                            Button {
                                viewModel.examUserAnswers[qIdx] = optIdx
                            } label: {
                                HStack {
                                    Text("\(UnicodeScalar(65 + optIdx)!). \(optText)")
                                        .font(.subheadline)
                                    Spacer()
                                    if isSel {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(DesignTokens.primaryBrand)
                                    }
                                }
                                .padding(12)
                                .background(isSel ? DesignTokens.primaryBrand.opacity(0.14) : DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        HStack {
                            if qIdx > 0 {
                                Button("Previous") { viewModel.examCurrentIndex -= 1 }
                                    .buttonStyle(.bordered)
                            }
                            Spacer()
                            if qIdx + 1 < viewModel.examQuestions.count {
                                Button("Next") { viewModel.examCurrentIndex += 1 }
                                    .buttonStyle(.borderedProminent)
                            } else {
                                Button("Finish & Grade") { viewModel.finishExam() }
                                    .buttonStyle(.borderedProminent)
                                    .tint(DesignTokens.successGreen)
                            }
                        }
                    }
                    .padding()
                } else {
                    Form {
                        Section("1. Select Subject Syllabus") {
                            Picker("Subject", selection: $selectedSubjectId) {
                                Text("All Selected Subjects").tag("ALL")
                                ForEach(SubjectCatalogue.subjects) { sub in
                                    Text("\(sub.name) (\(sub.code))").tag(sub.id)
                                }
                            }
                        }
                        Section("2. Tier & Duration") {
                            Picker("Tier", selection: $selectedDifficulty) {
                                Text("Core").tag("Core")
                                Text("Extended").tag("Extended")
                            }
                            .pickerStyle(.segmented)

                            Picker("Duration", selection: $selectedDuration) {
                                Text("5 Mins").tag(5)
                                Text("10 Mins").tag(10)
                                Text("20 Mins").tag(20)
                            }
                            .pickerStyle(.segmented)
                        }
                        Section {
                            Button {
                                viewModel.startExam(subjectId: selectedSubjectId, difficulty: selectedDifficulty, durationMinutes: selectedDuration)
                            } label: {
                                Text("Begin Timed Exam Session")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .navigationTitle("IGCSE Exam Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        if viewModel.isExamRunning { viewModel.finishExam() }
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PastPapersTrackerView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubjectId: String = "physics"
    @State private var year: Int = 2025
    @State private var session: String = "May/June"
    @State private var paperCode: String = "Paper 4 (Theory Extended)"
    @State private var questionNumber: String = "Q1"
    @State private var scoreStr: String = "4"
    @State private var maxScoreStr: String = "6"
    @State private var topic: String = ""
    @State private var mistakesNotes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Log Past Paper Question") {
                    Picker("Subject", selection: $selectedSubjectId) {
                        ForEach(SubjectCatalogue.subjects) { sub in
                            Text("\(sub.name) (\(sub.code))").tag(sub.id)
                        }
                    }
                    Picker("Year", selection: $year) {
                        ForEach([2025, 2024, 2023, 2022, 2021], id: \.self) { yr in
                            Text("\(yr)").tag(yr)
                        }
                    }
                    Picker("Session", selection: $session) {
                        ForEach(["May/June", "Oct/Nov", "Feb/March"], id: \.self) { s in
                            Text(s).tag(s)
                        }
                    }
                    TextField("Paper Component", text: $paperCode)
                    TextField("Question (e.g. Q2(b))", text: $questionNumber)
                    HStack {
                        TextField("Score", text: $scoreStr)
                            .keyboardType(.numberPad)
                        Text("/")
                        TextField("Max", text: $maxScoreStr)
                            .keyboardType(.numberPad)
                    }
                    TextField("Syllabus Topic", text: $topic)
                    TextField("Examiner Mark-Scheme Mistake Note", text: $mistakesNotes)
                    Button("Save Question Log (+25 Pts)") {
                        let sub = SubjectCatalogue.getSubject(by: selectedSubjectId) ?? SubjectCatalogue.subjects[0]
                        viewModel.recordPastPaper(
                            subject: sub,
                            year: year,
                            session: session,
                            paperCode: paperCode,
                            questionNumber: questionNumber,
                            scoreObtained: Int(scoreStr) ?? 0,
                            maxScore: Int(maxScoreStr) ?? 1,
                            topic: topic,
                            mistakesNotes: mistakesNotes
                        )
                        topic = ""
                        mistakesNotes = ""
                    }
                }

                Section("Recorded Attempts (\(viewModel.pastPaperAttempts.count))") {
                    ForEach(viewModel.pastPaperAttempts) { att in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(att.subjectName) (\(att.subjectCode)) · \(att.year) \(att.session)")
                                    .font(.caption.weight(.bold))
                                Spacer()
                                Text("\(att.scoreObtained)/\(att.maxScore)")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(DesignTokens.primaryBrand)
                            }
                            Text("\(att.questionNumber): \(att.topic)")
                                .font(.subheadline.weight(.semibold))
                            if !att.mistakesNotes.isEmpty {
                                Text("Note: \(att.mistakesNotes)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Past Papers Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AiTutorChatView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var input: String = ""

    var body: some View {
        let currentSubject = SubjectCatalogue.getSubject(by: viewModel.selectedChatSubjectId) ?? SubjectCatalogue.subjects[0]
        let messages = viewModel.chatMessages.filter {
            SubjectCatalogue.normalizeSubjectId($0.subjectId) == currentSubject.id
        }

        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SubjectCatalogue.subjects) { sub in
                            SubjectFilterPill(
                                label: "\(sub.shortName) (\(sub.code))",
                                isSelected: currentSubject.id == sub.id
                            ) {
                                viewModel.selectedChatSubjectId = sub.id
                            }
                        }
                    }
                    .padding()
                }
                Divider()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isFromUser { Spacer() }
                                Text(msg.messageText)
                                    .font(.subheadline)
                                    .foregroundColor(msg.isFromUser ? .white : .primary)
                                    .padding(12)
                                    .background(msg.isFromUser ? DesignTokens.primaryBrand : DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                if !msg.isFromUser { Spacer() }
                            }
                        }
                        if viewModel.isSendingMessage {
                            ProgressView("Tutor is reviewing syllabus...")
                                .font(.caption)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                }

                Divider()
                HStack {
                    TextField("Ask \(currentSubject.shortName) (\(currentSubject.code)) Tutor...", text: $input)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        let q = input
                        input = ""
                        viewModel.sendChatMessage(q)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DesignTokens.primaryBrand)
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSendingMessage)
                }
                .padding()
            }
            .navigationTitle("Cambridge AI Tutors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AiGeneratorSheetView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubjectId: String = "physics"
    @State private var topic: String = "Refraction & Snell's Law"
    @State private var contentType: String = "Study Note"
    @State private var difficulty: String = "Extended"

    var body: some View {
        let sub = SubjectCatalogue.getSubject(by: selectedSubjectId) ?? SubjectCatalogue.subjects[0]
        NavigationStack {
            Form {
                Section("Syllabus Parameters") {
                    Picker("Subject", selection: $selectedSubjectId) {
                        ForEach(SubjectCatalogue.subjects) { s in
                            Text("\(s.name) (\(s.code))").tag(s.id)
                        }
                    }
                    TextField("Topic", text: $topic)
                    Picker("Content Type", selection: $contentType) {
                        ForEach(["Study Note", "Quiz", "Flashcard", "Exam Tip"], id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    Picker("Tier", selection: $difficulty) {
                        Text("Core").tag("Core")
                        Text("Extended").tag("Extended")
                    }
                    .pickerStyle(.segmented)

                    Button {
                        viewModel.generateAiSyllabusItem(subject: sub, topic: topic, contentType: contentType, difficulty: difficulty)
                    } label: {
                        if viewModel.isGeneratingAi {
                            ProgressView("Generating...")
                        } else {
                            Text("Generate with Gemini AI")
                                .font(.headline)
                        }
                    }
                    .disabled(viewModel.isGeneratingAi)
                }

                if let gen = viewModel.aiGeneratedContent {
                    Section("Generated Preview") {
                        Text(gen.title).font(.headline)
                        Text(gen.content).font(.subheadline)
                        Text(gen.formulaOrKeyPoint)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(DesignTokens.primaryBrand)

                        Button("Publish to Feed (+20 Pts)") {
                            viewModel.createPost(
                                subject: sub,
                                topicTitle: gen.title,
                                chapterName: "\(sub.shortName) · AI Generated",
                                mainContent: gen.content,
                                formulaOrKeyPoint: gen.formulaOrKeyPoint,
                                quizQuestion: gen.quizQuestion,
                                quizOptions: gen.quizOptions ?? [],
                                quizCorrectIndex: gen.quizCorrectIndex,
                                quizExplanation: gen.quizExplanation,
                                postType: "AI_NOTE",
                                difficulty: difficulty
                            )
                            viewModel.aiGeneratedContent = nil
                            dismiss()
                        }

                        Button("Save as Flashcard (+15 Pts)") {
                            viewModel.createFlashcard(
                                subject: sub,
                                topic: gen.title,
                                difficulty: difficulty,
                                front: gen.flashcardFront ?? gen.title,
                                back: gen.flashcardBack ?? gen.content
                            )
                            viewModel.aiGeneratedContent = nil
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("AI Syllabus Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct AiMarkingSheetView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSubjectId: String = "physics"
    @State private var topic: String = "Waves & Refraction"
    @State private var questionText: String = "Explain why light bends towards the normal when passing from air into glass. [3 marks]"
    @State private var studentAnswer: String = ""

    var body: some View {
        let sub = SubjectCatalogue.getSubject(by: selectedSubjectId) ?? SubjectCatalogue.subjects[0]
        NavigationStack {
            Form {
                Section("Written Exam Question") {
                    Picker("Subject", selection: $selectedSubjectId) {
                        ForEach(SubjectCatalogue.subjects) { s in
                            Text("\(s.name) (\(s.code))").tag(s.id)
                        }
                    }
                    TextField("Topic", text: $topic)
                    TextField("Question", text: $questionText, axis: .vertical)
                    TextField("Your Written Answer", text: $studentAnswer, axis: .vertical)
                        .lineLimit(4...8)

                    Button {
                        viewModel.markAnswerWithAi(subject: sub, topic: topic, questionText: questionText, studentAnswer: studentAnswer)
                    } label: {
                        if viewModel.isMarkingAnswer {
                            ProgressView("Examiner evaluating...")
                        } else {
                            Text("Mark My Answer")
                                .font(.headline)
                        }
                    }
                    .disabled(viewModel.isMarkingAnswer || studentAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let res = viewModel.markingResult {
                    Section("Examiner Feedback (\(res.score)/\(res.maxScore) Marks)") {
                        Text(res.improvementTips)
                            .font(.subheadline)
                        Text("Model Answer: \(res.modelAnswer)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("AI Examiner Marking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.markingResult = nil
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsSheetView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $viewModel.isDarkTheme)
                }
                Section("Gemini 2.5 Flash API Key (Optional)") {
                    SecureField("Paste your GEMINI_API_KEY", text: $viewModel.customApiKey)
                    Text("Used for live AI Tutor, AI Generator, and AI Examiner Marking. Leave blank to use built-in offline study mode.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Section("Active IGCSE Subjects") {
                    ForEach(SubjectCatalogue.subjects) { sub in
                        let isSelected = viewModel.selectedSubjectIds.contains(sub.id)
                        Button {
                            var updated = Set(viewModel.selectedSubjectIds)
                            if isSelected && updated.count > 1 {
                                updated.remove(sub.id)
                            } else {
                                updated.insert(sub.id)
                            }
                            viewModel.completeOnboarding(with: Array(updated))
                        } label: {
                            HStack {
                                Text("\(sub.name) (\(sub.code))")
                                    .foregroundColor(.primary)
                                Spacer()
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(DesignTokens.primaryBrand)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
