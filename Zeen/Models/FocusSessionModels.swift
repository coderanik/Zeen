import Foundation
import SwiftUI

enum FocusSessionType: String, CaseIterable, Identifiable {
    case deepWork = "Deep Work"
    case reading = "Reading"
    case creative = "Creative"
    case meditation = "Meditation"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .deepWork:   return "brain"
        case .reading:    return "book"
        case .creative:   return "paintbrush"
        case .meditation: return "leaf"
        }
    }

    var color: Color {
        switch self {
        case .deepWork:   return Color(red: 0.20, green: 0.90, blue: 0.90)
        case .reading:    return Color(red: 0.26, green: 0.57, blue: 1.0)
        case .creative:   return Color(red: 0.98, green: 0.58, blue: 0.32)
        case .meditation: return Color(red: 0.35, green: 0.80, blue: 0.65)
        }
    }

    var defaultMinutes: Int {
        switch self {
        case .deepWork:   return 25
        case .reading:    return 20
        case .creative:   return 30
        case .meditation: return 10
        }
    }

    var defaultDuration: TimeInterval { TimeInterval(defaultMinutes * 60) }

    var gradient: LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct FocusSessionRecord: Identifiable, Equatable {
    let id = UUID()
    let type: FocusSessionType
    let elapsed: TimeInterval
    let target: TimeInterval
    let completedAt: Date
    let completed: Bool

    var elapsedLabel: String {
        let m = Int(elapsed) / 60
        let s = Int(elapsed) % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

enum FocusSessionState: Equatable {
    case idle, running, paused
}
