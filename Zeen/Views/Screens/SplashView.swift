import SwiftUI

struct SplashView: View {
    @State private var showLogo = false
    @State private var showTitle = false
    @State private var showTag = false
    @State private var ringScale: CGFloat = 0.3
    @State private var ringOpacity: Double = 0
    @State private var glow = false

    var body: some View {
        ZStack {
            GlassBackground()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [ZeenTheme.accentCyan, ZeenTheme.accentBlue, ZeenTheme.accentMint, ZeenTheme.accentCyan],
                                center: .center
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .shadow(color: ZeenTheme.accentCyan.opacity(glow ? 0.5 : 0.15), radius: glow ? 22 : 8)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(ZeenTheme.ctaGradient)
                        .scaleEffect(showLogo ? 1 : 0.4)
                        .opacity(showLogo ? 1 : 0)
                }

                VStack(spacing: 8) {
                    Text("Zeen")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .opacity(showTitle ? 1 : 0)
                        .offset(y: showTitle ? 0 : 14)

                    Text("Find your focus baseline")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.60))
                        .opacity(showTag ? 1 : 0)
                        .offset(y: showTag ? 0 : 8)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.15)) {
                ringScale = 1.0
                ringOpacity = 1.0
                showLogo = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4)) {
                showTitle = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.7)) {
                showTag = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(1.0)) {
                glow = true
            }
        }
    }
}
