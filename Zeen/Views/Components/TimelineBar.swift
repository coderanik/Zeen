import SwiftUI

struct TimelineBar: View {
    let point: TimelinePoint
    let maxScore: Int

    @State private var grown = false

    var body: some View {
        VStack(spacing: 6) {
            Text("\(point.score)")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
                .opacity(grown ? 1 : 0)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 22, height: 120)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [point.accentColor, point.accentColor.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 22, height: grown ? CGFloat(point.score) / CGFloat(max(maxScore, 1)) * 120 : 0)
                    .shadow(color: point.accentColor.opacity(0.35), radius: 6, y: -2)
            }

            Text(point.hourLabel)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
        }
        .onAppear {
            withAnimation(ZeenTheme.springSmooth.delay(Double(point.hour % 24) * 0.03)) {
                grown = true
            }
        }
    }
}
