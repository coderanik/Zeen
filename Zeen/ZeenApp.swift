import SwiftUI

@main
struct ZeenApp: App {
    @StateObject private var dashboardViewModel = DashboardViewModel(
        scoringService: DriftScoringService(),
        dataProvider: MockDataProvider()
    )

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(dashboardViewModel)
        }
    }
}
