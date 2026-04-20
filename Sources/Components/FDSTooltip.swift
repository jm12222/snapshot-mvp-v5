import SwiftUI

// MARK: - Tooltip Style
enum FDSTooltipStyle {
    case standard   // Dark background
    case callout    // Blue/accent background
    case onMedia    // Semi-transparent dark
}

// MARK: - Arrow Direction
enum FDSTooltipArrowDirection {
    case up
    case down
}

// MARK: - Arrow Position
enum FDSTooltipArrowPosition {
    case left
    case center
    case right
}

// MARK: - FDSTooltip Component
struct FDSTooltip: View {
    let text: String
    let tooltipStyle: FDSTooltipStyle
    let arrowDirection: FDSTooltipArrowDirection
    let arrowPosition: FDSTooltipArrowPosition
    let maxWidth: CGFloat
    let onDismiss: (() -> Void)?

    init(
        text: String,
        tooltipStyle: FDSTooltipStyle = .standard,
        arrowDirection: FDSTooltipArrowDirection = .up,
        arrowPosition: FDSTooltipArrowPosition = .left,
        maxWidth: CGFloat = 300,
        onDismiss: (() -> Void)? = nil
    ) {
        self.text = text
        self.tooltipStyle = tooltipStyle
        self.arrowDirection = arrowDirection
        self.arrowPosition = arrowPosition
        self.maxWidth = maxWidth
        self.onDismiss = onDismiss
    }

    private var backgroundColor: Color {
        switch tooltipStyle {
        case .standard: return Color("cardBackgroundDark")
        case .callout: return Color("accentColor")
        case .onMedia: return Color("primaryText").opacity(0.85)
        }
    }

    private var textColor: Color {
        return Color("alwaysWhite")
    }

    private var arrowHorizontalOffset: CGFloat {
        switch arrowPosition {
        case .left: return 20
        case .center: return 0
        case .right: return -20
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if arrowDirection == .up {
                arrowView
                    .rotationEffect(.degrees(0))
                    .offset(x: arrowHorizontalOffset)
            }

            HStack(spacing: 8) {
                Text(text)
                    .body3Typography()
                    .foregroundStyle(textColor)
                    .fixedSize(horizontal: false, vertical: true)

                if onDismiss != nil {
                    Button(action: { onDismiss?() }) {
                        Image("x-filled")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(textColor.opacity(0.7))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: maxWidth)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if arrowDirection == .down {
                arrowView
                    .rotationEffect(.degrees(180))
                    .offset(x: arrowHorizontalOffset)
            }
        }
    }

    private var arrowView: some View {
        Triangle()
            .fill(backgroundColor)
            .frame(width: 16, height: 8)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Tooltip Preview View
struct TooltipPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDismissable = true

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Tooltip",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Standard — arrow up") {
                            VStack(alignment: .leading, spacing: 16) {
                                FDSTooltip(
                                    text: "Tap here to customize your feed preferences",
                                    arrowDirection: .up,
                                    arrowPosition: .left
                                )
                                FDSTooltip(
                                    text: "New feature available",
                                    arrowDirection: .up,
                                    arrowPosition: .center
                                )
                            }
                        }

                        ButtonGroupCard(title: "Standard — arrow down") {
                            VStack(alignment: .leading, spacing: 16) {
                                FDSTooltip(
                                    text: "Pull down to refresh your notifications",
                                    arrowDirection: .down,
                                    arrowPosition: .left
                                )
                            }
                        }

                        ButtonGroupCard(title: "With dismiss button") {
                            VStack(alignment: .leading, spacing: 16) {
                                if showDismissable {
                                    FDSTooltip(
                                        text: "You can long-press any notification to see more options",
                                        onDismiss: { showDismissable = false }
                                    )
                                } else {
                                    FDSButton(
                                        type: .secondary,
                                        label: "Show again",
                                        size: .small,
                                        widthMode: .constrained,
                                        action: { showDismissable = true }
                                    )
                                }
                            }
                        }

                        ButtonGroupCard(title: "Callout style") {
                            FDSTooltip(
                                text: "Try the new AI-powered summary feature",
                                tooltipStyle: .callout,
                                arrowDirection: .up,
                                arrowPosition: .center
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "On media", backgroundType: .media) {
                            FDSTooltip(
                                text: "Double-tap to like",
                                tooltipStyle: .onMedia,
                                arrowDirection: .down,
                                arrowPosition: .center
                            )
                        }

                        ButtonGroupCard(title: "Arrow positions") {
                            VStack(alignment: .leading, spacing: 16) {
                                FDSTooltip(text: "Left arrow", arrowPosition: .left)
                                FDSTooltip(text: "Center arrow", arrowPosition: .center)
                                FDSTooltip(text: "Right arrow", arrowPosition: .right)
                            }
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
        TooltipPreviewView()
    }
}
