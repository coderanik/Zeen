import SwiftUI

struct ScoreRing: View {
    let score: Int
    let label: String
    let emoji: String

    @State private var progress: CGFloat = 0
    @State private var displayedScore: Int = 0
    @State private var pulseGlow = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 16)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [ZeenTheme.accentCyan, ZeenTheme.accentBlue, ZeenTheme.accentMint, ZeenTheme.accentCyan],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: ZeenTheme.driftColor(for: score).opacity(0.50), radius: 14)

            // Glow endpoint
            Circle()
                .fill(.white)
                .frame(width: 6, height: 6)
                .shadow(color: .white.opacity(0.9), radius: 6)
                .offset(y: -96)
                .rotationEffect(.degrees(Double(progress) * 360))
                .opacity(progress > 0.02 ? 1 : 0)

            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 26))

                Text("\(displayedScore)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(value: Double(displayedScore)))

                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.78))
            }
        }
        .frame(width: 200, height: 200)
        .shadow(color: ZeenTheme.driftColor(for: score).opacity(pulseGlow ? 0.40 : 0.15), radius: pulseGlow ? 32 : 14)
        .onAppear { animate() }
    }

    private func animate() {
        withAnimation(.easeOut(duration: 1.2)) {
            progress = CGFloat(score) / 100
        }
        let steps = 30
        let interval = 1.0 / Double(steps)
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                withAnimation(.linear(duration: interval)) {
                    displayedScore = Int(Double(score) * Double(i) / Double(steps))
                }
            }
        }
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.2)) {
            pulseGlow = true
        }
    }
}
