import SwiftUI

struct RootContainerView: View {
    @EnvironmentObject var viewModel: ReviseViewModel

    var body: some View {
        Group {
            if !viewModel.hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabScaffoldView()
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = viewModel.feedbackMessage {
                Text(msg)
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .padding(.bottom, 76)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.feedbackMessage)
    }
}

struct MainTabScaffoldView: View {
    @EnvironmentObject var viewModel: ReviseViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopHeaderBar()
                TabView(selection: $viewModel.selectedTab) {
                    HomeFeedView()
                        .tabItem { Label("Home", systemImage: NavTab.home.systemIcon) }
                        .tag(NavTab.home)

                    ExploreSearchView()
                        .tabItem { Label("Explore", systemImage: NavTab.explore.systemIcon) }
                        .tag(NavTab.explore)

                    CreatePostView()
                        .tabItem { Label("Create", systemImage: NavTab.create.systemIcon) }
                        .tag(NavTab.create)

                    ProgressMasteryView()
                        .tabItem { Label("Progress", systemImage: NavTab.progress.systemIcon) }
                        .tag(NavTab.progress)

                    ProfileView()
                        .tabItem { Label("Profile", systemImage: NavTab.profile.systemIcon) }
                        .tag(NavTab.profile)
                }
                .tint(DesignTokens.primaryBrand)
            }
            .sheet(item: $viewModel.activeStory) { story in
                StoryViewerSheet(story: story)
            }
            .sheet(item: $viewModel.activeCommentsPost) { post in
                CommentsSheetView(post: post)
            }
            .sheet(isPresented: $viewModel.showFlashcardsSheet) {
                FlashcardsDeckView()
            }
            .sheet(isPresented: $viewModel.showPastPapersSheet) {
                PastPapersTrackerView()
            }
            .sheet(isPresented: $viewModel.showExamModeSheet) {
                ExamSimulatorView()
            }
            .sheet(isPresented: $viewModel.showAiTutorSheet) {
                AiTutorChatView()
            }
            .sheet(isPresented: $viewModel.showAiGeneratorSheet) {
                AiGeneratorSheetView()
            }
            .sheet(isPresented: $viewModel.showAiMarkingSheet) {
                AiMarkingSheetView()
            }
            .sheet(isPresented: $viewModel.showSettingsSheet) {
                SettingsSheetView()
            }
        }
    }
}

struct TopHeaderBar: View {
    @EnvironmentObject var viewModel: ReviseViewModel

    var body: some View {
        HStack {
            Text("ReviseGram")
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 8) {
                Label("\(viewModel.userStats.streakDays)d", systemImage: "flame.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(DesignTokens.warningAmber)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                    .clipShape(Capsule())

                Label("\(viewModel.userStats.revisePoints) pts", systemImage: "star.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(DesignTokens.primaryBrand)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(DesignTokens.surfaceVariant(isDark: viewModel.isDarkTheme))
                    .clipShape(Capsule())

                Button {
                    viewModel.showSettingsSheet = true
                } label: {
                    Image(systemName: "gearshape")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
        }
        .padding(.horizontal, DesignTokens.screenHorizontalPadding)
        .padding(.vertical, 10)
        .background(DesignTokens.surface(isDark: viewModel.isDarkTheme))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}
