import SwiftUI

@main
struct ReviseGramApp: App {
    @StateObject private var viewModel = ReviseViewModel()

    var body: some Scene {
        WindowGroup {
            RootContainerView()
                .environmentObject(viewModel)
                .preferredColorScheme(viewModel.isDarkTheme ? .dark : .light)
        }
    }
}
