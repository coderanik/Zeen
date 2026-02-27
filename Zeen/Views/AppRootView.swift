import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var session: SessionViewModel

    @State private var phase: Phase = .splash

    private enum Phase: Equatable {
        case splash, auth, main
    }

    var body: some View {
        ZStack {
            switch phase {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .auth:
                AuthView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            case .main:
                RootTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: phase)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                phase = session.isAuthenticated ? .main : .auth
            }
        }
        .onChange(of: session.isAuthenticated) { _, isAuth in
            withAnimation(.easeInOut(duration: 0.5)) {
                phase = isAuth ? .main : .auth
            }
        }
    }
}
