import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var appeared = false

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Branding
                    VStack(spacing: 14) {
                        Circle()
                            .fill(ZeenTheme.ctaGradient)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(avatarInitial)
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: ZeenTheme.accentCyan.opacity(0.4), radius: 20, y: 10)
                            .scaleEffect(appeared ? 1 : 0.5)
                            .opacity(appeared ? 1 : 0)

                        VStack(spacing: 6) {
                            Text("Welcome to Zeen")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                            Text("Understand your attention patterns.\nNo data leaves your device.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.65))
                                .multilineTextAlignment(.center)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                    }
                    .padding(.top, 40)

                    // Features
                    VStack(spacing: 12) {
                        featureRow(icon: "brain.head.profile", title: "Cognitive Drift Score", desc: "Measures attention fragmentation, not screen time")
                        featureRow(icon: "lock.shield", title: "100% On-Device", desc: "All analysis happens locally on your iPhone")
                        featureRow(icon: "chart.xyaxis.line", title: "Weekly Insights", desc: "Track patterns and build better focus habits")
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                    // Form
                    GlassCard(delay: 0.3) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Create your profile")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.96))

                            VStack(spacing: 12) {
                                ZeenTextField(placeholder: "Your name", text: $name, icon: "person")
                                    .textContentType(.name)
                                ZeenTextField(placeholder: "Email address", text: $email, icon: "envelope")
                                    .textContentType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                            }

                            if !email.isEmpty && !emailIsValid {
                                Text("Please enter a valid email address")
                                    .font(.caption)
                                    .foregroundStyle(.red.opacity(0.9))
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            Button(action: handleContinue) {
                                HStack {
                                    Spacer()
                                    Text("Get Started")
                                        .font(.headline)
                                    Image(systemName: "arrow.right")
                                        .font(.headline)
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .background(ZeenTheme.ctaGradient)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: ZeenTheme.accentCyan.opacity(0.3), radius: 12, y: 6)
                            }
                            .disabled(!formIsValid)
                            .opacity(formIsValid ? 1 : 0.5)
                        }
                    }
                }
                .padding(24)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    private func featureRow(icon: String, title: String, desc: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(ZeenTheme.accentCyan)
                .frame(width: 36, height: 36)
                .background(ZeenTheme.accentCyan.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
    }

    private var formIsValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && emailIsValid
    }

    private var emailIsValid: Bool {
        let t = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return false }
        return t.contains("@") && t.contains(".")
    }

    private var avatarInitial: String {
        let source = name.isEmpty ? "Z" : name
        return String(source.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }

    private func handleContinue() {
        session.loginOrRegister(name: name, email: email)
    }
}
