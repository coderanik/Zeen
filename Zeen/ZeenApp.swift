import SwiftUI

@main
struct ZeenApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel(
        scoringService: DriftScoringService(),
        dataProvider: MockDataProvider()
    )
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var focusViewModel = FocusSessionViewModel()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(dashboardViewModel)
                .environmentObject(sessionViewModel)
                .environmentObject(focusViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
