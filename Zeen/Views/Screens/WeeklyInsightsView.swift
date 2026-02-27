import SwiftUI
import Charts

struct WeeklyInsightsView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    // Summary + Trend
                    GlassCard(delay: 0.05) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Weekly Drift Pattern")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                                trendBadge
                            }

                            Text("Average score: \(viewModel.weeklySummary.averageScore)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)

                            let goal = session.profile?.goalAverageScore ?? 40
                            let calm = viewModel.weeklySummary.calmDayCount(threshold: goal)
                            let streak = viewModel.weeklySummary.currentCalmStreak(threshold: goal)

                            HStack(spacing: 16) {
                                miniStat(icon: "leaf", value: "\(calm)/7", label: "Calm days")
                                if streak > 0 {
                                    miniStat(icon: "flame", value: "\(streak)", label: "Day streak")
                                }
                                miniStat(icon: "target", value: "<\(goal)", label: "Goal")
                            }
                        }
                    }

                    // Chart
                    GlassCard(delay: 0.12) {
                        Chart(viewModel.weeklySummary.points) { point in
                            AreaMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ZeenTheme.accentCyan.opacity(0.30), ZeenTheme.accentBlue.opacity(0.04)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)

                            LineMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Score", point.score)
                            )
                            .lineStyle(.init(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(ZeenTheme.ctaGradient)
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(.white)
                            .symbolSize(30)
                        }
                        .chartYScale(domain: 0...100)
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisValueLabel().foregroundStyle(.white.opacity(0.45))
                                AxisGridLine().foregroundStyle(.white.opacity(0.06))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { _ in
                                AxisValueLabel().foregroundStyle(.white.opacity(0.55))
                            }
                        }
                        .frame(height: 220)
                    }

                    // Deep Focus stats
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "brain",
                            value: "\(viewModel.weeklySummary.totalDeepFocusMinutes)",
                            label: "Focus min",
                            color: ZeenTheme.accentMint,
                            delay: 0.20
                        )
                        StatCard(
                            icon: "arrow.down.right",
                            value: bestDayLabel,
                            label: "Best day",
                            color: ZeenTheme.accentCyan,
                            delay: 0.25
                        )
                    }

                    // Deep Focus detail
                    GlassCard(delay: 0.30) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Deep Focus")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(viewModel.weeklySummary.totalDeepFocusMinutes) minutes this week")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)

                            // Focus by day
                            ForEach(viewModel.weeklySummary.points) { point in
                                HStack {
                                    Text(point.dayLabel)
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.70))
                                        .frame(width: 36, alignment: .leading)

                                    GeometryReader { geo in
                                        let maxFocus = max(viewModel.weeklySummary.points.map(\.deepFocusMinutes).max() ?? 1, 1)
                                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                                            .fill(ZeenTheme.accentMint.opacity(0.50))
                                            .frame(width: geo.size.width * CGFloat(point.deepFocusMinutes) / CGFloat(maxFocus), height: 8)
                                    }
                                    .frame(height: 8)

                                    Text(point.deepFocusLabel)
                                        .font(.caption.monospacedDigit())
                                        .foregroundStyle(.white.opacity(0.55))
                                        .frame(width: 50, alignment: .trailing)
                                }
                            }

                            Text("Lower drift days generally align with longer uninterrupted focus blocks.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.50))
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Weekly")
    }

    private var trendBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: viewModel.trend.icon)
                .font(.caption.weight(.bold))
            Text(viewModel.trend.label)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(viewModel.trend.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(viewModel.trend.color.opacity(0.12))
        .clipShape(Capsule())
    }

    private func miniStat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(ZeenTheme.accentCyan)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(.white)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.50))
            }
        }
    }

    private var bestDayLabel: String {
        viewModel.weeklySummary.points.min(by: { $0.score < $1.score })?.dayLabel ?? "—"
    }
}
