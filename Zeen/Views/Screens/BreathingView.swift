import SwiftUI

struct BreathingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var phase: BreathPhase = .ready
    @State private var circleScale: CGFloat = 0.35
    @State private var cyclesCompleted = 0
    @State private var isActive = false

    private let totalCycles = 4

    enum BreathPhase: String {
        case ready = "Ready?"
        case breatheIn = "Breathe In"
        case hold = "Hold"
        case breatheOut = "Breathe Out"
        case complete = "Well Done"

        var color: Color {
            switch self {
            case .breatheIn:       return Color(red: 0.20, green: 0.90, blue: 0.90)
            case .hold:            return Color(red: 0.26, green: 0.57, blue: 1.0)
            case .breatheOut:      return Color(red: 0.35, green: 0.80, blue: 0.65)
            case .ready, .complete: return .white
            }
        }
    }

    var body: some View {
        ZStack {
            GlassBackground()

            VStack(spacing: 0) {
                // Close
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .frame(width: 34, height: 34)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                // Phase label
                VStack(spacing: 8) {
                    Text(phase.rawValue)
                        .font(.system(.title, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .animation(.easeInOut(duration: 0.3), value: phase.rawValue)

                    if isActive && phase != .complete {
                        Text("Cycle \(min(cyclesCompleted + 1, totalCycles)) of \(totalCycles)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }

                    if phase == .complete {
                        Text("4 breathing cycles complete")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.bottom, 32)

                // Breathing circle
                ZStack {
                    Circle()
                        .fill(phase.color.opacity(0.04))
                        .frame(width: 280, height: 280)

                    Circle()
                        .stroke(phase.color.opacity(0.12), lineWidth: 1.5)
                        .frame(width: 250, height: 250)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [phase.color.opacity(0.45), phase.color.opacity(0.10)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 110
                            )
                        )
                        .frame(width: 210, height: 210)
                        .scaleEffect(circleScale)
                        .shadow(color: phase.color.opacity(0.35), radius: 30)

                    Circle()
                        .fill(phase.color.opacity(0.25))
                        .frame(width: 50, height: 50)
                        .scaleEffect(circleScale)
                }

                Spacer()

                // Action button
                if phase == .ready {
                    Button { startBreathing() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wind")
                            Text("Begin Breathing")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ZeenTheme.ctaGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(color: ZeenTheme.accentCyan.opacity(0.3), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 24)
                } else if phase == .complete {
                    Button { dismiss() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                            Text("Done")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ZeenTheme.accentMint.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    private func startBreathing() {
        isActive = true
        cyclesCompleted = 0
        runCycle()
    }

    private func runCycle() {
        guard cyclesCompleted < totalCycles else {
            withAnimation(.easeInOut(duration: 0.5)) { phase = .complete }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return
        }

        // Breathe In — 4s
        withAnimation(.easeInOut(duration: 0.3)) { phase = .breatheIn }
        withAnimation(.easeInOut(duration: 4)) { circleScale = 1.0 }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()

        // Hold — 7s (starts at t=4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.easeInOut(duration: 0.3)) { phase = .hold }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        // Breathe Out — 8s (starts at t=11)
        DispatchQueue.main.asyncAfter(deadline: .now() + 11) {
            withAnimation(.easeInOut(duration: 0.3)) { phase = .breatheOut }
            withAnimation(.easeInOut(duration: 8)) { circleScale = 0.35 }
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }

        // Next cycle (at t=19)
        DispatchQueue.main.asyncAfter(deadline: .now() + 19) {
            cyclesCompleted += 1
            runCycle()
        }
    }
}
