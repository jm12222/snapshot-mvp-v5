import SwiftUI

// MARK: - Type Enumeration
enum FDSInfoChipType {
    case secondary
    case secondaryEmphasized
    case primaryOnMedia
    case secondaryOnMediaEmphasized
    case primaryOnColor
    case secondaryOnColorEmphasized
}

// MARK: - Size Enumeration
enum FDSInfoChipSize {
    case small
    case medium
    case large
}

// MARK: - FDSInfoChip Component
struct FDSInfoChip: View {
    // MARK: - Properties
    let type: FDSInfoChipType
    let label: String
    let hideLabel: Bool
    let size: FDSInfoChipSize
    let icon: String?
    let isContained: Bool
    
    // MARK: - Initializer
    init(
        type: FDSInfoChipType = .secondary,
        label: String,
        hideLabel: Bool = false,
        size: FDSInfoChipSize = .medium,
        icon: String? = nil,
        isContained: Bool = true
    ) {
        self.type = type
        self.label = label
        self.hideLabel = hideLabel
        self.size = size
        self.icon = icon
        self.isContained = isContained
        
        // Validate: hideLabel requires an icon
        if hideLabel && icon == nil {
            print("Error: FDSInfoChip hideLabel=true requires an icon")
        }
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: gap) {
            // Icon
            if let iconName = icon {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(iconColor)
                    .frame(width: iconSize, height: iconSize)
                    .modifier(IconOnMediaShadowModifier(isOnMedia: shouldApplyShadow))
            }
            
            // Label (unless hidden)
            if !hideLabel {
                textWithTypography(label)
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .modifier(TextOnMediaShadowModifier(isOnMedia: shouldApplyShadow))
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(minWidth: minWidth)
        .frame(height: height)
        .background {
            if isContained {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
    
    // MARK: - Computed Properties
    
    // Spacing
    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 4   // I1
        case .medium: return 6  // I4
        case .large: return 8   // I7
        }
    }
    
    private var gap: CGFloat {
        switch size {
        case .small: return 2   // I2
        case .medium: return 4  // I5
        case .large: return 4   // I8
        }
    }
    
    // Sizing
    private var height: CGFloat {
        switch size {
        case .small: return 16   // J1
        case .medium: return 20  // J3
        case .large: return 24   // J5
        }
    }
    
    private var minWidth: CGFloat {
        switch size {
        case .small: return 20   // J2
        case .medium: return 20  // J4
        case .large: return 32   // J6
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small: return 12   // K1
        case .medium: return 12  // K2
        case .large: return 16   // K3
        }
    }
    
    // Shape
    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 4   // L1
        case .medium: return 6  // L2
        case .large: return 6   // L3
        }
    }
    
    // Colors
    private var backgroundColor: Color {
        guard isContained else { return .clear }
        
        switch type {
        case .secondary:
            return Color("secondaryButtonBackground")  // F3
        case .secondaryEmphasized:
            return Color("secondaryButtonBackground")  // F6
        case .primaryOnMedia:
            return Color("primaryButtonBackgroundOnMedia")  // G3
        case .secondaryOnMediaEmphasized:
            return Color("secondaryButtonBackgroundOnMedia")  // G6
        case .primaryOnColor:
            return Color("primaryButtonBackgroundOnColor")  // H3
        case .secondaryOnColorEmphasized:
            return Color("secondaryButtonBackgroundOnColor")  // H6
        }
    }
    
    private var iconColor: Color {
        if isContained {
            switch type {
            case .secondary:
                return Color("secondaryButtonIcon")  // F1
            case .secondaryEmphasized:
                return Color("secondaryButtonIcon")  // F4
            case .primaryOnMedia:
                return Color("primaryButtonIconOnMedia")  // G1
            case .secondaryOnMediaEmphasized:
                return Color("secondaryButtonIconOnMedia")  // G4
            case .primaryOnColor:
                return Color("primaryButtonIconOnColor")  // H1
            case .secondaryOnColorEmphasized:
                return Color("secondaryButtonIconOnColor")  // H4
            }
        } else {
            switch type {
            case .secondary:
                return Color("secondaryIcon")  // F7
            case .secondaryEmphasized:
                return Color("secondaryIcon")  // F9
            case .primaryOnMedia:
                return Color("primaryIconOnMedia")  // G7
            case .secondaryOnMediaEmphasized:
                return Color("secondaryIconOnMedia")  // G9
            case .primaryOnColor:
                return Color("primaryIconOnColor")  // H7
            case .secondaryOnColorEmphasized:
                return Color("secondaryIconOnColor")  // H9
            }
        }
    }
    
    private var textColor: Color {
        if isContained {
            switch type {
            case .secondary:
                return Color("secondaryButtonText")  // F2
            case .secondaryEmphasized:
                return Color("secondaryButtonText")  // F5
            case .primaryOnMedia:
                return Color("primaryButtonTextOnMedia")  // G2
            case .secondaryOnMediaEmphasized:
                return Color("secondaryButtonTextOnMedia")  // G5
            case .primaryOnColor:
                return Color("primaryButtonTextOnColor")  // H2
            case .secondaryOnColorEmphasized:
                return Color("secondaryButtonTextOnColor")  // H5
            }
        } else {
            switch type {
            case .secondary:
                return Color("secondaryText")  // F8
            case .secondaryEmphasized:
                return Color("secondaryText")  // F10
            case .primaryOnMedia:
                return Color("primaryTextOnMedia")  // G8
            case .secondaryOnMediaEmphasized:
                return Color("secondaryTextOnMedia")  // G10
            case .primaryOnColor:
                return Color("primaryTextOnColor")  // H8
            case .secondaryOnColorEmphasized:
                return Color("secondaryTextOnColor")  // H10
            }
        }
    }
    
    // Shadow - only for uncontained + on media
    private var shouldApplyShadow: Bool {
        return !isContained && isOnMedia
    }
    
    private var isOnMedia: Bool {
        switch type {
        case .primaryOnMedia, .secondaryOnMediaEmphasized:
            return true
        default:
            return false
        }
    }
    
    // Typography
    private var isEmphasized: Bool {
        switch type {
        case .secondaryEmphasized, .secondaryOnMediaEmphasized, .secondaryOnColorEmphasized:
            return true
        default:
            return false
        }
    }
    
    @ViewBuilder
    private func textWithTypography(_ text: String) -> some View {
        switch size {
        case .small:
            if isEmphasized {
                Text(text).body4LinkTypography()  // M2
            } else {
                Text(text).meta4Typography()  // M1
            }
        case .medium:
            if isEmphasized {
                Text(text).body4LinkTypography()  // M4
            } else {
                Text(text).meta4Typography()  // M3
            }
        case .large:
            if isEmphasized {
                Text(text).body4LinkTypography()  // M6
            } else {
                Text(text).meta4Typography()  // M5
            }
        }
    }
}

// MARK: - Shadow Modifier Helpers
private struct TextOnMediaShadowModifier: ViewModifier {
    let isOnMedia: Bool
    
    func body(content: Content) -> some View {
        if isOnMedia {
            content.textOnMediaShadow()
        } else {
            content
        }
    }
}

private struct IconOnMediaShadowModifier: ViewModifier {
    let isOnMedia: Bool
    
    func body(content: Content) -> some View {
        if isOnMedia {
            content.iconOnMediaShadow()
        } else {
            content
        }
    }
}

// MARK: - Info Chips Preview View
struct InfoChipsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSInfoChip",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    // Secondary
                    InfoChipCard(title: "Secondary") {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(type: .secondary, label: "Secondary", size: .large)
                                FDSInfoChip(type: .secondary, label: "Secondary", size: .medium)
                                FDSInfoChip(type: .secondary, label: "Secondary", size: .small)
                            }
                        }
                    }
                    
                    // Secondary Emphasized
                    InfoChipCard(title: "Secondary emphasized") {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(type: .secondaryEmphasized, label: "Emphasized", size: .large)
                                FDSInfoChip(type: .secondaryEmphasized, label: "Emphasized", size: .medium)
                                FDSInfoChip(type: .secondaryEmphasized, label: "Emphasized", size: .small)
                            }
                        }
                    }
                    
                    // With Icons
                    InfoChipCard(title: "With icons") {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    label: "Live",
                                    size: .large,
                                    icon: "play-circle-filled"
                                )
                                FDSInfoChip(
                                    label: "New",
                                    size: .medium,
                                    icon: "star-filled"
                                )
                                FDSInfoChip(
                                    label: "Trending",
                                    size: .small,
                                    icon: "trending-filled"
                                )
                            }
                        }
                    }
                    
                    // Icon Only (Hidden Labels)
                    InfoChipCard(title: "Icon only (hidden labels)") {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    label: "Live",
                                    hideLabel: true,
                                    size: .large,
                                    icon: "play-circle-filled"
                                )
                                FDSInfoChip(
                                    label: "New",
                                    hideLabel: true,
                                    size: .medium,
                                    icon: "star-filled"
                                )
                                FDSInfoChip(
                                    label: "Trending",
                                    hideLabel: true,
                                    size: .small,
                                    icon: "trending-filled"
                                )
                            }
                        }
                    }
                    
                    // Uncontained
                    InfoChipCard(title: "Uncontained") {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    label: "Info",
                                    size: .large,
                                    icon: "info-circle-filled",
                                    isContained: false
                                )
                                FDSInfoChip(
                                    label: "Tag",
                                    size: .medium,
                                    icon: "tag-filled",
                                    isContained: false
                                )
                                FDSInfoChip(
                                    label: "Pin",
                                    size: .small,
                                    icon: "pin-filled",
                                    isContained: false
                                )
                            }
                        }
                    }
                    
                    // On Color
                    InfoChipCard(title: "Primary on color", backgroundType: .purple) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    type: .primaryOnColor,
                                    label: "On color",
                                    size: .large
                                )
                                FDSInfoChip(
                                    type: .primaryOnColor,
                                    label: "Badge",
                                    size: .medium,
                                    icon: "star-filled"
                                )
                            }
                        }
                    }
                    
                    InfoChipCard(title: "Secondary on color emphasized", backgroundType: .purple) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    type: .secondaryOnColorEmphasized,
                                    label: "Emphasized",
                                    size: .large
                                )
                                FDSInfoChip(
                                    type: .secondaryOnColorEmphasized,
                                    label: "Tag",
                                    size: .medium,
                                    icon: "tag-filled"
                                )
                            }
                        }
                    }
                    
                    InfoChipCard(title: "Primary on color uncontained", backgroundType: .purple) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    type: .primaryOnColor,
                                    label: "Uncontained",
                                    size: .large,
                                    icon: "heart-filled",
                                    isContained: false
                                )
                                FDSInfoChip(
                                    type: .primaryOnColor,
                                    label: "Label",
                                    size: .medium,
                                    isContained: false
                                )
                            }
                        }
                    }
                    
                    // On Media
                    InfoChipCard(title: "Primary on media", backgroundType: .media) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    type: .primaryOnMedia,
                                    label: "Live",
                                    size: .large,
                                    icon: "play-circle-filled"
                                )
                                FDSInfoChip(
                                    type: .primaryOnMedia,
                                    label: "4K",
                                    size: .medium
                                )
                            }
                        }
                    }
                    
                    InfoChipCard(title: "Secondary on media emphasized", backgroundType: .media) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    type: .secondaryOnMediaEmphasized,
                                    label: "New",
                                    size: .large,
                                    icon: "star-filled"
                                )
                                FDSInfoChip(
                                    type: .secondaryOnMediaEmphasized,
                                    label: "HD",
                                    size: .medium
                                )
                            }
                        }
                    }
                    
                    InfoChipCard(title: "Primary on media uncontained", backgroundType: .media) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                FDSInfoChip(
                                    type: .primaryOnMedia,
                                    label: "Live",
                                    size: .large,
                                    icon: "play-circle-filled",
                                    isContained: false
                                )
                                FDSInfoChip(
                                    type: .primaryOnMedia,
                                    label: "Streaming",
                                    size: .medium,
                                    icon: "video-filled",
                                    isContained: false
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Helper Card Component
enum InfoChipCardBackground {
    case normal
    case purple
    case media
}

struct InfoChipCard<Content: View>: View {
    let title: String
    let content: Content
    let backgroundType: InfoChipCardBackground
    
    init(title: String, backgroundType: InfoChipCardBackground = .normal, @ViewBuilder content: () -> Content) {
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

// MARK: - Preview
#Preview {
    InfoChipsPreviewView()
}

