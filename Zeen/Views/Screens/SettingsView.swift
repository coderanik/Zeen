import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Profile Card (iOS Settings style)
                    NavigationLink {
                        ProfileDetailView()
                    } label: {
                        profileCard
                    }
                    .buttonStyle(.plain)

                    // MARK: - Privacy Section
                    GlassCard(delay: 0.10) {
                        VStack(spacing: 0) {
                            settingSectionHeader(icon: "lock.shield.fill", title: "Privacy", color: .blue)
                                .padding(.bottom, 10)

                            Toggle(isOn: $viewModel.preferences.analysisOnDeviceOnly) {
                                settingLabel(icon: "iphone", title: "On-device analysis only")
                            }
                            .tint(ZeenTheme.accentMint)
                            .padding(.vertical, 4)

                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 40)

                            Toggle(isOn: $viewModel.preferences.useFocusIntegration) {
                                settingLabel(icon: "moon.fill", title: "Use Focus Mode signals")
                            }
                            .tint(ZeenTheme.accentMint)
                            .padding(.vertical, 4)

                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 40)

                            Toggle(isOn: $viewModel.preferences.useNotificationsSignal) {
                                settingLabel(icon: "bell.badge.fill", title: "Notification signals")
                            }
                            .tint(ZeenTheme.accentMint)
                            .padding(.vertical, 4)
                        }
                        .foregroundStyle(.white)
                    }

                    // MARK: - Data Sources Section
                    GlassCard(delay: 0.18) {
                        VStack(alignment: .leading, spacing: 0) {
                            settingSectionHeader(icon: "antenna.radiowaves.left.and.right", title: "Data Sources", color: ZeenTheme.accentCyan)
                                .padding(.bottom, 10)

                            settingRow(icon: "apps.iphone", title: "Screen Time", subtitle: "Device Activity framework", color: .purple)
                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 40)
                            settingRow(icon: "moon.fill", title: "Focus Status", subtitle: "System focus transitions", color: .indigo)
                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 40)
                            settingRow(icon: "bell.badge.fill", title: "Notifications", subtitle: "Interruption metadata only", color: .orange)

                            HStack(spacing: 8) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.caption)
                                    .foregroundStyle(ZeenTheme.accentMint)
                                Text("No message content or personal data is ever accessed.")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.40))
                            }
                            .padding(.top, 14)
                        }
                    }

                    // MARK: - About Section
                    GlassCard(delay: 0.26) {
                        VStack(alignment: .leading, spacing: 0) {
                            settingSectionHeader(icon: "brain.head.profile", title: "About Zeen", color: ZeenTheme.accentMint)
                                .padding(.bottom, 10)

                            Text("Zeen estimates cognitive fragmentation using behavior signals — not screen time. Your Drift Score reflects how scattered your attention has been, helping you build better focus habits.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.55))
                                .lineSpacing(3)
                                .padding(.bottom, 12)

                            Divider().background(Color.white.opacity(0.06))

                            HStack {
                                Text("Version")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text("1.0.0")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.40))
                            }
                            .padding(.vertical, 10)

                            Divider().background(Color.white.opacity(0.06))

                            HStack {
                                Text("Platform")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text("iOS 17+")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.40))
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Settings")
    }

    // MARK: - Profile Card Component

    private var profileCard: some View {
        GlassCard(delay: 0.05) {
            HStack(spacing: 14) {
                Circle()
                    .fill(ZeenTheme.ctaGradient)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(profileInitial)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: ZeenTheme.accentCyan.opacity(0.25), radius: 10, y: 4)

                VStack(alignment: .leading, spacing: 3) {
                    Text(session.profile?.name ?? "Your Name")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Profile, Goal, & Account")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.50))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.30))
            }
        }
    }

    // MARK: - Helpers

    private func settingSectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.96))
        }
    }

    private func settingLabel(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.50))
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
        }
    }

    private func settingRow(icon: String, title: String, subtitle: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.40))
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private var profileInitial: String {
        String((session.profile?.name ?? "Z").prefix(1)).uppercased()
    }
}
