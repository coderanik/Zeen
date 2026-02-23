import Foundation

protocol ZeenDataProviding {
    func todayInput() -> DriftInput
    func timelineForToday() -> [TimelinePoint]
    func weeklySummary() -> WeeklySummary
}

struct MockDataProvider: ZeenDataProviding {
    func todayInput() -> DriftInput {
        DriftInput(
            appSwitches: 27,
            shortSessions: 16,
            notificationInterruptions: 21,
            focusBreaks: 8
        )
    }

    func timelineForToday() -> [TimelinePoint] {
        [
            .init(hour: 8, score: 18, interruptionCount: 2),
            .init(hour: 9, score: 22, interruptionCount: 3),
            .init(hour: 10, score: 28, interruptionCount: 4),
            .init(hour: 11, score: 34, interruptionCount: 5),
            .init(hour: 12, score: 52, interruptionCount: 9),
            .init(hour: 13, score: 61, interruptionCount: 10),
            .init(hour: 14, score: 58, interruptionCount: 7),
            .init(hour: 15, score: 47, interruptionCount: 6),
            .init(hour: 16, score: 43, interruptionCount: 4),
            .init(hour: 17, score: 39, interruptionCount: 3),
            .init(hour: 18, score: 36, interruptionCount: 4),
            .init(hour: 19, score: 31, interruptionCount: 2)
        ]
    }

    func weeklySummary() -> WeeklySummary {
        let calendar = Calendar.current
        let weekStart = calendar.date(byAdding: .day, value: -6, to: .now) ?? .now

        return WeeklySummary(
            weekStart: weekStart,
            points: [
                .init(dayIndex: 0, score: 41, deepFocusMinutes: 122),
                .init(dayIndex: 1, score: 54, deepFocusMinutes: 95),
                .init(dayIndex: 2, score: 48, deepFocusMinutes: 113),
                .init(dayIndex: 3, score: 66, deepFocusMinutes: 76),
                .init(dayIndex: 4, score: 58, deepFocusMinutes: 88),
                .init(dayIndex: 5, score: 35, deepFocusMinutes: 154),
                .init(dayIndex: 6, score: 29, deepFocusMinutes: 170)
            ]
        )
    }
}
