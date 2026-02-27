import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var session: SessionViewModel

    @State private var refreshBounce = false
    @State private var showBreathing = false
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greeting)
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundStyle(.white)
                        Text("Here's your attention snapshot")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                    }

                    // Hero Score
                    GlassCard(delay: 0.05) {
                        VStack(spacing: 16) {
                            ScoreRing(
                                score: viewModel.dailySummary.score.value,
                                label: viewModel.dailySummary.score.level.label,
                                emoji: viewModel.dailySummary.score.level.emoji
                            )
                            .frame(maxWidth: .infinity)

                            Text(viewModel.dailySummary.score.level.description)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)

                            // Action buttons
                            HStack(spacing: 12) {
                                // Share button
                                Button {
                                    generateAndShare()
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.caption)
                                        Text("Share")
                                            .font(.caption.weight(.medium))
                                    }
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.08))
                                    .clipShape(Capsule())
                                }

                                // Breathing reset (show when score is elevated)
                                if viewModel.dailySummary.score.value >= 40 {
                                    Button { showBreathing = true } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "wind")
                                                .font(.caption)
                                            Text("Breathe")
                                                .font(.caption.weight(.medium))
                                        }
                                        .foregroundStyle(ZeenTheme.accentMint)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(ZeenTheme.accentMint.opacity(0.10))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }

                    // Quick Stats
                    HStack(spacing: 12) {
                        StatCard(icon: "arrow.triangle.swap", value: "\(viewModel.totalAppSwitches)", label: "Switches", color: ZeenTheme.accentCyan, delay: 0.10)
                        StatCard(icon: "bell.badge", value: "\(viewModel.totalInterruptions)", label: "Interrupts", color: ZeenTheme.accentBlue, delay: 0.15)
                        StatCard(icon: "leaf", value: "\(viewModel.dailySummary.calmHourCount)", label: "Calm hrs", color: ZeenTheme.accentMint, delay: 0.20)
                    }

                    // Top Insight
                    if let insight = viewModel.insights.first {
                        InsightBanner(insight: insight, delay: 0.25)
                    }

                    // Factor Breakdown
                    GlassCard(delay: 0.30) {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("What drove today")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.96))

                            ForEach(Array(viewModel.dailySummary.score.factors.enumerated()), id: \.element.id) { i, factor in
                                FactorRow(
                                    factor: factor,
                                    maxContribution: viewModel.dailySummary.score.factors.map(\.contribution).max() ?? 1,
                                    animationDelay: 0.35 + Double(i) * 0.08
                                )
                            }
                        }
                    }

                    // Peak Drift
                    if let peak = viewModel.highestDriftPeriod {
                        GlassCard(delay: 0.55) {
                            HStack(spacing: 14) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Peak Drift Window")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Text(peak.hourLabel)
                                        .font(.title2.weight(.bold))
                                        .foregroundStyle(ZeenTheme.driftColor(for: peak.score))
                                    Text("\(peak.interruptionCount) interruptions")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.55))
                                }
                                Spacer()
                                ZStack {
                                    Circle()
                                        .fill(ZeenTheme.driftColor(for: peak.score).opacity(0.14))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "waveform.path.ecg")
                                        .font(.title2)
                                        .foregroundStyle(ZeenTheme.driftColor(for: peak.score))
                                        .symbolEffect(.pulse)
                                }
                            }
                        }
                    }

                    // More Insights
                    if viewModel.insights.count > 1 {
                        GlassCard(delay: 0.60) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("More Insights")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.96))

                                ForEach(Array(viewModel.insights.dropFirst().prefix(3))) { insight in
                                    HStack(spacing: 12) {
                                        Image(systemName: insight.icon)
                                            .font(.subheadline)
                                            .foregroundStyle(insight.tone.color)
                                            .frame(width: 28)
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(insight.title)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(.white.opacity(0.90))
                                            Text(insight.body)
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.50))
                                                .lineLimit(1)
                                        }
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.vertical, 2)
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
        .navigationTitle("Zeen")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let g = UIImpactFeedbackGenerator(style: .light)
                    g.impactOccurred()
                    refreshBounce.toggle()
                    withAnimation(ZeenTheme.springSmooth) {
                        viewModel.refresh(profile: session.profile)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                        .symbolEffect(.bounce, value: refreshBounce)
                }
                .foregroundStyle(.white.opacity(0.9))
            }
        }
        .fullScreenCover(isPresented: $showBreathing) {
            BreathingView()
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ShareSheetView(image: shareImage)
            }
        }
        .onAppear {
            viewModel.refresh(profile: session.profile)
        }
    }

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: .now)
        let n = session.profile?.firstName ?? "there"
        switch h {
        case 5..<12:  return "Good morning, \(n)"
        case 12..<17: return "Good afternoon, \(n)"
        case 17..<22: return "Good evening, \(n)"
        default:      return "Late night, \(n)?"
        }
    }

    private func generateAndShare() {
        let card = ScoreShareCard(
            score: viewModel.dailySummary.score,
            userName: session.profile?.firstName ?? "Zeen User",
            date: viewModel.dailySummary.date
        )
        if let image = card.renderUIImage() {
            shareImage = image
            showShareSheet = true
        }
    }
}

// MARK: - Share Sheet Wrapper
struct ShareSheetView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [image], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
