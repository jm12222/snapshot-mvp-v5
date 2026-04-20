import SwiftUI

// MARK: - Button Type Enumeration
enum FDSButtonType {
    case primary
    case primaryDeemphasized
    case primaryOnMedia
    case primaryOnColor
    case secondary
    case secondaryOnMedia
    case secondaryOnColor
}

// MARK: - Button Size Enumeration
enum FDSButtonSize {
    case large
    case medium
    case small
}

// MARK: - Width Mode Enumeration
enum FDSButtonWidthMode {
    case flexible
    case constrained
}

// MARK: - FDSButton Component
struct FDSButton: View {
    // MARK: - Properties
    let type: FDSButtonType
    let label: String?
    let icon: String?
    let size: FDSButtonSize
    let isDisabled: Bool
    let widthMode: FDSButtonWidthMode
    let isMenuButton: Bool
    let action: (() -> Void)?
    let navigationValue: (any Hashable)?
    
    // MARK: - Initializer
    init(
        type: FDSButtonType = .primary,
        label: String? = nil,
        icon: String? = nil,
        size: FDSButtonSize = .medium,
        isDisabled: Bool = false,
        widthMode: FDSButtonWidthMode = .flexible,
        isMenuButton: Bool = false,
        navigationValue: (any Hashable)? = nil,
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.label = label
        self.icon = icon
        self.size = size
        self.isDisabled = isDisabled
        self.widthMode = widthMode
        self.isMenuButton = isMenuButton
        self.navigationValue = navigationValue
        self.action = action
        
        // Validation: Either label or icon must be provided
        assert(label != nil || icon != nil, "FDSButton: Either label or icon must be provided")
        
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if let navigationValue = navigationValue {
                NavigationLink(value: navigationValue) {
                    buttonContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8, scale: .medium))
                .disabled(isDisabled)
            } else {
                Button(action: {
                    if !isDisabled {
                        action?()
                    }
                }) {
                    buttonContent
                }
                .buttonStyle(FDSPressedState(cornerRadius: 8, scale: .medium))
                .disabled(isDisabled)
            }
        }
    }
    
    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: horizontalSpacing) {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
            }
            
            if let label = label {
                textWithTypography(label)
                    .foregroundStyle(textColor)
            }
            
            if isMenuButton {
                Image("triangle-down-filled")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(iconColor)
                    .frame(width: menuIconSize, height: menuIconSize)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(maxWidth: widthMode == .flexible ? .infinity : nil)
        .frame(height: buttonHeight)
        .background(backgroundColor)
        .cornerRadius(buttonCornerRadius)
    }
    
    // MARK: - Computed Properties
    
    private var horizontalSpacing: CGFloat {
        return 6
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .large: return 12
        case .medium: return 12
        case .small: return 8
        }
    }
    
    
    private var buttonHeight: CGFloat {
        switch size {
        case .large: return 40
        case .medium: return 36
        case .small: return 28
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .large: return 16
        case .medium: return 16
        case .small: return 12
        }
    }
    
    private var menuIconSize: CGFloat {
        switch size {
        case .large: return 16
        case .medium: return 16
        case .small: return 12
        }
    }
    
    private var buttonCornerRadius: CGFloat {
        switch size {
        case .large: return 8
        case .medium: return 8
        case .small: return 8
        }
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return Color("disabledButtonBackground")
        }
        
        switch type {
        case .primary:
            return Color("primaryButtonBackground")
        case .primaryDeemphasized:
            return Color("primaryDeemphasizedButtonBackground")
        case .primaryOnMedia:
            return Color("primaryButtonBackgroundOnMedia")
        case .primaryOnColor:
            return Color("primaryButtonBackgroundOnColor")
        case .secondary:
            return Color("secondaryButtonBackground")
        case .secondaryOnMedia:
            return Color("secondaryButtonBackgroundOnMedia")
        case .secondaryOnColor:
            return Color("secondaryButtonBackgroundOnColor")
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        
        switch type {
        case .primary:
            return Color("primaryButtonText")
        case .primaryDeemphasized:
            return Color("primaryDeemphasizedButtonText")
        case .primaryOnMedia:
            return Color("primaryButtonTextOnMedia")
        case .primaryOnColor:
            return Color("primaryButtonTextOnColor")
        case .secondary:
            return Color("secondaryButtonText")
        case .secondaryOnMedia:
            return Color("secondaryButtonTextOnMedia")
        case .secondaryOnColor:
            return Color("secondaryButtonTextOnColor")
        }
    }
    
    private var iconColor: Color {
        if isDisabled {
            return Color("disabledIcon")
        }
        
        switch type {
        case .primary:
            return Color("primaryButtonIcon")
        case .primaryDeemphasized:
            return Color("primaryDeemphasizedButtonIcon")
        case .primaryOnMedia:
            return Color("primaryButtonIconOnMedia")
        case .primaryOnColor:
            return Color("primaryButtonIconOnColor")
        case .secondary:
            return Color("secondaryButtonIcon")
        case .secondaryOnMedia:
            return Color("secondaryButtonIconOnMedia")
        case .secondaryOnColor:
            return Color("secondaryButtonIconOnColor")
        }
    }
    
    @ViewBuilder
    private func textWithTypography(_ text: String) -> some View {
        switch size {
        case .large:
            Text(text).button1Typography()
        case .medium:
            Text(text).button2Typography()
        case .small:
            Text(text).button3Typography()
        }
    }
}

// MARK: - Button Group Card Component
enum ButtonGroupCardBackground {
    case normal
    case purple
    case media
}

struct ButtonGroupCard<Content: View>: View {
    let title: String
    let content: Content
    let backgroundType: ButtonGroupCardBackground
    
    init(title: String, backgroundType: ButtonGroupCardBackground = .normal, @ViewBuilder content: () -> Content) {
        self.title = title
        self.backgroundType = backgroundType
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(backgroundType == .normal ? Color("primaryText") : Color("alwaysWhite"))
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        switch backgroundType {
        case .normal:
            Color("cardBackground")
        case .purple:
            Color("decorativeIconPurple")
        case .media:
            ZStack {
                Image("image2")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                Color("overlayOnMediaLight")
            }
        }
    }
}

// MARK: - Buttons Preview View
// MARK: - FDSButtonGroup (2-up: primary left, secondary right)

struct FDSButtonGroup: View {
    let primaryLabel: String
    let secondaryLabel: String
    var primaryType: FDSButtonType = .primary
    var secondaryType: FDSButtonType = .secondary
    var size: FDSButtonSize = .medium
    var primaryAction: () -> Void = {}
    var secondaryAction: () -> Void = {}

    var body: some View {
        HStack(spacing: 8) {
            FDSButton(
                type: primaryType,
                label: primaryLabel,
                size: size,
                widthMode: .flexible,
                action: primaryAction
            )
            FDSButton(
                type: secondaryType,
                label: secondaryLabel,
                size: size,
                widthMode: .flexible,
                action: secondaryAction
            )
        }
    }
}

struct ButtonsPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Buttons & Chips",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // SELECTS — agent defaults to these
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Button Group (2-up)") {
                            VStack(spacing: 12) {
                                FDSButtonGroup(primaryLabel: "Confirm", secondaryLabel: "Delete")
                                FDSButtonGroup(primaryLabel: "Add friend", secondaryLabel: "Remove", primaryType: .primaryDeemphasized)
                            }
                        }

                        ButtonGroupCard(title: "Primary — medium") {
                            FDSButton(type: .primary, label: "Primary action", size: .medium, action: {})
                        }

                        ButtonGroupCard(title: "Primary deemphasized — medium") {
                            FDSButton(type: .primaryDeemphasized, label: "Deemphasized action", size: .medium, action: {})
                        }

                        ButtonGroupCard(title: "Secondary — medium") {
                            FDSButton(type: .secondary, label: "Secondary action", size: .medium, action: {})
                        }

                        // ── Action Chips ──

                        ButtonGroupCard(title: "Action Chip — styles (surface)") {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    FDSActionChip(type: .primary, size: .medium, label: "Primary", action: {})
                                    FDSActionChip(type: .primaryDeemphasized, size: .medium, label: "Deemphasized", action: {})
                                    FDSActionChip(type: .secondary, size: .medium, label: "Secondary", action: {})
                                }
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — with add-ons") {
                            VStack(spacing: 8) {
                                FDSActionChip(size: .medium, label: "Share", leftAddOn: .icon("share-outline"), action: {})
                                FDSActionChip(size: .medium, label: "Send to Alex", leftAddOn: .profilePhoto("profile2"), action: {})
                                FDSActionChip(size: .medium, label: "Category", isMenu: true, action: {})
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — sizes") {
                            HStack(spacing: 8) {
                                FDSActionChip(size: .small, label: "Small 24", action: {})
                                FDSActionChip(size: .medium, label: "Medium 32", action: {})
                                FDSActionChip(size: .large, label: "Large 36", action: {})
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — emphasized") {
                            HStack(spacing: 8) {
                                FDSActionChip(size: .medium, label: "Normal", action: {})
                                FDSActionChip(size: .medium, label: "Emphasized", isEmphasized: true, action: {})
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — on media", backgroundType: .media) {
                            HStack(spacing: 8) {
                                FDSActionChip(surface: .media, type: .primary, size: .medium, label: "Reply", action: {})
                                FDSActionChip(surface: .media, type: .secondary, size: .medium, label: "Share", leftAddOn: .icon("share-outline"), action: {})
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — on color", backgroundType: .purple) {
                            HStack(spacing: 8) {
                                FDSActionChip(surface: .color, type: .primary, size: .medium, label: "Reply", action: {})
                                FDSActionChip(surface: .color, type: .secondary, size: .medium, label: "Share", action: {})
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — h-scroll group") {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    FDSActionChip(size: .medium, label: "All", action: {})
                                    FDSActionChip(type: .primaryDeemphasized, size: .medium, label: "Groups", leftAddOn: .icon("group-outline"), action: {})
                                    FDSActionChip(type: .primaryDeemphasized, size: .medium, label: "Pages", leftAddOn: .icon("pages-outline"), action: {})
                                    FDSActionChip(type: .primaryDeemphasized, size: .medium, label: "Events", leftAddOn: .icon("events-outline"), action: {})
                                    FDSActionChip(type: .primaryDeemphasized, size: .medium, label: "Reels", action: {})
                                }
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — grid (feedback pills)") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    FDSActionChip(size: .medium, label: "Not interested", action: {})
                                    FDSActionChip(size: .medium, label: "Too many", action: {})
                                }
                                HStack(spacing: 8) {
                                    FDSActionChip(size: .medium, label: "Already saw this", action: {})
                                    FDSActionChip(size: .medium, label: "Something else", action: {})
                                }
                            }
                        }

                        ButtonGroupCard(title: "Action Chip — disabled") {
                            FDSActionChip(size: .medium, label: "Unavailable", action: {})
                                .disabled(true)
                                .opacity(0.4)
                        }

                        // ── Info Chips (non-interactive, display information) ──

                        ButtonGroupCard(title: "Info Chip — styles") {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    FDSInfoChip(type: .secondary, label: "Draft")
                                    FDSInfoChip(type: .secondaryEmphasized, label: "LIVE")
                                }
                            }
                        }

                        ButtonGroupCard(title: "Info Chip — with icon") {
                            HStack(spacing: 8) {
                                FDSInfoChip(label: "3 min read", icon: "clock-outline")
                                FDSInfoChip(label: "Trending", icon: "trending-outline")
                            }
                        }

                        ButtonGroupCard(title: "Info Chip — sizes") {
                            HStack(spacing: 8) {
                                FDSInfoChip(label: "Small", size: .small)
                                FDSInfoChip(label: "Medium", size: .medium)
                                FDSInfoChip(label: "Large", size: .large)
                            }
                        }

                        ButtonGroupCard(title: "Info Chip — on media", backgroundType: .media) {
                            HStack(spacing: 8) {
                                FDSInfoChip(type: .primaryOnMedia, label: "LIVE")
                                FDSInfoChip(type: .secondaryOnMediaEmphasized, label: "4:32")
                            }
                        }

                        ButtonGroupCard(title: "Info Chip — on color", backgroundType: .purple) {
                            HStack(spacing: 8) {
                                FDSInfoChip(type: .primaryOnColor, label: "New")
                                FDSInfoChip(type: .secondaryOnColorEmphasized, label: "Featured")
                            }
                        }

                        ButtonGroupCard(title: "Info Chip — icon only") {
                            HStack(spacing: 8) {
                                FDSInfoChip(label: "Audio", hideLabel: true, icon: "volume-up-filled")
                                FDSInfoChip(label: "Muted", hideLabel: true, icon: "volume-mute-filled")
                            }
                        }

                        ButtonGroupCard(title: "Icon + label") {
                            VStack(spacing: 12) {
                                FDSButton(label: "Add photo", icon: "photo-filled", action: {})
                                FDSButton(type: .secondary, label: "Share", icon: "share-filled", action: {})
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    // APPENDIX — available but deprioritized
                    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Large & small sizes") {
                            VStack(spacing: 12) {
                                FDSButton(type: .primary, label: "Large", size: .large, action: {})
                                FDSButton(type: .primary, label: "Small", size: .small, action: {})
                            }
                        }

                        ButtonGroupCard(title: "On color", backgroundType: .purple) {
                            VStack(spacing: 12) {
                                FDSButton(type: .primaryOnColor, label: "Primary on color", size: .medium, action: {})
                                FDSButton(type: .secondaryOnColor, label: "Secondary on color", size: .medium, action: {})
                            }
                        }

                        ButtonGroupCard(title: "On media", backgroundType: .media) {
                            VStack(spacing: 12) {
                                FDSButton(type: .primaryOnMedia, label: "Primary on media", size: .medium, action: {})
                                FDSButton(type: .secondaryOnMedia, label: "Secondary on media", size: .medium, action: {})
                            }
                        }

                        ButtonGroupCard(title: "Icon only") {
                            HStack(spacing: 12) {
                                FDSButton(icon: "photo-filled", size: .large, action: {})
                                FDSButton(icon: "photo-filled", size: .medium, action: {})
                                FDSButton(icon: "photo-filled", size: .small, action: {})
                            }
                        }

                        ButtonGroupCard(title: "Disabled") {
                            FDSButton(label: "Disabled", isDisabled: true, action: {})
                        }

                        ButtonGroupCard(title: "Width modes") {
                            VStack(alignment: .center, spacing: 12) {
                                FDSButton(label: "Flexible width", widthMode: .flexible, action: {})
                                FDSButton(label: "Constrained", widthMode: .constrained, action: {})
                            }
                        }

                        ButtonGroupCard(title: "Menu button") {
                            FDSButton(type: .secondary, label: "Select option", size: .medium, widthMode: .constrained, isMenuButton: true, action: {})
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    ButtonsPreviewView()
}
