import Foundation

final class DriftScoringService {

    // MARK: - Scoring

    func score(input: DriftInput) -> DriftScore {
        let maxAppSwitches   = 40.0
        let maxShortSessions = 30.0
        let maxNotifications = 40.0
        let maxFocusBreaks   = 20.0

        let factors: [DriftFactor] = [
            {
                let n = min(Double(input.appSwitches) / maxAppSwitches, 1.0)
                return DriftFactor(title: "App Switching", weight: 0.35, observed: input.appSwitches, contribution: Int(n * 100 * 0.35))
            }(),
            {
                let n = min(Double(input.shortSessions) / maxShortSessions, 1.0)
                return DriftFactor(title: "Short Sessions", weight: 0.25, observed: input.shortSessions, contribution: Int(n * 100 * 0.25))
            }(),
            {
                let n = min(Double(input.notificationInterruptions) / maxNotifications, 1.0)
                return DriftFactor(title: "Notifications", weight: 0.25, observed: input.notificationInterruptions, contribution: Int(n * 100 * 0.25))
            }(),
            {
                let n = min(Double(input.focusBreaks) / maxFocusBreaks, 1.0)
                return DriftFactor(title: "Focus Breaks", weight: 0.15, observed: input.focusBreaks, contribution: Int(n * 100 * 0.15))
            }()
        ]

        let normalized = max(0, min(100, factors.map(\.contribution).reduce(0, +)))
        let level: DriftLevel
        switch normalized {
        case 0..<25:  level = .calm
        case 25..<50: level = .mild
        case 50..<75: level = .high
        default:      level = .overloaded
        }
        return DriftScore(value: normalized, level: level, factors: factors)
    }

    // MARK: - Insight Generation

    func generateInsights(daily: DailySummary, weekly: WeeklySummary, profile: UserProfile?) -> [DriftInsight] {
        var insights: [DriftInsight] = []
        let s = daily.score.value

        // Overall assessment
        if s < 25 {
            insights.append(.init(icon: "sparkles", title: "Exceptional focus", body: "Your cognitive drift is minimal today. Keep protecting these patterns.", tone: .positive))
        } else if s < 50 {
            insights.append(.init(icon: "brain.head.profile", title: "Mild fragmentation", body: "Some attention scattering, but still within a healthy range.", tone: .neutral))
        } else if s < 75 {
            insights.append(.init(icon: "exclamationmark.bubble", title: "Elevated drift", body: "Your attention is fragmenting. Consider a focus block.", tone: .warning))
        } else {
            insights.append(.init(icon: "bolt.trianglebadge.exclamationmark", title: "Cognitive overload", body: "High mental fatigue detected. Time for a reset.", tone: .critical))
        }

        // Top driver
        if let top = daily.score.factors.max(by: { $0.contribution < $1.contribution }) {
            insights.append(.init(icon: "arrow.up.right", title: "\(top.title) is your top driver", body: "\(top.observed) instances contributed +\(top.contribution) to your score.", tone: top.contribution > 15 ? .warning : .neutral))
        }

        // Calmest period
        if let calm = daily.mostCalmHour {
            insights.append(.init(icon: "leaf", title: "Calmest at \(calm.hourLabel)", body: "Score of \(calm.score) with \(calm.interruptionCount) interruptions.", tone: .positive))
        }

        // Goal tracking
        let avg = weekly.averageScore
        if let goal = profile?.goalAverageScore, avg < goal {
            insights.append(.init(icon: "target", title: "On track for your goal", body: "Weekly average of \(avg) is below your target of \(goal).", tone: .positive))
        } else if let goal = profile?.goalAverageScore, avg >= goal {
            insights.append(.init(icon: "exclamationmark.circle", title: "Above your goal", body: "Weekly average \(avg) exceeds your target of \(goal). Focus on reducing switches.", tone: .warning))
        }

        return insights
    }

    // MARK: - Trend Detection

    func trendDirection(for weekly: WeeklySummary) -> TrendDirection {
        let pts = weekly.points.sorted { $0.dayIndex < $1.dayIndex }
        guard pts.count >= 4 else { return .stable }
        let half = pts.count / 2
        let firstAvg = pts.prefix(half).map(\.score).reduce(0, +) / max(half, 1)
        let secondAvg = pts.suffix(half).map(\.score).reduce(0, +) / max(half, 1)
        let diff = secondAvg - firstAvg
        if diff < -5 { return .improving }
        if diff > 5  { return .worsening }
        return .stable
    }
}
