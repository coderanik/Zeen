import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var focusVM: FocusSessionViewModel

    @State private var appeared = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Progress header
                    GlassCard(delay: 0.05) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                                Circle()
                                    .trim(from: 0, to: appeared ? progressFraction : 0)
                                    .stroke(
                                        LinearGradient(
                                            colors: [ZeenTheme.accentCyan, ZeenTheme.accentMint],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeOut(duration: 1).delay(0.3), value: appeared)

                                VStack(spacing: 2) {
                                    Text("\(unlockedCount)")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Text("of \(achievements.count)")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.50))
                                }
                            }
                            .frame(width: 90, height: 90)

                            Text("Achievements Unlocked")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.70))
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Badge grid
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(achievements.enumerated()), id: \.element.id) { index, badge in
                            badgeCard(badge: badge, index: index)
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    // MARK: - Badge Card

    private func badgeCard(badge: Achievement, index: Int) -> some View {
        GlassCard(delay: 0.08 + Double(index) * 0.05) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(badge.isUnlocked ? badge.color.opacity(0.18) : Color.white.opacity(0.04))
                        .frame(width: 56, height: 56)

                    Image(systemName: badge.icon)
                        .font(.title2)
                        .foregroundStyle(badge.isUnlocked ? badge.color : .white.opacity(0.20))
                        .symbolEffect(.bounce, value: appeared && badge.isUnlocked)
                }

                Text(badge.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(badge.isUnlocked ? .white : .white.opacity(0.35))
                    .lineLimit(1)

                Text(badge.description)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(badge.isUnlocked ? 0.55 : 0.25))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                if badge.isUnlocked {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("Unlocked")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(badge.color)
                } else {
                    Text(badge.requirement)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.30))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.05))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Data

    private var achievements: [Achievement] {
        var list = Achievement.catalog

        // Check unlocks based on current state
        let weeklyAvg = viewModel.weeklySummary.averageScore
        let streak = viewModel.weeklySummary.currentCalmStreak(threshold: 40)
        let focusSessions = focusVM.sessions.count
        let completedSessions = focusVM.sessions.filter(\.completed).count

        // First calm
        if weeklyAvg < 30 || viewModel.dailySummary.score.value < 30 {
            if let i = list.firstIndex(where: { $0.id == "first_calm" }) {
                list[i].isUnlocked = true
                list[i].unlockedDate = .now
            }
        }

        // Streaks
        if streak >= 3 {
            if let i = list.firstIndex(where: { $0.id == "streak_3" }) {
                list[i].isUnlocked = true
            }
        }
        if streak >= 7 {
            if let i = list.firstIndex(where: { $0.id == "streak_7" }) {
                list[i].isUnlocked = true
            }
        }

        // Focus sessions
        if completedSessions >= 1 {
            if let i = list.firstIndex(where: { $0.id == "focus_first" }) {
                list[i].isUnlocked = true
            }
        }
        if completedSessions >= 10 {
            if let i = list.firstIndex(where: { $0.id == "focus_10" }) {
                list[i].isUnlocked = true
            }
        }

        // Time-based
        let h = Calendar.current.component(.hour, from: .now)
        if h < 8 {
            if let i = list.firstIndex(where: { $0.id == "early_bird" }) {
                list[i].isUnlocked = true
            }
        }

        // Perfect day
        let allCalm = viewModel.dailySummary.timeline.allSatisfy { $0.score < 30 }
        if allCalm && !viewModel.dailySummary.timeline.isEmpty {
            if let i = list.firstIndex(where: { $0.id == "perfect_day" }) {
                list[i].isUnlocked = true
            }
        }

        return list
    }

    private var unlockedCount: Int {
        achievements.filter(\.isUnlocked).count
    }

    private var progressFraction: CGFloat {
        guard !achievements.isEmpty else { return 0 }
        return CGFloat(unlockedCount) / CGFloat(achievements.count)
    }
}
