import SwiftUI

struct InsightBanner: View {
    let insight: DriftInsight
    var delay: Double = 0

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(insight.tone.color.opacity(0.14))
                    .frame(width: 42, height: 42)
                Image(systemName: insight.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(insight.tone.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(insight.body)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.60))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(insight.tone.color.opacity(0.20), lineWidth: 0.6)
        )
        .shadow(color: .black.opacity(0.20), radius: 12, x: 0, y: 8)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .onAppear {
            withAnimation(ZeenTheme.springSmooth.delay(delay)) {
                appeared = true
            }
        }
    }
}
