import SwiftUI

// MARK: - Media Card Size

enum FDSMediaCardSize {
    case small      // 120pt width
    case medium     // 160pt width
    case large      // 200pt width
    case flexible   // Fills available width
    
    var width: CGFloat? {
        switch self {
        case .small: return 120
        case .medium: return 160
        case .large: return 200
        case .flexible: return nil
        }
    }
}

// MARK: - Media Card Type

enum FDSMediaCardType {
    case surface    // No shadow, with border
    case elevated   // With shadow
}

// MARK: - Media Card Aspect Ratio

enum FDSMediaCardAspectRatio {
    case square         // 1:1
    case portrait       // 3:4
    case landscape      // 4:3
    case widescreen     // 16:9
    
    var ratio: CGFloat {
        switch self {
        case .square: return 1.0
        case .portrait: return 3.0 / 4.0
        case .landscape: return 4.0 / 3.0
        case .widescreen: return 16.0 / 9.0
        }
    }
}

// MARK: - Media Card Media Type

enum FDSMediaCardMedia {
    case image(String)
    case asyncImage(URL)
    case color(Color)
}

// MARK: - Media Card Height Mode

enum FDSMediaCardHeightMode {
    case constrained    // Natural height (default)
    case flexible       // Grows to fill parent, pins bottom add-ons to bottom
}

// MARK: - Media Card Bottom Add On

enum FDSMediaCardBottomAddOn {
    case facepile(profiles: [String], text: String)
    case custom(AnyView)
}

// MARK: - Media Card Additional Bottom Add On

enum FDSMediaCardAdditionalBottomAddOn {
    case button(type: FDSButtonType, label: String, action: () -> Void)
    case custom(AnyView)
}

// MARK: - Media Card Overlay

enum FDSMediaCardOverlay {
    case none
    case gradient       // Bottom gradient for text readability
    case scrim          // Full overlay scrim
}

// MARK: - FDSMediaCard Component

struct FDSMediaCard: View {
    // MARK: - Properties
    
    let media: FDSMediaCardMedia
    let size: FDSMediaCardSize
    let aspectRatio: FDSMediaCardAspectRatio
    let cardType: FDSMediaCardType
    let overlay: FDSMediaCardOverlay
    let hierarchyLevel: FDSTextPairingHierarchyLevel
    let headlineText: FDSTextPairingHeadlineText?
    let bodyText: FDSTextPairingBodyText?
    let metaText: FDSTextPairingMetaText?
    let bottomAddOn: FDSMediaCardBottomAddOn?
    let additionalBottomAddOn: FDSMediaCardAdditionalBottomAddOn?
    let heightMode: FDSMediaCardHeightMode
    let onMediaOverlay: AnyView?
    let action: (() -> Void)?
    
    // MARK: - Initializer (Full Control)
    
    init(
        media: FDSMediaCardMedia,
        size: FDSMediaCardSize = .medium,
        aspectRatio: FDSMediaCardAspectRatio = .portrait,
        cardType: FDSMediaCardType = .elevated,
        overlay: FDSMediaCardOverlay = .none,
        hierarchyLevel: FDSTextPairingHierarchyLevel = .level3,
        headlineText: FDSTextPairingHeadlineText? = nil,
        bodyText: FDSTextPairingBodyText? = nil,
        metaText: FDSTextPairingMetaText? = nil,
        bottomAddOn: FDSMediaCardBottomAddOn? = nil,
        additionalBottomAddOn: FDSMediaCardAdditionalBottomAddOn? = nil,
        heightMode: FDSMediaCardHeightMode = .constrained,
        onMediaOverlay: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.media = media
        self.size = size
        self.aspectRatio = aspectRatio
        self.cardType = cardType
        self.overlay = overlay
        self.hierarchyLevel = hierarchyLevel
        self.headlineText = headlineText
        self.bodyText = bodyText
        self.metaText = metaText
        self.bottomAddOn = bottomAddOn
        self.additionalBottomAddOn = additionalBottomAddOn
        self.heightMode = heightMode
        self.onMediaOverlay = onMediaOverlay
        self.action = action
    }
    
    // MARK: - Convenience Initializer (Simple Strings)
    
    init(
        media: FDSMediaCardMedia,
        size: FDSMediaCardSize = .medium,
        aspectRatio: FDSMediaCardAspectRatio = .portrait,
        cardType: FDSMediaCardType = .elevated,
        overlay: FDSMediaCardOverlay = .none,
        hierarchyLevel: FDSTextPairingHierarchyLevel = .level3,
        headlineText: String? = nil,
        bodyText: String? = nil,
        metaText: String? = nil,
        bottomAddOn: FDSMediaCardBottomAddOn? = nil,
        additionalBottomAddOn: FDSMediaCardAdditionalBottomAddOn? = nil,
        heightMode: FDSMediaCardHeightMode = .constrained,
        onMediaOverlay: AnyView? = nil,
        action: (() -> Void)? = nil
    ) {
        self.media = media
        self.size = size
        self.aspectRatio = aspectRatio
        self.cardType = cardType
        self.overlay = overlay
        self.hierarchyLevel = hierarchyLevel
        self.headlineText = headlineText.map { FDSTextPairingHeadlineText(text: $0) }
        self.bodyText = bodyText.map { FDSTextPairingBodyText(text: $0) }
        self.metaText = metaText.map { FDSTextPairingMetaText(text: $0) }
        self.bottomAddOn = bottomAddOn
        self.additionalBottomAddOn = additionalBottomAddOn
        self.heightMode = heightMode
        self.onMediaOverlay = onMediaOverlay
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        if let action = action {
            Button(action: action) {
                cardContent
            }
            .buttonStyle(FDSPressedState(cornerRadius: 12))
        } else {
            cardContent
        }
    }
    
    // MARK: - Card Content
    
    private var cardContent: some View {
        VStack(spacing: 0) {
            // Media section
            mediaSection
            
            // Text and add-ons section
            if hasTextOrAddOns {
                contentSection
            }
        }
        .frame(width: size.width)
        .frame(maxHeight: heightMode == .flexible ? .infinity : nil)
        .background(Color("cardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .modifier(CardStyleModifier(cardType: cardType))
    }
    
    // MARK: - Has Text or Add-Ons
    
    private var hasTextOrAddOns: Bool {
        headlineText != nil || bodyText != nil || metaText != nil || 
        bottomAddOn != nil || additionalBottomAddOn != nil
    }
    
    // MARK: - Media Section
    
    private var mediaSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Media content
                mediaContent
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Overlay
                overlayView
                
                // On-media overlay content
                if let onMediaOverlay = onMediaOverlay {
                    onMediaOverlay
                }
                
                // Media inner border on bottom (when there's content below)
                if hasTextOrAddOns {
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color("mediaInnerBorder"))
                            .frame(height: 0.5)
                    }
                }
            }
        }
        .aspectRatio(aspectRatio.ratio, contentMode: .fit)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 12,
                bottomLeadingRadius: hasTextOrAddOns ? 0 : 12,
                bottomTrailingRadius: hasTextOrAddOns ? 0 : 12,
                topTrailingRadius: 12
            )
        )
    }
    
    // MARK: - Media Content
    
    @ViewBuilder
    private var mediaContent: some View {
        switch media {
        case .image(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
            
        case .asyncImage(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Color("glimmerBaseOpaque")
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Color("backgroundDeemphasized")
                        .overlay(
                            Image("image-outline")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color("secondaryIcon"))
                        )
                @unknown default:
                    Color("backgroundDeemphasized")
                }
            }
            
        case .color(let color):
            color
        }
    }
    
    // MARK: - Overlay View
    
    @ViewBuilder
    private var overlayView: some View {
        switch overlay {
        case .none:
            EmptyView()
            
        case .gradient:
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.6)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            
        case .scrim:
            Color.black.opacity(0.4)
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(spacing: 0) {
            if heightMode == .flexible {
                VStack(spacing: 0) {
                    // Text pairing (top)
                    textPairingSection
                        .padding(12)
                    
                    Spacer(minLength: 0)
                    
                    // Bottom add-ons (pinned to bottom)
                    bottomAddOnsSection
                }
            } else {
                // Text pairing
                textPairingSection
                    .padding(12)
                
                // Bottom add-ons
                bottomAddOnsSection
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
    }
    
    // MARK: - Text Pairing Section
    
    @ViewBuilder
    private var textPairingSection: some View {
        if headlineText != nil || bodyText != nil || metaText != nil {
            FDSTextPairing(
                hierarchyLevel: hierarchyLevel,
                headlineText: headlineText,
                bodyText: bodyText,
                metaText: metaText
            )
        }
    }
    
    // MARK: - Bottom Add-Ons Section
    
    @ViewBuilder
    private var bottomAddOnsSection: some View {
        VStack(spacing: 0) {
            // Bottom add-on (Facepile)
            if let bottomAddOn = bottomAddOn {
                VStack(spacing: 0) {
                    switch bottomAddOn {
                    case .facepile(let profiles, let text):
        FDSFacepile(
            profiles: profiles,
            size: .xSmall,
            maxFacepiles: 3,
            bodyText: AttributedString(text)
        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.top, (headlineText != nil || bodyText != nil || metaText != nil) ? 0 : 12)
                        .padding(.bottom, additionalBottomAddOn != nil ? 8 : 12)
                        
                    case .custom(let view):
                        view
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.top, (headlineText != nil || bodyText != nil || metaText != nil) ? 0 : 12)
                            .padding(.bottom, additionalBottomAddOn != nil ? 8 : 12)
                    }
                }
            }
            
            // Additional bottom add-on (Button)
            if let additionalBottomAddOn = additionalBottomAddOn {
                VStack(spacing: 0) {
                    switch additionalBottomAddOn {
                    case .button(let type, let label, let action):
        FDSButton(
            type: type,
            label: label,
            size: .small,
            widthMode: .flexible,
            action: action
        )
                        .padding(.horizontal, 12)
                        .padding(.top, 0)
                        .padding(.bottom, 12)
                        
                    case .custom(let view):
                        view
                            .padding(.horizontal, 12)
                            .padding(.top, 0)
                            .padding(.bottom, 12)
                    }
                }
            }
        }
    }
}

// MARK: - Card Style Modifier

fileprivate struct CardStyleModifier: ViewModifier {
    let cardType: FDSMediaCardType
    
    func body(content: Content) -> some View {
        switch cardType {
        case .surface:
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color("borderUiEmphasis"), lineWidth: 1)
                )
        case .elevated:
            content
                .uiEmphasisShadow()
        }
    }
}

// MARK: - Media Card Group Component
struct MediaCardGroup<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(Color("primaryText"))
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Media Card Preview View

struct MediaCardPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSMediaCard",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    MediaCardGroup(title: "Sizes") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .small,
                                    headlineText: "Small",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    headlineText: "Medium",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image3"),
                                    size: .large,
                                    headlineText: "Large",
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Aspect ratios") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .medium,
                                    aspectRatio: .square,
                                    headlineText: "Square",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    aspectRatio: .portrait,
                                    headlineText: "Portrait",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image3"),
                                    size: .medium,
                                    aspectRatio: .landscape,
                                    headlineText: "Landscape",
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Card types") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .medium,
                                    cardType: .surface,
                                    headlineText: "Surface",
                                    bodyText: "With border",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    cardType: .elevated,
                                    headlineText: "Elevated",
                                    bodyText: "With shadow",
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Hierarchy levels") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .medium,
                                    hierarchyLevel: .level2,
                                    headlineText: FDSTextPairingHeadlineText(text: "Level 2"),
                                    bodyText: FDSTextPairingBodyText(text: "Larger text"),
                                    metaText: FDSTextPairingMetaText(text: "Meta text"),
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    hierarchyLevel: .level3,
                                    headlineText: FDSTextPairingHeadlineText(text: "Level 3"),
                                    bodyText: FDSTextPairingBodyText(text: "Default sizing"),
                                    metaText: FDSTextPairingMetaText(text: "Meta text"),
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image3"),
                                    size: .medium,
                                    hierarchyLevel: .level4,
                                    headlineText: FDSTextPairingHeadlineText(text: "Level 4"),
                                    bodyText: FDSTextPairingBodyText(text: "Smaller sizing"),
                                    metaText: FDSTextPairingMetaText(text: "Meta text"),
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Headline emphasis") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .medium,
                                    headlineText: FDSTextPairingHeadlineText(text: "Emphasized", emphasis: .emphasized),
                                    bodyText: FDSTextPairingBodyText(text: "Body text"),
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    headlineText: FDSTextPairingHeadlineText(text: "Default", emphasis: .default),
                                    bodyText: FDSTextPairingBodyText(text: "Body text"),
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image3"),
                                    size: .medium,
                                    headlineText: FDSTextPairingHeadlineText(text: "Deemphasized", emphasis: .deemphasized),
                                    bodyText: FDSTextPairingBodyText(text: "Body text"),
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Media overlays") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .medium,
                                    overlay: .none,
                                    headlineText: "No overlay",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    overlay: .gradient,
                                    headlineText: "Gradient",
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image3"),
                                    size: .medium,
                                    overlay: .scrim,
                                    headlineText: "Scrim",
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Bottom add-ons") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FDSMediaCard(
                                    media: .image("image1"),
                                    size: .medium,
                                    headlineText: "Event name",
                                    bodyText: "Tomorrow at 7 PM",
                                    bottomAddOn: .facepile(profiles: ["profile1", "profile2", "profile3"], text: "3 friends going"),
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image2"),
                                    size: .medium,
                                    headlineText: "Product name",
                                    bodyText: "$49.99",
                                    additionalBottomAddOn: .button(type: .secondary, label: "View", action: {}),
                                    action: {}
                                )
                                
                                FDSMediaCard(
                                    media: .image("image3"),
                                    size: .medium,
                                    headlineText: "Event name",
                                    bodyText: "Saturday at 2 PM",
                                    bottomAddOn: .facepile(profiles: ["profile1", "profile2", "profile3"], text: "3 friends going"),
                                    additionalBottomAddOn: .button(type: .primary, label: "Join", action: {}),
                                    action: {}
                                )
                            }
                            .padding(.leading, 12)
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, -12)
                    }
                    
                    MediaCardGroup(title: "Height mode") {
                        HStack(spacing: 12) {
                            FDSMediaCard(
                                media: .image("image1"),
                                size: .medium,
                                aspectRatio: .square,
                                headlineText: "Constrained",
                                bodyText: "Natural height",
                                bottomAddOn: .facepile(profiles: ["profile1", "profile2"], text: "2 friends"),
                                additionalBottomAddOn: .button(type: .secondary, label: "View", action: {}),
                                heightMode: .constrained,
                                action: {}
                            )
                            
                            FDSMediaCard(
                                media: .image("image2"),
                                size: .medium,
                                aspectRatio: .square,
                                headlineText: "Flexible",
                                bodyText: "Pins to bottom",
                                additionalBottomAddOn: .button(type: .secondary, label: "View", action: {}),
                                heightMode: .flexible,
                                action: {}
                            )
                        }
                        .frame(height: 320)
                    }
                    
                    MediaCardGroup(title: "Interactive card") {
                        FDSMediaCard(
                            media: .image("image1"),
                            size: .flexible,
                            aspectRatio: .landscape,
                            cardType: .elevated,
                            headlineText: "Tap me!",
                            bodyText: "This card is interactive",
                            action: {
                                print("Card tapped!")
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview

#Preview {
    MediaCardPreviewView()
}
