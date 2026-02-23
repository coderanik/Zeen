import SwiftUI

struct ScoreRing: View {
    let score: Int
    let label: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.18), lineWidth: 14)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    ZeenTheme.driftGradient,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: ZeenTheme.driftColor(for: score).opacity(0.45), radius: 10, x: 0, y: 0)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.86))
            }
        }
        .frame(width: 180, height: 180)
    }
}
