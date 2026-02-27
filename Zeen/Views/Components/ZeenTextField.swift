import SwiftUI

struct ZeenTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(width: 20)
            }
            TextField(placeholder, text: $text)
                .foregroundStyle(.white)
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.10), lineWidth: 0.5)
        )
    }
}
