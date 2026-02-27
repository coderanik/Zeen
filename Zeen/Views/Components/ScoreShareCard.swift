import SwiftUI

struct ScoreShareCard: View {
    let score: DriftScore
    let userName: String
    let date: Date

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Zeen")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: "brain.head.profile")
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.20, green: 0.90, blue: 0.90))
            }

            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(score.value) / 100)
                    .stroke(
                        AngularGradient(
                            colors: [
                                Color(red: 0.20, green: 0.90, blue: 0.90),
                                Color(red: 0.26, green: 0.57, blue: 1.0),
                                Color(red: 0.35, green: 0.80, blue: 0.65),
                                Color(red: 0.20, green: 0.90, blue: 0.90)
                            ],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text(score.level.emoji)
                        .font(.title3)
                    Text("\(score.value)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(score.level.label)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .frame(width: 130, height: 130)

            // Factors
            VStack(spacing: 5) {
                ForEach(score.factors) { factor in
                    HStack {
                        Text(factor.title)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.65))
                        Spacer()
                        Text("+\(factor.contribution)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(ZeenTheme.driftColor(for: factor.contribution * 3))
                    }
                }
            }

            Divider().background(Color.white.opacity(0.08))

            // Footer
            Text("\(userName)'s Focus Report")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(22)
        .frame(width: 300)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.03, green: 0.06, blue: 0.14),
                        Color(red: 0.06, green: 0.10, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(Color(red: 0.20, green: 0.90, blue: 0.90).opacity(0.07))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: -70, y: -80)
                Circle()
                    .fill(Color(red: 0.26, green: 0.57, blue: 1.0).opacity(0.09))
                    .frame(width: 180, height: 180)
                    .blur(radius: 50)
                    .offset(x: 70, y: 80)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
        )
    }

    @MainActor
    func renderImage() -> Image {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }

    @MainActor
    func renderUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3
        return renderer.uiImage
    }
}
