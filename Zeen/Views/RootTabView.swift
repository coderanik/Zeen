import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                TodayView()
            }
            .tabItem {
                Label("Today", systemImage: "gauge.with.dots.needle.67percent")
            }

            NavigationStack {
                FocusSessionView()
            }
            .tabItem {
                Label("Focus", systemImage: "timer")
            }

            NavigationStack {
                TimelineScreen()
            }
            .tabItem {
                Label("Timeline", systemImage: "chart.bar.xaxis")
            }

            NavigationStack {
                WeeklyInsightsView()
            }
            .tabItem {
                Label("Weekly", systemImage: "chart.xyaxis.line")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "slider.horizontal.3")
            }
        }
        .tint(ZeenTheme.accentCyan)
    }
}
