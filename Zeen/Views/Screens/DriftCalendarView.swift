import SwiftUI

struct DriftCalendarView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel

    @State private var appeared = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Legend
                    GlassCard(delay: 0.05) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("30-Day Drift Map")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.96))

                            Text("Each cell represents one day. Color intensity indicates drift severity.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.50))

                            HStack(spacing: 4) {
                                legendDot(label: "Calm", level: .calm)
                                Spacer()
                                legendDot(label: "Mild", level: .mild)
                                Spacer()
                                legendDot(label: "High", level: .high)
                                Spacer()
                                legendDot(label: "Overloaded", level: .overloaded)
                            }
                        }
                    }

                    // Calendar grid
                    GlassCard(delay: 0.12) {
                        VStack(spacing: 8) {
                            // Weekday headers
                            LazyVGrid(columns: columns, spacing: 4) {
                                ForEach(weekdays, id: \.self) { day in
                                    Text(day)
                                        .font(.caption2.weight(.medium))
                                        .foregroundStyle(.white.opacity(0.40))
                                        .frame(height: 20)
                                }
                            }

                            // Day cells
                            LazyVGrid(columns: columns, spacing: 4) {
                                // Leading empty cells for alignment
                                ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                                    Color.clear
                                        .frame(height: 38)
                                }

                                ForEach(Array(historicalData.enumerated()), id: \.element.id) { index, record in
                                    dayCell(record: record, index: index)
                                }
                            }
                        }
                    }

                    // Monthly stats
                    GlassCard(delay: 0.22) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Month Summary")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.96))

                            HStack(spacing: 12) {
                                monthStat(
                                    value: "\(historicalData.filter { $0.level == .calm }.count)",
                                    label: "Calm Days",
                                    color: DriftLevel.calm.color
                                )
                                monthStat(
                                    value: "\(averageScore)",
                                    label: "Avg Score",
                                    color: ZeenTheme.accentCyan
                                )
                                monthStat(
                                    value: "\(bestStreak)",
                                    label: "Best Streak",
                                    color: .orange
                                )
                                monthStat(
                                    value: "\(historicalData.filter { $0.level == .overloaded }.count)",
                                    label: "Hard Days",
                                    color: DriftLevel.overloaded.color
                                )
                            }
                        }
                    }

                    // Distribution bars
                    GlassCard(delay: 0.30) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Distribution")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.96))

                            ForEach(DriftLevel.allCases, id: \.self) { level in
                                distributionRow(level: level)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                appeared = true
            }
        }
    }

    // MARK: - Components

    private func dayCell(record: DailyRecord, index: Int) -> some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(record.level.color.opacity(appeared ? cellOpacity(for: record) : 0))
                .frame(height: 38)
                .overlay(
                    VStack(spacing: 1) {
                        Text("\(record.dayOfMonth)")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.70))
                        Text("\(record.score)")
                            .font(.system(size: 8, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.45))
                    }
                )
                .animation(
                    .easeOut(duration: 0.4).delay(Double(index) * 0.03),
                    value: appeared
                )
        }
    }

    private func cellOpacity(for record: DailyRecord) -> Double {
        switch record.level {
        case .calm:       return 0.35
        case .mild:       return 0.50
        case .high:       return 0.70
        case .overloaded: return 0.90
        }
    }

    private func legendDot(label: String, level: DriftLevel) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(level.color.opacity(0.65))
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.55))
        }
    }

    private func monthStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.50))
        }
        .frame(maxWidth: .infinity)
    }

    private func distributionRow(level: DriftLevel) -> some View {
        let count = historicalData.filter { $0.level == level }.count
        let fraction = historicalData.isEmpty ? 0 : CGFloat(count) / CGFloat(historicalData.count)

        return HStack(spacing: 10) {
            Text(level.emoji)
                .font(.caption)
                .frame(width: 20)
            Text(level.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.70))
                .frame(width: 70, alignment: .leading)

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(level.color.opacity(0.50))
                    .frame(width: appeared ? geo.size.width * fraction : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: appeared)
            }
            .frame(height: 14)

            Text("\(count)")
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(.white.opacity(0.55))
                .frame(width: 20, alignment: .trailing)
        }
    }

    // MARK: - Data

    private var historicalData: [DailyRecord] {
        LiveDataProvider().historicalRecords(days: 30)
    }

    private var leadingEmptyCells: Int {
        guard let first = historicalData.first else { return 0 }
        return first.weekday
    }

    private var averageScore: Int {
        guard !historicalData.isEmpty else { return 0 }
        return historicalData.map(\.score).reduce(0, +) / historicalData.count
    }

    private var bestStreak: Int {
        var maxStreak = 0, current = 0
        for r in historicalData {
            if r.level == .calm { current += 1; maxStreak = max(maxStreak, current) }
            else { current = 0 }
        }
        return maxStreak
    }
}
