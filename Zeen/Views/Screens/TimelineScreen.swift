import SwiftUI

struct TimelineScreen: View {
    @EnvironmentObject private var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Fragmentation Timeline")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("Spikes show periods where rapid switches and interruptions likely increased mental fatigue.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.72))
                        }
                    }

                    GlassCard {
                        let points = viewModel.dailySummary.timeline
                        let maxScore = max(points.map(\.score).max() ?? 100, 1)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 14) {
                                ForEach(points) { point in
                                    TimelineBar(point: point, maxScore: maxScore)
                                }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 4)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Attention Notes")
                                .font(.headline)
                                .foregroundStyle(.white)

                            ForEach(Array(viewModel.dailySummary.timeline.prefix(3).enumerated()), id: \.offset) { entry in
                                let point = entry.element
                                HStack(alignment: .top) {
                                    Circle()
                                        .fill(ZeenTheme.driftColor(for: point.score))
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 5)

                                    Text("\(point.hourLabel): score \(point.score), interruptions \(point.interruptionCount)")
                                        .foregroundStyle(.white.opacity(0.86))
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Timeline")
    }
}
