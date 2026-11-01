import SwiftUI

struct CreatePostView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @State private var selectedSubjectId: String = "physics"
    @State private var postType: String = "FORMULA"
    @State private var difficulty: String = "Extended"
    @State private var topicTitle: String = ""
    @State private var chapterName: String = ""
    @State private var mainContent: String = ""
    @State private var formulaOrKeyPoint: String = ""
    @State private var includeQuiz: Bool = false
    @State private var quizQuestion: String = ""
    @State private var optA: String = ""
    @State private var optB: String = ""
    @State private var optC: String = ""
    @State private var optD: String = ""
    @State private var correctIndex: Int = 0
    @State private var quizExplanation: String = ""

    var body: some View {
        Form {
            Section("Syllabus Subject & Format") {
                Picker("Subject", selection: $selectedSubjectId) {
                    ForEach(SubjectCatalogue.subjects) { sub in
                        Text("\(sub.name) (\(sub.code))").tag(sub.id)
                    }
                }
                Picker("Format", selection: $postType) {
                    Text("Revision Note").tag("POST")
                    Text("Formula Sheet").tag("FORMULA")
                    Text("Quiz Challenge").tag("QUIZ")
                    Text("Exam Tip").tag("EXAM_TIP")
                }
                Picker("Tier", selection: $difficulty) {
                    Text("Core").tag("Core")
                    Text("Extended").tag("Extended")
                }
                .pickerStyle(.segmented)
            }

            Section("Revision Content") {
                TextField("Topic Title (e.g. Snell's Law)", text: $topicTitle)
                TextField("Unit / Chapter (e.g. Unit 3 · Waves)", text: $chapterName)
                TextField("Main Explanation / Summary", text: $mainContent, axis: .vertical)
                    .lineLimit(4...8)
                TextField("Key Formula or Examiner Rule (Optional)", text: $formulaOrKeyPoint)
            }

            Section("Optional Multiple-Choice Checkpoint") {
                Toggle("Include 4-Option Quiz", isOn: $includeQuiz)
                if includeQuiz || postType == "QUIZ" {
                    TextField("Quiz Question", text: $quizQuestion)
                    TextField("Option A", text: $optA)
                    TextField("Option B", text: $optB)
                    TextField("Option C", text: $optC)
                    TextField("Option D", text: $optD)
                    Picker("Correct Option", selection: $correctIndex) {
                        Text("A").tag(0)
                        Text("B").tag(1)
                        Text("C").tag(2)
                        Text("D").tag(3)
                    }
                    .pickerStyle(.segmented)
                    TextField("Mark Scheme Explanation", text: $quizExplanation)
                }
            }

            Section {
                Button {
                    let sub = SubjectCatalogue.getSubject(by: selectedSubjectId) ?? SubjectCatalogue.subjects[0]
                    viewModel.createPost(
                        subject: sub,
                        topicTitle: topicTitle,
                        chapterName: chapterName,
                        mainContent: mainContent,
                        formulaOrKeyPoint: formulaOrKeyPoint,
                        quizQuestion: (includeQuiz || postType == "QUIZ") ? quizQuestion : nil,
                        quizOptions: [optA, optB, optC, optD],
                        quizCorrectIndex: correctIndex,
                        quizExplanation: quizExplanation,
                        postType: postType,
                        difficulty: difficulty
                    )
                    topicTitle = ""
                    chapterName = ""
                    mainContent = ""
                    formulaOrKeyPoint = ""
                    quizQuestion = ""
                    optA = ""
                    optB = ""
                    optC = ""
                    optD = ""
                } label: {
                    Text("Publish to Revision Feed (+20 Pts)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .disabled(topicTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                          mainContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

struct ProgressMasteryView: View {
    @EnvironmentObject var viewModel: ReviseViewModel

    private var overallAccuracy: Int {
        let total = viewModel.userStats.totalQuizzesAnswered
        guard total > 0 else { return 0 }
        return Int((Double(viewModel.userStats.correctQuizzesCount) / Double(total)) * 100.0)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Syllabus Mastery")
                            .font(.title2.weight(.bold))
                        Text("Cambridge IGCSE exam readiness & diagnostics")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button {
                        viewModel.showAiMarkingSheet = true
                    } label: {
                        Label("AI Examiner", systemImage: "checkmark.seal.fill")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(DesignTokens.primaryBrand)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }

                // Summary Metrics Card
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("\(overallAccuracy)%")
                            .font(.title2.weight(.bold))
                            .foregroundColor(DesignTokens.primaryBrand)
                        Text("Accuracy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Divider().frame(height: 36)
                    Spacer()
                    VStack(spacing: 4) {
                        Text("\(viewModel.userStats.streakDays)d")
                            .font(.title2.weight(.bold))
                            .foregroundColor(DesignTokens.warningAmber)
                        Text("Streak")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Divider().frame(height: 36)
                    Spacer()
                    VStack(spacing: 4) {
                        Text("\(viewModel.userStats.revisePoints)")
                            .font(.title2.weight(.bold))
                            .foregroundColor(DesignTokens.primaryBrand)
                        Text("RevisePoints")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(18)
                .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Daily Missions
                Text("Daily Revision Missions")
                    .font(.headline)

                VStack(spacing: 10) {
                    ForEach(viewModel.dailyMissions) { mission in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mission.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(mission.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ProgressView(
                                    value: Double(min(mission.currentCount, mission.targetCount)),
                                    total: Double(max(1, mission.targetCount))
                                )
                                .tint(DesignTokens.primaryBrand)
                            }
                            Spacer()
                            if mission.isClaimed {
                                Text("Claimed ✓")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(DesignTokens.successGreen)
                            } else if mission.isCompleted {
                                Button("Claim +\(mission.rewardPoints)") {
                                    viewModel.claimMission(mission)
                                }
                                .font(.caption.weight(.bold))
                                .buttonStyle(.borderedProminent)
                                .tint(DesignTokens.successGreen)
                            } else {
                                Text("\(mission.currentCount)/\(mission.targetCount)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Subject Breakdown
                Text("Subject Competency Breakdown")
                    .font(.headline)

                VStack(spacing: 10) {
                    ForEach(viewModel.selectedSubjects) { subject in
                        let subAttempts = viewModel.quizAttempts.filter { $0.subjectCode == subject.code }
                        let pct = subAttempts.isEmpty ? 0 : Int((Double(subAttempts.filter(\.isCorrect).count) / Double(subAttempts.count)) * 100.0)

                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("\(subject.shortName) (\(subject.code))")
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text("\(pct)% (\(subAttempts.count) attempts)")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(pct >= 80 ? DesignTokens.successGreen : .secondary)
                            }
                            ProgressView(value: Double(pct), total: 100.0)
                                .tint(pct >= 80 ? DesignTokens.successGreen : DesignTokens.primaryBrand)
                        }
                        .padding(14)
                        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(DesignTokens.border(isDark: viewModel.isDarkTheme), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(DesignTokens.screenHorizontalPadding)
        }
        .background(DesignTokens.background(isDark: viewModel.isDarkTheme))
    }
}

struct ProfileView: View {
    @EnvironmentObject var viewModel: ReviseViewModel
    @State private var selectedSection: Int = 0
    @State private var newFolderName: String = ""
    @State private var showNewFolderAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(spacing: 16) {
                    Text(viewModel.userStats.selectedAvatar)
                        .font(.title2.weight(.bold))
                        .foregroundColor(DesignTokens.primaryBrand)
                        .frame(width: 64, height: 64)
                        .background(DesignTokens.primaryBrand.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.userStats.userTitle)
                            .font(.headline)
                        Text("Level \(viewModel.userStats.userLevel) · \(viewModel.savedPosts.count) Saved Notes · \(viewModel.userStats.streakShieldsActive) Rest Shields")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    Button {
                        showNewFolderAlert = true
                    } label: {
                        Label("New Folder", systemImage: "folder.badge.plus")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(DesignTokens.border(isDark: viewModel.isDarkTheme)))
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.showSettingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "slider.horizontal.3")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(DesignTokens.border(isDark: viewModel.isDarkTheme)))
                    }
                    .buttonStyle(.plain)
                }

                Picker("Section", selection: $selectedSection) {
                    Text("Saved (\(viewModel.savedPosts.count))").tag(0)
                    Text("Folders (\(viewModel.collections.count))").tag(1)
                    Text("Rewards").tag(2)
                }
                .pickerStyle(.segmented)

                if selectedSection == 0 {
                    if viewModel.savedPosts.isEmpty {
                        Text("Bookmark revision cards from your Home feed to review them here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 24)
                    } else {
                        ForEach(viewModel.savedPosts) { post in
                            PostCardView(post: post)
                        }
                    }
                } else if selectedSection == 1 {
                    ForEach(viewModel.collections) { folder in
                        HStack {
                            Text(folder.iconEmoji)
                                .font(.title3)
                            VStack(alignment: .leading) {
                                Text(folder.name)
                                    .font(.subheadline.weight(.semibold))
                                Text(folder.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DesignTokens.border(isDark: viewModel.isDarkTheme)))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } else {
                    ForEach(viewModel.rewards) { reward in
                        HStack {
                            Text(reward.iconEmoji)
                                .font(.headline)
                                .frame(width: 40, height: 40)
                                .background(DesignTokens.primaryBrand.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(reward.title)
                                    .font(.subheadline.weight(.semibold))
                                Text(reward.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button(reward.isUnlocked ? (reward.isEquipped ? "Equipped" : "Equip") : "\(reward.pointCost) pts") {
                                viewModel.purchaseOrEquipReward(reward)
                            }
                            .font(.caption.weight(.bold))
                            .buttonStyle(.borderedProminent)
                            .tint(reward.isEquipped ? DesignTokens.successGreen : DesignTokens.primaryBrand)
                        }
                        .padding(14)
                        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(DesignTokens.border(isDark: viewModel.isDarkTheme)))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(DesignTokens.screenHorizontalPadding)
        }
        .background(DesignTokens.background(isDark: viewModel.isDarkTheme))
        .alert("New Topic Folder", isPresented: $showNewFolderAlert) {
            TextField("Folder Name", text: $newFolderName)
            Button("Create") {
                viewModel.createCollection(name: newFolderName)
                newFolderName = ""
            }
            Button("Cancel", role: .cancel) { newFolderName = "" }
        }
    }
}
