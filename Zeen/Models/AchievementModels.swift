import Foundation
import SwiftUI

struct Achievement: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requirement: String
    var isUnlocked: Bool = false
    var unlockedDate: Date? = nil

    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id && lhs.isUnlocked == rhs.isUnlocked
    }

    static let catalog: [Achievement] = [
        Achievement(id: "first_calm", title: "Inner Peace",
                    description: "Score below 30 for the first time",
                    icon: "leaf.fill", color: Color(red: 0.35, green: 0.80, blue: 0.65),
                    requirement: "Score < 30"),

        Achievement(id: "streak_3", title: "Momentum",
                    description: "Maintain a 3-day calm streak",
                    icon: "flame.fill", color: .orange,
                    requirement: "3-day streak"),

        Achievement(id: "streak_7", title: "Unstoppable",
                    description: "7 calm days in a row",
                    icon: "bolt.fill", color: .yellow,
                    requirement: "7-day streak"),

        Achievement(id: "focus_first", title: "Deep Diver",
                    description: "Complete your first focus session",
                    icon: "timer", color: Color(red: 0.20, green: 0.90, blue: 0.90),
                    requirement: "1 focus session"),

        Achievement(id: "focus_10", title: "Focus Master",
                    description: "Complete 10 focus sessions",
                    icon: "crown.fill", color: .purple,
                    requirement: "10 sessions"),

        Achievement(id: "breathe", title: "Zen Master",
                    description: "Complete a breathing exercise",
                    icon: "wind", color: Color(red: 0.26, green: 0.57, blue: 1.0),
                    requirement: "1 breathing"),

        Achievement(id: "early_bird", title: "Early Bird",
                    description: "Check your score before 8 AM",
                    icon: "sunrise.fill", color: .orange,
                    requirement: "Open < 8 AM"),

        Achievement(id: "perfect_day", title: "Perfect Day",
                    description: "Stay in Calm zone all day",
                    icon: "star.fill", color: .yellow,
                    requirement: "All hours < 30"),
    ]
}

// MARK: - Daily Record for Calendar

struct DailyRecord: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let score: Int

    var level: DriftLevel {
        switch score {
        case 0..<30:   return .calm
        case 30..<55:  return .mild
        case 55..<75:  return .high
        default:       return .overloaded
        }
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: date)
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: date) - 1 // 0 = Sunday
    }
}
