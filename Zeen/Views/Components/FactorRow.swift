import SwiftUI

struct FactorRow: View {
    let factor: DriftFactor
    let maxContribution: Int
    var animationDelay: Double = 0

    @State private var barWidth: CGFloat = 0

    private var fraction: CGFloat {
        guard maxContribution > 0 else { return 0 }
        return CGFloat(factor.contribution) / CGFloat(maxContribution)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(factor.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.90))

                Spacer()

                Text("+\(factor.contribution)")
                    .font(.subheadline.weight(.bold).monospacedDigit())
                    .foregroundStyle(ZeenTheme.driftColor(for: factor.contribution * 3))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [ZeenTheme.accentCyan, ZeenTheme.driftColor(for: factor.contribution * 3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: barWidth, height: 6)
                        .shadow(color: ZeenTheme.driftColor(for: factor.contribution * 3).opacity(0.4), radius: 4, y: 1)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8).delay(animationDelay)) {
                        barWidth = geo.size.width * fraction
                    }
                }
            }
            .frame(height: 6)

            HStack {
                Text("Observed: \(factor.observed)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
                Spacer()
                Text("Weight: \(Int(factor.weight * 100))%")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(.vertical, 4)
    }
}
