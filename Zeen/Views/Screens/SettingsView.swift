import SwiftUI

struct SettingsView: View {
    @State private var analysisOnDeviceOnly = true
    @State private var useFocusIntegration = true
    @State private var useNotificationsSignal = true

    var body: some View {
        ZStack {
            GlassBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Privacy")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Toggle("On-device analysis only", isOn: $analysisOnDeviceOnly)
                                .tint(.mint)
                            Toggle("Use Focus Mode signals", isOn: $useFocusIntegration)
                                .tint(.mint)
                            Toggle("Use notification interruption count", isOn: $useNotificationsSignal)
                                .tint(.mint)
                        }
                        .foregroundStyle(.white)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Data Sources")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("- Screen Time / Device Activity\n- Focus status transitions\n- Notification interruption metadata")
                                .foregroundStyle(.white.opacity(0.84))

                            Text("No content or message text is accessed.")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.68))
                        }
                    }
                }
                .padding(20)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Settings")
    }
}
