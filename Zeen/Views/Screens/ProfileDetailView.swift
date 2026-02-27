import SwiftUI

struct ProfileDetailView: View {
    @EnvironmentObject private var session: SessionViewModel

    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var saved = false

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Avatar + Info
                    VStack(spacing: 14) {
                        ZStack(alignment: .bottomTrailing) {
                            Circle()
                                .fill(ZeenTheme.ctaGradient)
                                .frame(width: 96, height: 96)
                                .overlay(
                                    Text(profileInitial)
                                        .font(.system(size: 42, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                )
                                .shadow(color: ZeenTheme.accentCyan.opacity(0.35), radius: 20, y: 8)

                            if isEditing {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 13))
                                            .foregroundStyle(.white)
                                    )
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }

                        if !isEditing {
                            VStack(spacing: 4) {
                                Text(session.profile?.name ?? "Your Name")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.white)

                                Text(session.profile?.email ?? "Add email")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.55))

                                if let profile = session.profile {
                                    Text("Member since \(profile.joinDate, format: .dateTime.month(.wide).year())")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.35))
                                        .padding(.top, 2)
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.top, 16)
                    .frame(maxWidth: .infinity)

                    // Edit form or info cards
                    if isEditing {
                        GlassCard(delay: 0.05) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Edit Profile")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.96))

                                VStack(spacing: 12) {
                                    ZeenTextField(placeholder: "Name", text: $editedName, icon: "person")
                                        .textContentType(.name)
                                    ZeenTextField(placeholder: "Email", text: $editedEmail, icon: "envelope")
                                        .textContentType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                }

                                HStack(spacing: 12) {
                                    Button {
                                        session.updateProfile(name: editedName, email: editedEmail)
                                        withAnimation(ZeenTheme.springSnappy) {
                                            saved = true
                                            isEditing = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            withAnimation { saved = false }
                                        }
                                    } label: {
                                        HStack {
                                            Spacer()
                                            if saved {
                                                Image(systemName: "checkmark")
                                                    .transition(.scale.combined(with: .opacity))
                                            }
                                            Text(saved ? "Saved!" : "Save Changes")
                                                .font(.subheadline.weight(.semibold))
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                        .background(saved ? Color.green.opacity(0.7) : Color.white.opacity(0.9))
                                        .foregroundStyle(saved ? .white : .black)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }

                                    Button {
                                        withAnimation(ZeenTheme.springSnappy) {
                                            isEditing = false
                                        }
                                    } label: {
                                        Text("Cancel")
                                            .font(.subheadline.weight(.medium))
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 20)
                                            .background(Color.white.opacity(0.08))
                                            .foregroundStyle(.white.opacity(0.7))
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                }
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // Profile info cards
                        GlassCard(delay: 0.05) {
                            VStack(spacing: 0) {
                                profileInfoRow(icon: "person.fill", label: "Name", value: session.profile?.name ?? "—")
                                Divider().background(Color.white.opacity(0.08)).padding(.leading, 44)
                                profileInfoRow(icon: "envelope.fill", label: "Email", value: session.profile?.email ?? "—")
                                Divider().background(Color.white.opacity(0.08)).padding(.leading, 44)
                                profileInfoRow(icon: "target", label: "Goal Score", value: "< \(session.profile?.goalAverageScore ?? 40)")
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // Goal Adjustment
                    if !isEditing {
                        GlassCard(delay: 0.12) {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Focus Goal", systemImage: "gauge.with.dots.needle.50percent")
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text("Set a daily drift score target. Days below this count as \"calm days.\"")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.50))

                                HStack(spacing: 16) {
                                    Text("\(session.profile?.goalAverageScore ?? 40)")
                                        .font(.system(size: 36, weight: .bold, design: .rounded))
                                        .foregroundStyle(ZeenTheme.accentCyan)
                                        .contentTransition(.numericText(value: Double(session.profile?.goalAverageScore ?? 40)))
                                        .frame(width: 60)

                                    Slider(
                                        value: Binding(
                                            get: { Double(session.profile?.goalAverageScore ?? 40) },
                                            set: { session.updateGoal(Int($0)) }
                                        ),
                                        in: 10...90,
                                        step: 5
                                    )
                                    .tint(ZeenTheme.accentCyan)
                                }
                            }
                        }
                    }

                    // Achievements
                    if !isEditing {
                        NavigationLink {
                            AchievementsView()
                        } label: {
                            GlassCard(delay: 0.16) {
                                HStack(spacing: 14) {
                                    Image(systemName: "trophy.fill")
                                        .font(.title3)
                                        .foregroundStyle(.yellow)
                                        .frame(width: 36, height: 36)
                                        .background(Color.yellow.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Achievements")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.white)
                                        Text("\(Achievement.catalog.count) badges to unlock")
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
                        .buttonStyle(.plain)
                    }

                    // Danger zone
                    if !isEditing {
                        GlassCard(delay: 0.20) {
                            Button(role: .destructive) {
                                session.logout()
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                    Spacer()
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.red.opacity(0.85))
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(ZeenTheme.springSnappy) {
                        if !isEditing {
                            editedName = session.profile?.name ?? ""
                            editedEmail = session.profile?.email ?? ""
                        }
                        isEditing.toggle()
                    }
                } label: {
                    Image(systemName: isEditing ? "xmark" : "pencil")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .contentTransition(.symbolEffect(.replace))
                }
            }
        }
        .onAppear {
            editedName = session.profile?.name ?? ""
            editedEmail = session.profile?.email ?? ""
        }
    }

    private func profileInfoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(ZeenTheme.accentCyan)
                .frame(width: 28)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 12)
    }

    private var profileInitial: String {
        let source = isEditing ? (editedName.isEmpty ? "Z" : editedName) : (session.profile?.name ?? "Z")
        return String(source.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }
}
