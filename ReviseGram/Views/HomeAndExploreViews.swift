import SwiftUI

struct HomeFeedView: View {
    @EnvironmentObject var viewModel: ReviseViewModel

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning."
        case 12..<18: return "Good afternoon."
        default: return "Good evening."
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // 1. Editorial Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title2.weight(.bold))
                    Text("Focused Cambridge IGCSE revision space")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, DesignTokens.screenHorizontalPadding)
                .padding(.top, 12)

                // 2. Stories Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.stories) { story in
                            Button {
                                viewModel.activeStorySlideIndex = 0
                                viewModel.activeStory = story
                            } label: {
                                VStack(spacing: 6) {
                                    Text(story.subjectCode)
                                        .font(.system(.caption, design: .monospaced).weight(.bold))
                                        .foregroundColor(DesignTokens.primaryBrand)
                                        .frame(width: 56, height: 56)
                                        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                                        .overlay(
                                            Circle().stroke(
                                                story.isViewed ? Color.secondary.opacity(0.35) : DesignTokens.primaryBrand,
                                                lineWidth: 2
                                            )
                                        )
                                        .clipShape(Circle())

                                    Text(story.subjectName)
                                        .font(.caption2.weight(.medium))
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .frame(width: 68)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, DesignTokens.screenHorizontalPadding)
                }

                // 3. Quick Study Tools
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        QuickToolChip(title: "Flashcards", subtitle: "Active recall", icon: "rectangle.stack.fill") {
                            viewModel.showFlashcardsSheet = true
                        }
                        QuickToolChip(title: "Exam Mode", subtitle: "Timed mock", icon: "timer") {
                            viewModel.showExamModeSheet = true
                        }
                        QuickToolChip(title: "Past Papers", subtitle: "Score log", icon: "doc.text.fill") {
                            viewModel.showPastPapersSheet = true
                        }
                        QuickToolChip(title: "AI Tutor", subtitle: "Syllabus Q&A", icon: "sparkles") {
                            viewModel.showAiTutorSheet = true
                        }
                        QuickToolChip(title: "AI Generate", subtitle: "Notes & quiz", icon: "wand.and.stars") {
                            viewModel.showAiGeneratorSheet = true
                        }
                    }
                    .padding(.horizontal, DesignTokens.screenHorizontalPadding)
                }

                // 4. Subject Filter Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        SubjectFilterPill(
                            label: "All Subjects",
                            isSelected: viewModel.selectedSubjectFilter == "ALL"
                        ) {
                            viewModel.selectedSubjectFilter = "ALL"
                        }
                        ForEach(viewModel.selectedSubjects) { subject in
                            SubjectFilterPill(
                                label: "\(subject.shortName) · \(subject.code)",
                                isSelected: SubjectCatalogue.normalizeSubjectId(viewModel.selectedSubjectFilter) == subject.id
                            ) {
                                viewModel.selectedSubjectFilter = subject.id
                            }
                        }
                    }
                    .padding(.horizontal, DesignTokens.screenHorizontalPadding)
                }

                // 5. Feed Posts
                ForEach(viewModel.filteredPosts) { post in
                    PostCardView(post: post)
                        .padding(.horizontal, DesignTokens.screenHorizontalPadding)
                }
            }
            .padding(.bottom, 32)
        }
        .background(DesignTokens.background(isDark: viewModel.isDarkTheme))
    }
}

struct QuickToolChip: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(DesignTokens.primaryBrand)
                    .frame(width: 32, height: 32)
                    .background(DesignTokens.primaryBrand.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct SubjectFilterPill: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(isSelected ? DesignTokens.primaryBrand : DesignTokens.surface(isDark: viewModel.isDarkTheme))
                .overlay(
                    Capsule().stroke(
                        isSelected ? Color.clear : DesignTokens.border(isDark: viewModel.isDarkTheme),
                        lineWidth: 1
                    )
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct PostCardView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    let post: PostItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(post.subjectCode)
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundColor(DesignTokens.primaryBrand)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignTokens.primaryBrand.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                VStack(alignment: .leading, spacing: 1) {
                    Text(post.subjectName)
                        .font(.caption.weight(.semibold))
                    Text(post.chapterName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(post.difficulty)
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                    .clipShape(Capsule())
            }

            // Title & Content
            Text(post.topicTitle)
                .font(.headline)

            Text(post.mainContent)
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            if let formula = post.formulaOrKeyPoint, !formula.isEmpty {
                Text(formula)
                    .font(.system(.footnote, design: .monospaced).weight(.semibold))
                    .foregroundColor(DesignTokens.primaryBrand)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            // Interactive Quiz
            if post.hasValidQuiz, let q = post.quizQuestion {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CHECKPOINT QUESTION")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(DesignTokens.primaryBrand)
                    Text(q)
                        .font(.subheadline.weight(.medium))

                    ForEach(Array(post.quizOptions.enumerated()), id: \.offset) { idx, optionText in
                        let isAnswered = post.userSelectedAnswerIndex != -1
                        let isCorrect = idx == post.quizCorrectIndex
                        let isSelected = idx == post.userSelectedAnswerIndex

                        Button {
                            viewModel.submitQuizAnswer(post: post, optionIndex: idx)
                        } label: {
                            HStack {
                                Text("\(UnicodeScalar(65 + idx)!).")
                                    .font(.caption.weight(.bold))
                                Text(optionText)
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if isAnswered {
                                    if isCorrect {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(DesignTokens.successGreen)
                                    } else if isSelected {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(DesignTokens.errorRed)
                                    }
                                }
                            }
                            .padding(10)
                            .background(
                                !isAnswered ? DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme).opacity(0.5)
                                : (isCorrect ? DesignTokens.successGreen.opacity(0.15)
                                   : (isSelected ? DesignTokens.errorRed.opacity(0.15) : Color.clear))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        !isAnswered ? DesignTokens.border(isDark: viewModel.isDarkTheme)
                                        : (isCorrect ? DesignTokens.successGreen : (isSelected ? DesignTokens.errorRed : Color.clear)),
                                        lineWidth: 1
                                    )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(isAnswered)
                        .buttonStyle(.plain)
                    }

                    if post.userSelectedAnswerIndex != -1, let exp = post.quizExplanation, !exp.isEmpty {
                        Text(exp)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.top, 4)
            }

            Divider()

            // Action Bar
            HStack(spacing: 18) {
                Button {
                    viewModel.toggleLike(post)
                } label: {
                    Label("\(post.likesCount)", systemImage: post.isLiked ? "heart.fill" : "heart")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(post.isLiked ? DesignTokens.errorRed : .secondary)
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.activeCommentsPost = post
                } label: {
                    Label("\(post.commentsCount) Notes", systemImage: "bubble.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.selectedChatSubjectId = post.subjectId
                    viewModel.showAiTutorSheet = true
                    viewModel.sendChatMessage("Explain \(post.topicTitle) (\(post.subjectCode)): \(post.mainContent)")
                } label: {
                    Label("Ask AI Tutor", systemImage: "sparkles")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(DesignTokens.primaryBrand)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    viewModel.toggleSave(post)
                } label: {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundColor(post.isSaved ? DesignTokens.primaryBrand : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ExploreSearchView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    private let suggestions = ["0625", "Snell's Law", "Quadratic", "Electrolysis", "Break-Even", "PED", "0500"]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search syllabus topics, formulas, or codes (e.g. 0625)...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, DesignTokens.screenHorizontalPadding)
            .padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { tag in
                        Button {
                            viewModel.searchQuery = tag
                        } label: {
                            Text(tag)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DesignTokens.screenHorizontalPadding)
            }

            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(viewModel.filteredPosts) { post in
                        PostCardView(post: post)
                            .padding(.horizontal, DesignTokens.screenHorizontalPadding)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .background(DesignTokens.background(isDark: viewModel.isDarkTheme))
    }
}
