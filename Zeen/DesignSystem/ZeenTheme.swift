import SwiftUI

enum ZeenTheme {
    // MARK: - Accent Palette
    static let accentCyan = Color(red: 0.20, green: 0.90, blue: 0.90)
    static let accentBlue = Color(red: 0.26, green: 0.57, blue: 1.0)
    static let accentMint = Color(red: 0.35, green: 0.80, blue: 0.65)

    // MARK: - Gradients
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.06, blue: 0.14),
            Color(red: 0.01, green: 0.02, blue: 0.06),
            Color(red: 0.06, green: 0.10, blue: 0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let driftGradient = LinearGradient(
        colors: [accentCyan, accentBlue, accentMint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ctaGradient = LinearGradient(
        colors: [accentCyan, accentBlue],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Score Color
    static func driftColor(for score: Int) -> Color {
        switch score {
        case 0..<25:  return Color(red: 0.35, green: 0.90, blue: 0.70)
        case 25..<50: return Color(red: 0.92, green: 0.82, blue: 0.30)
        case 50..<75: return Color(red: 0.98, green: 0.58, blue: 0.32)
        default:      return Color(red: 0.96, green: 0.36, blue: 0.40)
        }
    }

    // MARK: - Animation Presets
    static let springSnappy = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let springSmooth = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
}

// MARK: - Animated Glass Background
struct GlassBackground: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            ZeenTheme.backgroundGradient.ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.16))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: drift ? -100 : -140, y: drift ? -280 : -240)

            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: drift ? 120 : 160, y: drift ? 340 : 300)

            Circle()
                .fill(Color.mint.opacity(0.12))
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .offset(x: drift ? 140 : 180, y: drift ? -220 : -180)

            Circle()
                .fill(Color.purple.opacity(0.09))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: drift ? -80 : -40, y: drift ? 160 : 200)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
