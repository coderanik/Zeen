import SwiftUI

struct GlassCard<Content: View>: View {
    var delay: Double
    let content: Content

    @State private var appeared = false

    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), Color.white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 12)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .onAppear {
                withAnimation(ZeenTheme.springSmooth.delay(delay)) {
                    appeared = true
                }
            }
    }
}
