import SwiftUI

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var delay: Double = 0

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.weight(.bold).monospacedDigit())
                .foregroundStyle(.white)

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(color.opacity(0.18), lineWidth: 0.6)
        )
        .shadow(color: .black.opacity(0.18), radius: 10, x: 0, y: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(value) \(label)")
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .onAppear {
            withAnimation(ZeenTheme.springSmooth.delay(delay)) {
                appeared = true
            }
        }
    }
}
