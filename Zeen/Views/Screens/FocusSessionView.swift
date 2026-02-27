import SwiftUI

struct FocusSessionView: View {
    @EnvironmentObject private var vm: FocusSessionViewModel

    @State private var pulsate = false
    @State private var completionBounce = false

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Type selector (idle only)
                    if vm.state == .idle {
                        typeSelector
                    }

                    // Timer
                    timerSection

                    // Controls
                    controlButtons

                    // Today stats
                    if vm.totalSessionsToday > 0 {
                        todayStats
                    }

                    // Session history
                    if !vm.sessions.isEmpty {
                        recentSessions
                    }
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Focus")
    }

    // MARK: - Type Selector

    private var typeSelector: some View {
        GlassCard(delay: 0.05) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Session Type")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.96))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(FocusSessionType.allCases) { type in
                        Button { vm.selectType(type) } label: {
                            HStack(spacing: 10) {
                                Image(systemName: type.icon)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(vm.selectedType == type ? .white : type.color)
                                    .frame(width: 28, height: 28)
                                    .background(
                                        vm.selectedType == type
                                            ? AnyShapeStyle(type.gradient)
                                            : AnyShapeStyle(type.color.opacity(0.12))
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(type.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white.opacity(vm.selectedType == type ? 1 : 0.7))
                                    Text("\(type.defaultMinutes) min")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                Spacer()
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(vm.selectedType == type ? type.color.opacity(0.12) : Color.white.opacity(0.04))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        vm.selectedType == type ? type.color.opacity(0.35) : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        GlassCard(delay: 0.10) {
            VStack(spacing: 20) {
                ZStack {
                    // Track
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 14)

                    // Progress
                    Circle()
                        .trim(from: 0, to: vm.progress)
                        .stroke(
                            AngularGradient(
                                colors: [vm.selectedType.color, vm.selectedType.color.opacity(0.5), vm.selectedType.color],
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(270)
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: vm.selectedType.color.opacity(0.4), radius: 10)
                        .animation(.linear(duration: 1), value: vm.progress)

                    // Glow at endpoint
                    if vm.state == .running {
                        Circle()
                            .fill(vm.selectedType.color.opacity(pulsate ? 0.25 : 0.08))
                            .frame(width: 180, height: 180)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulsate)
                    }

                    // Center content
                    VStack(spacing: 6) {
                        Image(systemName: vm.selectedType.icon)
                            .font(.title3)
                            .foregroundStyle(vm.selectedType.color.opacity(0.7))

                        Text(vm.timeLabel)
                            .font(.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white)
                            .contentTransition(.numericText(value: vm.remainingTime))

                        Text(vm.selectedType.rawValue)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.50))

                        if vm.state == .running {
                            Text("Stay focused")
                                .font(.caption2)
                                .foregroundStyle(vm.selectedType.color.opacity(0.7))
                                .transition(.opacity)
                        } else if vm.state == .paused {
                            Text("Paused")
                                .font(.caption2)
                                .foregroundStyle(.yellow.opacity(0.8))
                                .transition(.opacity)
                        }
                    }
                }
                .frame(width: 220, height: 220)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            pulsate = true
        }
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 16) {
            switch vm.state {
            case .idle:
                Button {
                    let g = UIImpactFeedbackGenerator(style: .medium)
                    g.impactOccurred()
                    withAnimation(ZeenTheme.springSnappy) { vm.start() }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Start Session")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(vm.selectedType.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: vm.selectedType.color.opacity(0.3), radius: 12, y: 6)
                }

            case .running:
                Button {
                    withAnimation(ZeenTheme.springSnappy) { vm.pause() }
                } label: {
                    controlPill(icon: "pause.fill", label: "Pause", color: .yellow)
                }

                Button {
                    withAnimation(ZeenTheme.springSnappy) { vm.stop() }
                } label: {
                    controlPill(icon: "stop.fill", label: "End", color: .red.opacity(0.8))
                }

            case .paused:
                Button {
                    withAnimation(ZeenTheme.springSnappy) { vm.resume() }
                } label: {
                    controlPill(icon: "play.fill", label: "Resume", color: vm.selectedType.color)
                }

                Button {
                    withAnimation(ZeenTheme.springSnappy) { vm.stop() }
                } label: {
                    controlPill(icon: "stop.fill", label: "End", color: .red.opacity(0.8))
                }
            }
        }
    }

    private func controlPill(icon: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.subheadline)
            Text(label).font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(color.opacity(0.30), lineWidth: 0.8)
        )
    }

    // MARK: - Today Stats

    private var todayStats: some View {
        HStack(spacing: 12) {
            StatCard(icon: "checkmark.circle", value: "\(vm.completedToday)", label: "Completed", color: ZeenTheme.accentMint, delay: 0.15)
            StatCard(icon: "clock", value: "\(vm.totalFocusMinutesToday)m", label: "Focused", color: ZeenTheme.accentCyan, delay: 0.20)
            StatCard(icon: "flame", value: "\(vm.totalSessionsToday)", label: "Sessions", color: ZeenTheme.accentBlue, delay: 0.25)
        }
    }

    // MARK: - Recent Sessions

    private var recentSessions: some View {
        GlassCard(delay: 0.30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Sessions")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.96))

                ForEach(vm.sessions.prefix(5)) { record in
                    HStack(spacing: 12) {
                        Image(systemName: record.type.icon)
                            .font(.subheadline)
                            .foregroundStyle(record.type.color)
                            .frame(width: 30, height: 30)
                            .background(record.type.color.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.type.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                            Text(record.completedAt, format: .dateTime.hour().minute())
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.40))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(record.elapsedLabel)
                                .font(.subheadline.weight(.semibold).monospacedDigit())
                                .foregroundStyle(.white.opacity(0.80))
                            if record.completed {
                                Text("Completed")
                                    .font(.caption2)
                                    .foregroundStyle(ZeenTheme.accentMint)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }
}
