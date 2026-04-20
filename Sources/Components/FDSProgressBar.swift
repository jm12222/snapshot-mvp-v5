import SwiftUI

// MARK: - Progress Bar Size
enum FDSProgressBarSize {
    case large   // 8pt
    case medium  // 4pt
    case small   // 2pt

    var height: CGFloat {
        switch self {
        case .large: return 8
        case .medium: return 4
        case .small: return 2
        }
    }
}

// MARK: - Progress Bar Type
enum FDSProgressBarType {
    case primary
    case secondary
    case onMedia
    case onColor
}

// MARK: - FDSProgressBar Component
struct FDSProgressBar: View {
    let progress: Double
    let size: FDSProgressBarSize
    let type: FDSProgressBarType

    init(
        progress: Double,
        size: FDSProgressBarSize = .large,
        type: FDSProgressBarType = .primary
    ) {
        self.progress = min(1, max(0, progress))
        self.size = size
        self.type = type
    }

    private var trackColor: Color {
        switch type {
        case .primary, .secondary:
            return Color("primaryText").opacity(0.2)
        case .onMedia:
            return Color("alwaysWhite").opacity(0.2)
        case .onColor:
            return Color("alwaysWhite").opacity(0.15)
        }
    }

    private var fillColor: Color {
        switch type {
        case .primary: return Color("accent")
        case .secondary: return Color("secondaryIcon")
        case .onMedia: return Color("alwaysWhite")
        case .onColor: return Color("alwaysWhite")
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(trackColor)
                Capsule()
                    .fill(fillColor)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: size.height)
    }
}

// MARK: - Indeterminate Progress Ring
struct FDSProgressRing: View {
    let size: CGFloat
    let lineWidth: CGFloat
    let type: FDSProgressBarType
    @State private var isAnimating = false

    init(
        size: CGFloat = 24,
        lineWidth: CGFloat = 3,
        type: FDSProgressBarType = .primary
    ) {
        self.size = size
        self.lineWidth = lineWidth
        self.type = type
    }

    private var ringColor: Color {
        switch type {
        case .primary: return Color("accent")
        case .secondary: return Color("secondaryIcon")
        case .onMedia, .onColor: return Color("alwaysWhite")
        }
    }

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}

// MARK: - Progress Preview View
struct ProgressPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var demoProgress: Double = 0.65

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Progress",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Progress bar — sizes") {
                            VStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Large (8pt)")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                    FDSProgressBar(progress: demoProgress, size: .large)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Medium (4pt)")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                    FDSProgressBar(progress: demoProgress, size: .medium)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Small (2pt)")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                    FDSProgressBar(progress: demoProgress, size: .small)
                                }
                            }
                        }

                        ButtonGroupCard(title: "Interactive demo") {
                            VStack(spacing: 12) {
                                FDSProgressBar(progress: demoProgress)
                                Text("\(Int(demoProgress * 100))% complete")
                                    .body3Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                Slider(value: $demoProgress, in: 0...1)
                                    .tint(Color("accent"))
                            }
                        }

                        ButtonGroupCard(title: "Progress ring — indeterminate") {
                            HStack(spacing: 24) {
                                VStack(spacing: 8) {
                                    FDSProgressRing(size: 24, lineWidth: 3)
                                    Text("Small")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }
                                VStack(spacing: 8) {
                                    FDSProgressRing(size: 36, lineWidth: 4)
                                    Text("Medium")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }
                                VStack(spacing: 8) {
                                    FDSProgressRing(size: 48, lineWidth: 5)
                                    Text("Large")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "On media", backgroundType: .media) {
                            VStack(spacing: 16) {
                                FDSProgressBar(progress: 0.4, size: .large, type: .onMedia)
                                HStack(spacing: 24) {
                                    FDSProgressRing(size: 24, type: .onMedia)
                                    FDSProgressRing(size: 36, type: .onMedia)
                                }
                            }
                        }

                        ButtonGroupCard(title: "On color", backgroundType: .purple) {
                            VStack(spacing: 16) {
                                FDSProgressBar(progress: 0.7, size: .large, type: .onColor)
                                HStack(spacing: 24) {
                                    FDSProgressRing(size: 24, type: .onColor)
                                    FDSProgressRing(size: 36, type: .onColor)
                                }
                            }
                        }

                        ButtonGroupCard(title: "Secondary type") {
                            FDSProgressBar(progress: 0.5, type: .secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color("surfaceBackground"))
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        ProgressPreviewView()
    }
}
