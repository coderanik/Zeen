import SwiftUI

struct TimelineBar: View {
    let point: TimelinePoint
    let maxScore: Int

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 20, height: 132)

                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(ZeenTheme.driftColor(for: point.score))
                    .frame(width: 20, height: CGFloat(point.score) / CGFloat(maxScore) * 132)
            }

            Text(point.hourLabel)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.78))
        }
    }
}
