import SwiftUI

// MARK: - FDSContextualMessage

struct FDSContextualMessage: View {
    // Text
    var headlineText: String?
    var bodyText: String?
    var textHierarchyLevel: Int = 3 // 3 or 4
    var headlineEmphasis: HeadlineEmphasis = .normal

    // Card style
    var elevation: Elevation = .flat
    var showDismiss: Bool = false
    var onDismiss: (() -> Void)?

    // Left add-on
    var leftAddOn: LeftAddOn?

    // Bottom add-on
    var bottomAddOn: BottomAddOn?

    enum HeadlineEmphasis {
        case normal      // semibold
        case emphasized  // bold
        case deemphasized // regular
    }

    enum Elevation {
        case flat
        case elevated
        case transparent
        case surface
    }

    enum LeftAddOn {
        case icon(String, color: IconColor = .primary)
        case errorIcon(severity: ErrorSeverity)
        case profilePhoto(imageName: String, size: CGFloat = 40)
    }

    enum IconColor {
        case primary, accent, negative, warning

        var color: Color {
            switch self {
            case .primary: return Color("primaryIcon")
            case .accent: return Color("accentColor")
            case .negative: return Color("negative")
            case .warning: return Color("warning")
            }
        }
    }

    enum ErrorSeverity {
        case error, warning
    }

    enum BottomAddOn {
        case button(label: String, variant: ButtonVariant = .primary, action: () -> Void)
        case buttonGroup(
            button1Label: String, button1Variant: ButtonVariant = .primary, button1Action: () -> Void,
            button2Label: String, button2Variant: ButtonVariant = .secondary, button2Action: () -> Void
        )
    }

    enum ButtonVariant {
        case primary, secondary, primaryDeemphasized

        var backgroundColor: Color {
            switch self {
            case .primary: return Color("primaryButtonBackground")
            case .secondary: return Color("secondaryButtonBackground")
            case .primaryDeemphasized: return Color("primaryDeemphasizedButtonBackground")
            }
        }

        var textColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return Color("primaryText")
            case .primaryDeemphasized: return Color("primaryDeemphasizedButtonText")
            }
        }
    }

    // Typography helpers
    private var headlineFont: Font {
        let weight: Font.Weight = switch headlineEmphasis {
        case .normal: .semibold
        case .emphasized: .bold
        case .deemphasized: .regular
        }
        let size: CGFloat = textHierarchyLevel == 3 ? 15 : 13
        return .system(size: size, weight: weight)
    }

    private var bodyFont: Font {
        let size: CGFloat = textHierarchyLevel == 3 ? 15 : 13
        return .system(size: size)
    }

    private var cardBackground: Color {
        switch elevation {
        case .flat: return Color("cardBackgroundFlat")
        case .elevated, .surface: return .white
        case .transparent: return .clear
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top row: left add-on + text + dismiss
            HStack(alignment: .top, spacing: 12) {
                // Left add-on
                if let leftAddOn {
                    leftAddOnView(leftAddOn)
                }

                // Text pairing
                VStack(alignment: .leading, spacing: 0) {
                    if let headlineText {
                        Text(headlineText)
                            .font(headlineFont)
                            .foregroundStyle(Color("primaryText"))
                    }
                    if let bodyText {
                        Text(bodyText)
                            .font(bodyFont)
                            .foregroundStyle(Color("primaryText"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Dismiss
                if showDismiss {
                    Button(action: { onDismiss?() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color("secondaryIcon"))
                            .frame(width: 28, height: 28)
                    }
                    .offset(x: 4, y: -4)
                }
            }

            // Bottom add-on
            if let bottomAddOn {
                bottomAddOnView(bottomAddOn)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(cardBackground)
        .shadow(color: elevation == .elevated ? .black.opacity(0.05) : .clear, radius: 4, x: 0, y: 2)
    }

    @ViewBuilder
    private func leftAddOnView(_ addOn: LeftAddOn) -> some View {
        switch addOn {
        case .icon(let name, let color):
            Image(name)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundStyle(color.color)
        case .errorIcon(let severity):
            Image(severity == .error ? "caution-circle-filled" : "caution-triangle-filled")
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundStyle(severity == .error ? Color("negative") : Color("warning"))
        case .profilePhoto(let imageName, let size):
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    private func bottomAddOnView(_ addOn: BottomAddOn) -> some View {
        switch addOn {
        case .button(let label, let variant, let action):
            cmButton(label: label, variant: variant, action: action)
        case .buttonGroup(let b1Label, let b1Variant, let b1Action, let b2Label, let b2Variant, let b2Action):
            HStack(spacing: 8) {
                cmButton(label: b1Label, variant: b1Variant, action: b1Action)
                cmButton(label: b2Label, variant: b2Variant, action: b2Action)
            }
        }
    }

    private func cmButton(label: String, variant: ButtonVariant, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(variant.textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(variant.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}


// MARK: - Preview

struct ContextualMessagePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(title: "Contextual Message", backAction: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    FDSUnitHeader(headlineText: "Flat (default)")
                    FDSContextualMessage(
                        headlineText: "Your notification preferences may be outdated",
                        bodyText: "Reset in 30 seconds — we'll recommend based on what you actually use.",
                        showDismiss: true,
                        bottomAddOn: .buttonGroup(
                            button1Label: "Reset now", button1Action: {},
                            button2Label: "Not now", button2Variant: .secondary, button2Action: {}
                        )
                    )

                    FDSUnitHeader(headlineText: "With icon")
                    FDSContextualMessage(
                        headlineText: "You watched 17 Reels from MrBeast",
                        bodyText: "Want to be notified when he posts new ones?",
                        showDismiss: true,
                        leftAddOn: .icon("bell-filled", color: .accent),
                        bottomAddOn: .buttonGroup(
                            button1Label: "Notify me", button1Action: {},
                            button2Label: "No thanks", button2Variant: .secondary, button2Action: {}
                        )
                    )

                    FDSUnitHeader(headlineText: "Elevated")
                    FDSContextualMessage(
                        headlineText: "Your notification patterns",
                        bodyText: "47 skipped · 12 opened · 3 acted on this week.",
                        elevation: .elevated,
                        showDismiss: true,
                        bottomAddOn: .buttonGroup(
                            button1Label: "Review & fix", button1Action: {},
                            button2Label: "Dismiss", button2Variant: .secondary, button2Action: {}
                        )
                    )

                    FDSUnitHeader(headlineText: "Single button")
                    FDSContextualMessage(
                        headlineText: "New feature available",
                        bodyText: "Try the updated notification controls.",
                        bottomAddOn: .button(label: "Learn more", action: {})
                    )

                    FDSUnitHeader(headlineText: "Error icon")
                    FDSContextualMessage(
                        headlineText: "Something went wrong",
                        bodyText: "We couldn't update your preferences. Try again.",
                        leftAddOn: .errorIcon(severity: .error),
                        bottomAddOn: .button(label: "Retry", action: {})
                    )

                    FDSUnitHeader(headlineText: "Level 4 typography")
                    FDSContextualMessage(
                        headlineText: "Smaller headline",
                        bodyText: "Smaller body text for compact contexts.",
                        textHierarchyLevel: 4
                    )

                    FDSUnitHeader(headlineText: "Deemphasized button")
                    FDSContextualMessage(
                        headlineText: "Suggested for you",
                        bodyText: "Based on your recent activity.",
                        bottomAddOn: .button(label: "See suggestions", variant: .primaryDeemphasized, action: {})
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color("surfaceBackground"))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ContextualMessagePreviewView()
}
