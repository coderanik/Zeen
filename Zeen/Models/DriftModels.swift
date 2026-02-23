import Foundation
import SwiftUI

struct DriftInput: Equatable {
    let appSwitches: Int
    let shortSessions: Int
    let notificationInterruptions: Int
    let focusBreaks: Int
}

struct DriftScore: Equatable {
    let value: Int
    let level: DriftLevel
    let factors: [DriftFactor]

    static let empty = DriftScore(value: 0, level: .calm, factors: [])

    var formattedValue: String { "\(value)" }
    var accessibilityLabel: String { "Zeen score \(value), \(level.label)" }
}

enum DriftLevel: String, CaseIterable {
    case calm
    case mild
    case high
    case overloaded

    var label: String {
        switch self {
        case .calm: return "Calm"
        case .mild: return "Mild Zeen"
        case .high: return "High Zeen"
        case .overloaded: return "Overloaded"
        }
    }

    var emoji: String {
        switch self {
        case .calm: return "🧘‍♀️"
        case .mild: return "🌤️"
        case .high: return "🌪️"
        case .overloaded: return "🚨"
        }
    }

    var symbolName: String {
        switch self {
        case .calm: return "leaf"
        case .mild: return "wind"
        case .high: return "tornado"
        case .overloaded: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .calm: return Color.green
        case .mild: return Color.yellow
        case .high: return Color.orange
        case .overloaded: return Color.red
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .calm:
            return LinearGradient(colors: [Color.green.opacity(0.6), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mild:
            return LinearGradient(colors: [Color.yellow.opacity(0.7), Color.orange.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .high:
            return LinearGradient(colors: [Color.orange, Color.red.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .overloaded:
            return LinearGradient(colors: [Color.red, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct DriftFactor: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let weight: Double
    let observed: Int
    let contribution: Int
}

struct TimelinePoint: Identifiable, Equatable {
    let id = UUID()
    let hour: Int
    let score: Int
    let interruptionCount: Int

    var hourLabel: String {
        let normalized = hour % 24
        if normalized == 0 { return "12a" }
        if normalized < 12 { return "\(normalized)a" }
        if normalized == 12 { return "12p" }
        return "\(normalized - 12)p"
    }

    var accentColor: Color {
        switch score {
        case ..<25: return .green
        case 25..<50: return .yellow
        case 50..<75: return .orange
        default: return .red
        }
    }
}

struct WeeklyDriftPoint: Identifiable, Equatable {
    let id = UUID()
    let dayIndex: Int
    let score: Int
    let deepFocusMinutes: Int

    var dayLabel: String {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][max(0, min(dayIndex, 6))]
    }

    var deepFocusLabel: String { "\(deepFocusMinutes) min" }
}

struct DailySummary: Equatable {
    let date: Date
    let score: DriftScore
    let timeline: [TimelinePoint]
}

struct WeeklySummary: Equatable {
    let weekStart: Date
    let points: [WeeklyDriftPoint]

    var averageScore: Int {
        guard !points.isEmpty else { return 0 }
        return points.map(\.score).reduce(0, +) / points.count
    }

    var totalDeepFocusMinutes: Int {
        points.map(\.deepFocusMinutes).reduce(0, +)
    }
}
#if DEBUG
extension DriftInput {
    static let sample = DriftInput(appSwitches: 12, shortSessions: 8, notificationInterruptions: 5, focusBreaks: 3)
}

extension DriftFactor {
    static func sample(title: String, weight: Double, observed: Int, contribution: Int) -> DriftFactor {
        DriftFactor(title: title, weight: weight, observed: observed, contribution: contribution)
    }
}

extension DriftScore {
    static let sampleCalm = DriftScore(
        value: 18,
        level: .calm,
        factors: [
            .sample(title: "Few Notifications", weight: 0.3, observed: 2, contribution: -5),
            .sample(title: "Long Sessions", weight: 0.4, observed: 5, contribution: -7)
        ]
    )

    static let sampleHigh = DriftScore(
        value: 72,
        level: .high,
        factors: [
            .sample(title: "Many App Switches", weight: 0.5, observed: 30, contribution: 20),
            .sample(title: "Frequent Alerts", weight: 0.4, observed: 18, contribution: 15)
        ]
    )
}

extension TimelinePoint {
    static let sample: [TimelinePoint] = (0..<24).map { hour in
        let base = Int.random(in: 5...90)
        let interruptions = Int.random(in: 0...6)
        return TimelinePoint(hour: hour, score: base, interruptionCount: interruptions)
    }
}

extension WeeklyDriftPoint {
    static let sample: [WeeklyDriftPoint] = (0..<7).map { idx in
        let score = Int.random(in: 10...90)
        let deep = Int.random(in: 20...180)
        return WeeklyDriftPoint(dayIndex: idx, score: score, deepFocusMinutes: deep)
    }
}

extension DailySummary {
    static let sample = DailySummary(date: .now, score: .sampleHigh, timeline: TimelinePoint.sample)
}

extension WeeklySummary {
    static let sample = WeeklySummary(weekStart: .now, points: WeeklyDriftPoint.sample)
}
#endif

