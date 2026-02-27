import XCTest
@testable import Zeen

final class DriftScoringServiceTests: XCTestCase {

    private var sut: DriftScoringService!

    override func setUp() {
        super.setUp()
        sut = DriftScoringService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - score()

    func testZeroInputProducesZeroScore() {
        let input = DriftInput(appSwitches: 0, shortSessions: 0, notificationInterruptions: 0, focusBreaks: 0)
        let result = sut.score(input: input)

        XCTAssertEqual(result.value, 0)
        XCTAssertEqual(result.level, .calm)
        XCTAssertEqual(result.factors.count, 4)
    }

    func testMaxInputProducesFullScore() {
        let input = DriftInput(appSwitches: 40, shortSessions: 30, notificationInterruptions: 40, focusBreaks: 20)
        let result = sut.score(input: input)

        XCTAssertEqual(result.value, 100)
        XCTAssertEqual(result.level, .overloaded)
    }

    func testScoreLevelBoundaries() {
        // Calm: 0..<25
        let calm = sut.score(input: DriftInput(appSwitches: 5, shortSessions: 3, notificationInterruptions: 4, focusBreaks: 1))
        XCTAssertEqual(calm.level, .calm)
        XCTAssertLessThan(calm.value, 25)

        // High: over 50
        let high = sut.score(input: DriftInput(appSwitches: 30, shortSessions: 20, notificationInterruptions: 25, focusBreaks: 12))
        XCTAssertTrue(high.level == .high || high.level == .overloaded)
        XCTAssertGreaterThanOrEqual(high.value, 50)
    }

    func testInputExceedingMaxIsCapped() {
        let input = DriftInput(appSwitches: 999, shortSessions: 999, notificationInterruptions: 999, focusBreaks: 999)
        let result = sut.score(input: input)

        XCTAssertEqual(result.value, 100, "Score should be capped at 100")
        XCTAssertEqual(result.level, .overloaded)
    }

    func testFactorsHaveCorrectTitles() {
        let input = DriftInput(appSwitches: 10, shortSessions: 5, notificationInterruptions: 8, focusBreaks: 3)
        let result = sut.score(input: input)

        let titles = result.factors.map(\.title)
        XCTAssertTrue(titles.contains("App Switching"))
        XCTAssertTrue(titles.contains("Short Sessions"))
        XCTAssertTrue(titles.contains("Notifications"))
        XCTAssertTrue(titles.contains("Focus Breaks"))
    }

    func testFactorWeightsSumToOne() {
        let input = DriftInput(appSwitches: 1, shortSessions: 1, notificationInterruptions: 1, focusBreaks: 1)
        let result = sut.score(input: input)
        let totalWeight = result.factors.map(\.weight).reduce(0, +)

        XCTAssertEqual(totalWeight, 1.0, accuracy: 0.01, "Factor weights should sum to 1.0")
    }

    // MARK: - generateInsights()

    func testInsightsContainOverallAssessment() {
        let input = DriftInput(appSwitches: 5, shortSessions: 3, notificationInterruptions: 2, focusBreaks: 1)
        let score = sut.score(input: input)
        let timeline = [TimelinePoint(hour: 9, score: 15, interruptionCount: 1)]
        let daily = DailySummary(date: .now, score: score, timeline: timeline)
        let weekly = WeeklySummary(weekStart: .now, points: [
            WeeklyDriftPoint(dayIndex: 0, score: 20, deepFocusMinutes: 120)
        ])

        let insights = sut.generateInsights(daily: daily, weekly: weekly, profile: nil)

        XCTAssertFalse(insights.isEmpty, "Should generate at least one insight")
        XCTAssertEqual(insights.first?.tone, .positive, "Low score should produce positive assessment")
    }

    func testInsightsIncludeGoalTracking() {
        let input = DriftInput(appSwitches: 30, shortSessions: 20, notificationInterruptions: 25, focusBreaks: 10)
        let score = sut.score(input: input)
        let daily = DailySummary(date: .now, score: score, timeline: [])
        let weekly = WeeklySummary(weekStart: .now, points: [
            WeeklyDriftPoint(dayIndex: 0, score: 60, deepFocusMinutes: 50)
        ])
        let profile = UserProfile(name: "Test", email: "test@test.com", goalAverageScore: 40)

        let insights = sut.generateInsights(daily: daily, weekly: weekly, profile: profile)
        let goalInsight = insights.first(where: { $0.title.contains("goal") || $0.title.contains("Goal") })

        XCTAssertNotNil(goalInsight, "Should include a goal-related insight when average exceeds goal")
    }

    // MARK: - trendDirection()

    func testTrendDetectsImprovement() {
        let points = [
            WeeklyDriftPoint(dayIndex: 0, score: 70, deepFocusMinutes: 60),
            WeeklyDriftPoint(dayIndex: 1, score: 65, deepFocusMinutes: 80),
            WeeklyDriftPoint(dayIndex: 2, score: 60, deepFocusMinutes: 100),
            WeeklyDriftPoint(dayIndex: 3, score: 55, deepFocusMinutes: 90),
            WeeklyDriftPoint(dayIndex: 4, score: 40, deepFocusMinutes: 130),
            WeeklyDriftPoint(dayIndex: 5, score: 30, deepFocusMinutes: 150),
            WeeklyDriftPoint(dayIndex: 6, score: 25, deepFocusMinutes: 160),
        ]
        let weekly = WeeklySummary(weekStart: .now, points: points)

        XCTAssertEqual(sut.trendDirection(for: weekly), .improving)
    }

    func testTrendDetectsWorsening() {
        let points = [
            WeeklyDriftPoint(dayIndex: 0, score: 20, deepFocusMinutes: 160),
            WeeklyDriftPoint(dayIndex: 1, score: 25, deepFocusMinutes: 150),
            WeeklyDriftPoint(dayIndex: 2, score: 30, deepFocusMinutes: 130),
            WeeklyDriftPoint(dayIndex: 3, score: 45, deepFocusMinutes: 100),
            WeeklyDriftPoint(dayIndex: 4, score: 60, deepFocusMinutes: 80),
            WeeklyDriftPoint(dayIndex: 5, score: 70, deepFocusMinutes: 60),
            WeeklyDriftPoint(dayIndex: 6, score: 75, deepFocusMinutes: 50),
        ]
        let weekly = WeeklySummary(weekStart: .now, points: points)

        XCTAssertEqual(sut.trendDirection(for: weekly), .worsening)
    }

    func testTrendDetectsStable() {
        let points = [
            WeeklyDriftPoint(dayIndex: 0, score: 42, deepFocusMinutes: 100),
            WeeklyDriftPoint(dayIndex: 1, score: 44, deepFocusMinutes: 110),
            WeeklyDriftPoint(dayIndex: 2, score: 40, deepFocusMinutes: 105),
            WeeklyDriftPoint(dayIndex: 3, score: 43, deepFocusMinutes: 100),
            WeeklyDriftPoint(dayIndex: 4, score: 41, deepFocusMinutes: 108),
            WeeklyDriftPoint(dayIndex: 5, score: 45, deepFocusMinutes: 100),
            WeeklyDriftPoint(dayIndex: 6, score: 42, deepFocusMinutes: 102),
        ]
        let weekly = WeeklySummary(weekStart: .now, points: points)

        XCTAssertEqual(sut.trendDirection(for: weekly), .stable)
    }

    func testTrendWithTooFewPointsReturnsStable() {
        let weekly = WeeklySummary(weekStart: .now, points: [
            WeeklyDriftPoint(dayIndex: 0, score: 80, deepFocusMinutes: 30),
            WeeklyDriftPoint(dayIndex: 1, score: 20, deepFocusMinutes: 180),
        ])

        XCTAssertEqual(sut.trendDirection(for: weekly), .stable,
                       "Should return stable with fewer than 4 data points")
    }
}
