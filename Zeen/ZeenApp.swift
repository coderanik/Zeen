import SwiftUI

@main
struct ZeenApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel(
        scoringService: DriftScoringService(),
        dataProvider: LiveDataProvider()
    )
    @StateObject private var sessionViewModel = SessionViewModel()
    @StateObject private var focusViewModel = FocusSessionViewModel()

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(dashboardViewModel)
                .environmentObject(sessionViewModel)
                .environmentObject(focusViewModel)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { _, newPhase in
                    // Track real app lifecycle transitions
                    ActivityTracker.shared.handleScenePhaseChange(newPhase)

                    // Refresh dashboard data when app becomes active
                    if newPhase == .active {
                        dashboardViewModel.refresh(profile: sessionViewModel.profile)
                    }

                    // Save snapshot when going to background
                    if newPhase == .background {
                        focusViewModel.handleAppBackgrounded()
                        ActivityTracker.shared.saveTodaySnapshot(
                            deepFocusMinutes: focusViewModel.lifetimeFocusMinutes
                        )
                    }
                }
        }
    }
}
