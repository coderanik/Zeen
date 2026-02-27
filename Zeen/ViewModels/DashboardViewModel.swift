import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var dailySummary: DailySummary
    @Published private(set) var weeklySummary: WeeklySummary
    @Published private(set) var insights: [DriftInsight] = []
    @Published private(set) var trend: TrendDirection = .stable
    @Published var preferences: ZeenPreferences = ZeenPreferences()

    private let scoringService: DriftScoringService
    private let dataProvider: ZeenDataProviding

    init(scoringService: DriftScoringService, dataProvider: ZeenDataProviding) {
        self.scoringService = scoringService
        self.dataProvider = dataProvider

        let input = dataProvider.todayInput()
        let score = scoringService.score(input: input)
        self.dailySummary = DailySummary(date: .now, score: score, timeline: dataProvider.timelineForToday())
        self.weeklySummary = dataProvider.weeklySummary()
        self.trend = scoringService.trendDirection(for: self.weeklySummary)
    }

    func refresh(profile: UserProfile? = nil) {
        let base = dataProvider.todayInput()
        let adjusted = DriftInput(
            appSwitches: base.appSwitches,
            shortSessions: base.shortSessions,
            notificationInterruptions: preferences.useNotificationsSignal ? base.notificationInterruptions : 0,
            focusBreaks: preferences.useFocusIntegration ? base.focusBreaks : 0
        )

        let score = scoringService.score(input: adjusted)
        dailySummary = DailySummary(date: .now, score: score, timeline: dataProvider.timelineForToday())
        weeklySummary = dataProvider.weeklySummary()
        trend = scoringService.trendDirection(for: weeklySummary)
        insights = scoringService.generateInsights(daily: dailySummary, weekly: weeklySummary, profile: profile)
    }

    var highestDriftPeriod: TimelinePoint? {
        dailySummary.timeline.max(by: { $0.score < $1.score })
    }

    var totalInterruptions: Int {
        dailySummary.timeline.map(\.interruptionCount).reduce(0, +)
    }

    var totalAppSwitches: Int {
        dailySummary.score.factors.first(where: { $0.title == "App Switching" })?.observed ?? 0
    }
}
