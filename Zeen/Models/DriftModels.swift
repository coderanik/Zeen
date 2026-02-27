import Foundation
import SwiftUI

// MARK: - Core Scoring Types

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
    var accessibilityLabel: String { "Drift score \(value), \(level.label)" }
}

enum DriftLevel: String, CaseIterable, Equatable {
    case calm, mild, high, overloaded

    var label: String {
        switch self {
        case .calm:       return "In Flow"
        case .mild:       return "Mild Drift"
        case .high:       return "High Drift"
        case .overloaded: return "Overloaded"
        }
    }

    var description: String {
        switch self {
        case .calm:       return "Your attention is steady and protected."
        case .mild:       return "Some scattering, but you're staying grounded."
        case .high:       return "Frequent context switches are fragmenting your focus."
        case .overloaded: return "Your cognitive bandwidth is stretched thin."
        }
    }

    var emoji: String {
        switch self {
        case .calm:       return "🧘"
        case .mild:       return "🌤"
        case .high:       return "🌪️"
        case .overloaded: return "🔥"
        }
    }

    var symbolName: String {
        switch self {
        case .calm:       return "leaf"
        case .mild:       return "wind"
        case .high:       return "tornado"
        case .overloaded: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .calm:       return Color(red: 0.35, green: 0.90, blue: 0.70)
        case .mild:       return Color(red: 0.92, green: 0.82, blue: 0.30)
        case .high:       return Color(red: 0.98, green: 0.58, blue: 0.32)
        case .overloaded: return Color(red: 0.96, green: 0.36, blue: 0.40)
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .calm:
            return LinearGradient(colors: [Color(red: 0.35, green: 0.90, blue: 0.70).opacity(0.7), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mild:
            return LinearGradient(colors: [Color(red: 0.92, green: 0.82, blue: 0.30).opacity(0.8), Color.orange.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .high:
            return LinearGradient(colors: [Color.orange, Color(red: 0.96, green: 0.36, blue: 0.40).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .overloaded:
            return LinearGradient(colors: [Color(red: 0.96, green: 0.36, blue: 0.40), Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
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

struct ZeenPreferences: Equatable {
    var analysisOnDeviceOnly: Bool = true
    var useFocusIntegration: Bool = true
    var useNotificationsSignal: Bool = true
}

// MARK: - Timeline & Weekly

struct TimelinePoint: Identifiable, Equatable {
    let id = UUID()
    let hour: Int
    let score: Int
    let interruptionCount: Int

    var hourLabel: String {
        let n = hour % 24
        if n == 0  { return "12a" }
        if n < 12  { return "\(n)a" }
        if n == 12 { return "12p" }
        return "\(n - 12)p"
    }

    var accentColor: Color { ZeenTheme.driftColor(for: score) }
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

    var calmHourCount: Int { timeline.filter { $0.score < 40 }.count }

    var mostCalmHour: TimelinePoint? {
        timeline.min(by: { $0.score < $1.score })
    }
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

    func calmDayCount(threshold: Int) -> Int {
        points.filter { $0.score < threshold }.count
    }

    func currentCalmStreak(threshold: Int) -> Int {
        guard !points.isEmpty else { return 0 }
        let sorted = points.sorted { $0.dayIndex > $1.dayIndex }
        var streak = 0
        for point in sorted {
            if point.score < threshold { streak += 1 } else { break }
        }
        return streak
    }
}

// MARK: - Insights & Trends

struct DriftInsight: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let body: String
    let tone: InsightTone

    enum InsightTone: String, Equatable {
        case positive, neutral, warning, critical

        var color: Color {
            switch self {
            case .positive: return Color(red: 0.35, green: 0.90, blue: 0.70)
            case .neutral:  return Color(red: 0.20, green: 0.90, blue: 0.90)
            case .warning:  return Color(red: 0.98, green: 0.58, blue: 0.32)
            case .critical: return Color(red: 0.96, green: 0.36, blue: 0.40)
            }
        }
    }
}

enum TrendDirection: String, Equatable {
    case improving, stable, worsening

    var label: String {
        switch self {
        case .improving: return "Improving"
        case .stable:    return "Stable"
        case .worsening: return "Worsening"
        }
    }

    var icon: String {
        switch self {
        case .improving: return "arrow.down.right"
        case .stable:    return "arrow.right"
        case .worsening: return "arrow.up.right"
        }
    }

    var color: Color {
        switch self {
        case .improving: return Color(red: 0.35, green: 0.90, blue: 0.70)
        case .stable:    return Color(red: 0.20, green: 0.90, blue: 0.90)
        case .worsening: return Color(red: 0.96, green: 0.36, blue: 0.40)
        }
    }
}

// MARK: - Sample Data

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
        value: 18, level: .calm,
        factors: [
            .sample(title: "Few Notifications", weight: 0.3, observed: 2, contribution: -5),
            .sample(title: "Long Sessions", weight: 0.4, observed: 5, contribution: -7)
        ]
    )
    static let sampleHigh = DriftScore(
        value: 72, level: .high,
        factors: [
            .sample(title: "Many App Switches", weight: 0.5, observed: 30, contribution: 20),
            .sample(title: "Frequent Alerts", weight: 0.4, observed: 18, contribution: 15)
        ]
    )
}

extension TimelinePoint {
    static let sample: [TimelinePoint] = (0..<24).map { hour in
        TimelinePoint(hour: hour, score: Int.random(in: 5...90), interruptionCount: Int.random(in: 0...6))
    }
}

extension WeeklyDriftPoint {
    static let sample: [WeeklyDriftPoint] = (0..<7).map { idx in
        WeeklyDriftPoint(dayIndex: idx, score: Int.random(in: 10...90), deepFocusMinutes: Int.random(in: 20...180))
    }
}

extension DailySummary {
    static let sample = DailySummary(date: .now, score: .sampleHigh, timeline: TimelinePoint.sample)
}

extension WeeklySummary {
    static let sample = WeeklySummary(weekStart: .now, points: WeeklyDriftPoint.sample)
}
#endif
