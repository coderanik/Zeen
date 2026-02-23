import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    GlassCard {
                        VStack(spacing: 14) {
                            ScoreRing(
                                score: viewModel.dailySummary.score.value,
                                label: viewModel.dailySummary.score.level.label
                            )
                            .frame(maxWidth: .infinity)

                            Text("Your score reflects attention fragmentation, not total screen time.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.75))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What drove today")
                                .font(.headline)
                                .foregroundStyle(.white)

                            ForEach(viewModel.dailySummary.score.factors) { factor in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(factor.title)
                                            .foregroundStyle(.white)
                                        Text("Observed: \(factor.observed)")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.68))
                                    }
                                    Spacer()
                                    Text("+\(factor.contribution)")
                                        .font(.headline)
                                        .foregroundStyle(ZeenTheme.driftColor(for: factor.contribution))
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    if let peak = viewModel.highestDriftPeriod {
                        GlassCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Peak Drift Window")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text("\(peak.hourLabel) - score \(peak.score)")
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "waveform.path.ecg")
                                    .font(.title2)
                                    .foregroundStyle(ZeenTheme.driftColor(for: peak.score))
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Zeen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Refresh") {
                    viewModel.refresh()
                }
                .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Cognitive Drift")
                .font(.title.bold())
                .foregroundStyle(.white)
            Text("Understand why your mind feels fragmented.")
                .foregroundStyle(.white.opacity(0.76))
        }
    }
}
