import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var dailySummary: DailySummary
    @Published private(set) var weeklySummary: WeeklySummary

    private let scoringService: DriftScoringService
    private let dataProvider: ZeenDataProviding

    init(scoringService: DriftScoringService, dataProvider: ZeenDataProviding) {
        self.scoringService = scoringService
        self.dataProvider = dataProvider

        let input = dataProvider.todayInput()
        let score = scoringService.score(input: input)
        self.dailySummary = DailySummary(date: .now, score: score, timeline: dataProvider.timelineForToday())
        self.weeklySummary = dataProvider.weeklySummary()
    }

    func refresh() {
        let input = dataProvider.todayInput()
        let score = scoringService.score(input: input)
        dailySummary = DailySummary(date: .now, score: score, timeline: dataProvider.timelineForToday())
        weeklySummary = dataProvider.weeklySummary()
    }

    var highestDriftPeriod: TimelinePoint? {
        dailySummary.timeline.max(by: { $0.score < $1.score })
    }
}
