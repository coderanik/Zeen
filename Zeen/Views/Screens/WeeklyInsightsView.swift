import SwiftUI
import Charts

struct WeeklyInsightsView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Drift Pattern")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("Average score: \(viewModel.weeklySummary.averageScore)")
                                .foregroundStyle(.white.opacity(0.84))
                        }
                    }

                    GlassCard {
                        Chart(viewModel.weeklySummary.points) { point in
                            LineMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Score", point.score)
                            )
                            .lineStyle(.init(lineWidth: 3, lineCap: .round))
                            .foregroundStyle(ZeenTheme.driftGradient)

                            AreaMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.33), Color.blue.opacity(0.06)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            PointMark(
                                x: .value("Day", point.dayLabel),
                                y: .value("Score", point.score)
                            )
                            .foregroundStyle(.white)
                        }
                        .chartYScale(domain: 0...100)
                        .chartYAxis {
                            AxisMarks(position: .leading)
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic)
                        }
                        .frame(height: 220)
                        .tint(.white)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Deep Focus")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("\(viewModel.weeklySummary.totalDeepFocusMinutes) min this week")
                                .font(.title2.bold())
                                .foregroundStyle(.white)
                            Text("Lower drift days generally align with longer uninterrupted focus blocks.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.74))
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Weekly")
    }
}
