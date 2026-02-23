import SwiftUI

enum ZeenTheme {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.06, green: 0.10, blue: 0.16),
            Color(red: 0.03, green: 0.06, blue: 0.12),
            Color(red: 0.11, green: 0.18, blue: 0.24)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassStroke = Color.white.opacity(0.25)
    static let glassHighlight = Color.white.opacity(0.45)

    static let driftGradient = LinearGradient(
        colors: [
            Color(red: 0.20, green: 0.90, blue: 0.90),
            Color(red: 0.26, green: 0.57, blue: 1.0),
            Color(red: 0.35, green: 0.80, blue: 0.65)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func driftColor(for score: Int) -> Color {
        switch score {
        case 0..<25: return Color(red: 0.35, green: 0.90, blue: 0.70)
        case 25..<50: return Color(red: 0.92, green: 0.82, blue: 0.30)
        case 50..<75: return Color(red: 0.98, green: 0.58, blue: 0.32)
        default: return Color(red: 0.96, green: 0.36, blue: 0.40)
        }
    }
}

struct GlassBackground: View {
    var body: some View {
        ZStack {
            ZeenTheme.backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.cyan.opacity(0.15))
                .frame(width: 260, height: 260)
                .blur(radius: 12)
                .offset(x: -120, y: -260)

            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 280, height: 280)
                .blur(radius: 10)
                .offset(x: 120, y: 320)

            Circle()
                .fill(Color.mint.opacity(0.12))
                .frame(width: 180, height: 180)
                .blur(radius: 8)
                .offset(x: 140, y: -180)
        }
    }
}
