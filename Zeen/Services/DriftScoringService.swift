import Foundation

final class DriftScoringService {
    func score(input: DriftInput) -> DriftScore {
        let weighted = [
            DriftFactor(title: "App Switching", weight: 0.35, observed: input.appSwitches, contribution: Int(Double(input.appSwitches) * 1.9)),
            DriftFactor(title: "Short Sessions", weight: 0.25, observed: input.shortSessions, contribution: Int(Double(input.shortSessions) * 1.4)),
            DriftFactor(title: "Notifications", weight: 0.25, observed: input.notificationInterruptions, contribution: Int(Double(input.notificationInterruptions) * 2.1)),
            DriftFactor(title: "Focus Breaks", weight: 0.15, observed: input.focusBreaks, contribution: Int(Double(input.focusBreaks) * 2.8))
        ]

        let rawScore = weighted.map(\.contribution).reduce(0, +)
        let normalized = max(0, min(100, rawScore))
        let level: DriftLevel

        switch normalized {
        case 0..<25:
            level = .calm
        case 25..<50:
            level = .mild
        case 50..<75:
            level = .high
        default:
            level = .overloaded
        }

        return DriftScore(value: normalized, level: level, factors: weighted)
    }
}
