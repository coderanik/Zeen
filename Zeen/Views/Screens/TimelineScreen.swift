import SwiftUI
import Charts

struct TimelineScreen: View {
    @EnvironmentObject private var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    GlassCard(delay: 0.05) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Fragmentation Timeline")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("Spikes show periods of rapid context switching and attention fragmentation.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.60))
                        }
                    }

                    // Charts visualization
                    GlassCard(delay: 0.12) {
                        let points = viewModel.dailySummary.timeline

                        Chart(points) { point in
                            AreaMark(
                                x: .value("Hour", point.hourLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [ZeenTheme.accentCyan.opacity(0.35), ZeenTheme.accentBlue.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .interpolationMethod(.catmullRom)

                            LineMark(
                                x: .value("Hour", point.hourLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(ZeenTheme.accentCyan)
                            .lineStyle(.init(lineWidth: 2.5, lineCap: .round))
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Hour", point.hourLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(point.accentColor)
                            .symbolSize(point.score > 50 ? 40 : 20)
                        }
                        .chartYScale(domain: 0...100)
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel()
                                    .foregroundStyle(.white.opacity(0.45))
                                AxisGridLine()
                                    .foregroundStyle(.white.opacity(0.06))
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic) { value in
                                AxisValueLabel()
                                    .foregroundStyle(.white.opacity(0.45))
                            }
                        }
                        .frame(height: 220)
                    }

                    // Bar visualization
                    GlassCard(delay: 0.20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Hourly Breakdown")
                                .font(.headline)
                                .foregroundStyle(.white)

                            let points = viewModel.dailySummary.timeline
                            let maxScore = max(points.map(\.score).max() ?? 100, 1)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .bottom, spacing: 10) {
                                    ForEach(points) { point in
                                        TimelineBar(point: point, maxScore: maxScore)
                                    }
                                }
                                .padding(.vertical, 6)
                                .padding(.horizontal, 4)
                            }
                        }
                    }

                    // Attention Notes
                    GlassCard(delay: 0.28) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Attention Notes")
                                .font(.headline)
                                .foregroundStyle(.white)

                            let top3 = viewModel.dailySummary.timeline
                                .sorted { $0.score > $1.score }
                                .prefix(3)

                            ForEach(Array(top3.enumerated()), id: \.element.id) { _, point in
                                HStack(alignment: .top, spacing: 10) {
                                    Circle()
                                        .fill(ZeenTheme.driftColor(for: point.score))
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 5)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(point.hourLabel) — Score \(point.score)")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.white.opacity(0.90))
                                        Text("\(point.interruptionCount) interruptions during this period")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.50))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Timeline")
    }
}
