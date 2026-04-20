import SwiftUI

// MARK: - Enums

enum FDSTextPairingHierarchyLevel {
    case level1
    case level2
    case level3
    case level4
    
    var spacing: CGFloat {
        switch self {
        case .level1: return 14
        case .level2: return 12
        case .level3: return 10
        case .level4: return 10
        }
    }
}

enum FDSTextPairingParentContentType {
    case surface
    case onMedia
    case onColor
}

enum FDSTextPairingHorizontalAlignment {
    case start
    case center
    case end
    
    var textAlignment: TextAlignment {
        switch self {
        case .start: return .leading
        case .center: return .center
        case .end: return .trailing
        }
    }
    
    var alignment: HorizontalAlignment {
        switch self {
        case .start: return .leading
        case .center: return .center
        case .end: return .trailing
        }
    }
}

enum FDSTextPairingMetaPosition {
    case top
    case bottom
}

enum FDSTextPairingHeadlineEmphasis {
    case `default`
    case emphasized
    case deemphasized
}

enum FDSTextPairingBodyEmphasis {
    case `default`
    case emphasized
}

// MARK: - Models

struct FDSTextPairingHeadlineText {
    let text: String
    let maxLines: Int?
    let emphasis: FDSTextPairingHeadlineEmphasis
    
    init(
        text: String,
        maxLines: Int? = nil,
        emphasis: FDSTextPairingHeadlineEmphasis = .default
    ) {
        self.text = text
        self.maxLines = maxLines
        self.emphasis = emphasis
    }
}

struct FDSTextPairingBodyText {
    let text: String
    let maxLines: Int?
    
    init(
        text: String,
        maxLines: Int? = nil
    ) {
        self.text = text
        self.maxLines = maxLines
    }
}

struct FDSTextPairingMetaText {
    let text: String
    let maxLines: Int?
    let metaPosition: FDSTextPairingMetaPosition
    
    init(
        text: String,
        maxLines: Int? = nil,
        metaPosition: FDSTextPairingMetaPosition = .bottom
    ) {
        self.text = text
        self.maxLines = maxLines
        self.metaPosition = metaPosition
    }
}

// MARK: - FDSTextPairing Component

struct FDSTextPairing: View {
    // Required
    let hierarchyLevel: FDSTextPairingHierarchyLevel
    
    // Optional configuration
    let parentContentType: FDSTextPairingParentContentType
    let horizontalAlignment: FDSTextPairingHorizontalAlignment
    let removeBoundingBox: Bool
    
    // Headline
    let headlineText: FDSTextPairingHeadlineText?
    let headlineTextColor: String?
    
    // Body
    let bodyText: FDSTextPairingBodyText?
    let bodyTextColor: String?
    let bodyTextEmphasis: FDSTextPairingBodyEmphasis
    
    // Meta
    let metaText: FDSTextPairingMetaText?
    let metaTextColor: String?
    
    init(
        hierarchyLevel: FDSTextPairingHierarchyLevel,
        parentContentType: FDSTextPairingParentContentType = .surface,
        horizontalAlignment: FDSTextPairingHorizontalAlignment = .start,
        removeBoundingBox: Bool = true,
        headlineText: FDSTextPairingHeadlineText? = nil,
        headlineTextColor: String? = nil,
        bodyText: FDSTextPairingBodyText? = nil,
        bodyTextColor: String? = nil,
        bodyTextEmphasis: FDSTextPairingBodyEmphasis = .default,
        metaText: FDSTextPairingMetaText? = nil,
        metaTextColor: String? = nil
    ) {
        self.hierarchyLevel = hierarchyLevel
        self.parentContentType = parentContentType
        self.horizontalAlignment = horizontalAlignment
        self.removeBoundingBox = removeBoundingBox
        self.headlineText = headlineText
        self.headlineTextColor = headlineTextColor
        self.bodyText = bodyText
        self.bodyTextColor = bodyTextColor
        self.bodyTextEmphasis = bodyTextEmphasis
        self.metaText = metaText
        self.metaTextColor = metaTextColor
    }
    
    var body: some View {
        VStack(alignment: horizontalAlignment.alignment, spacing: hierarchyLevel.spacing) {
            // Meta text at top (if position is top)
            if let metaText = metaText, metaText.metaPosition == .top {
                styledText(
                    text: metaText.text,
                    maxLines: metaText.maxLines,
                    color: metaTextColor,
                    type: .meta,
                    headlineEmphasis: nil
                )
            }
            
            // Headline text
            if let headlineText = headlineText {
                styledText(
                    text: headlineText.text,
                    maxLines: headlineText.maxLines,
                    color: headlineTextColor,
                    type: .headline,
                    headlineEmphasis: headlineText.emphasis
                )
            }
            
            // Body text
            if let bodyText = bodyText {
                styledText(
                    text: bodyText.text,
                    maxLines: bodyText.maxLines,
                    color: bodyTextColor,
                    type: .body,
                    headlineEmphasis: nil
                )
            }
            
            // Meta text at bottom (if position is bottom)
            if let metaText = metaText, metaText.metaPosition == .bottom {
                styledText(
                    text: metaText.text,
                    maxLines: metaText.maxLines,
                    color: metaTextColor,
                    type: .meta,
                    headlineEmphasis: nil
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: horizontalAlignment.alignment, vertical: .center))
        .multilineTextAlignment(horizontalAlignment.textAlignment)
    }
    
    // MARK: - Text Type
    
    private enum TextType {
        case headline
        case body
        case meta
    }
    
    // MARK: - Styled Text Builder
    
    @ViewBuilder
    private func styledText(
        text: String,
        maxLines: Int?,
        color: String?,
        type: TextType,
        headlineEmphasis: FDSTextPairingHeadlineEmphasis?
    ) -> some View {
        // Use LocalizedStringKey to enable Markdown parsing
        let textView = Text(LocalizedStringKey(text))
        let styledText = applyTypography(
            to: textView,
            type: type,
            headlineEmphasis: headlineEmphasis
        )
        let coloredText = applyColor(
            to: styledText,
            customColor: color,
            type: type
        )
        
        if let maxLines = maxLines {
            coloredText
                .lineLimit(maxLines)
        } else {
            coloredText
        }
    }
    
    // MARK: - Typography Application
    
    private func applyTypography(
        to text: Text,
        type: TextType,
        headlineEmphasis: FDSTextPairingHeadlineEmphasis?
    ) -> some View {
        Group {
            switch type {
            case .headline:
                applyHeadlineTypography(to: text, emphasis: headlineEmphasis ?? .default)
            case .body:
                applyBodyTypography(to: text)
            case .meta:
                applyMetaTypography(to: text)
            }
        }
    }
    
    @ViewBuilder
    private func applyHeadlineTypography(to text: Text, emphasis: FDSTextPairingHeadlineEmphasis) -> some View {
        switch hierarchyLevel {
        case .level1:
            // Level 1 always uses headline1Emphasized
            text.headline1EmphasizedTypography()
            
        case .level2:
            // Level 2 always uses headline2Emphasized
            text.headline2EmphasizedTypography()
            
        case .level3:
            // Level 3 supports all emphasis levels
            switch emphasis {
            case .emphasized:
                text.headline3EmphasizedTypography()
            case .default:
                text.headline3Typography()
            case .deemphasized:
                text.headline3DeemphasizedTypography()
            }
            
        case .level4:
            // Level 4 supports all emphasis levels
            switch emphasis {
            case .emphasized:
                text.headline4EmphasizedTypography()
            case .default:
                text.headline4Typography()
            case .deemphasized:
                text.headline4DeemphasizedTypography()
            }
        }
    }
    
    @ViewBuilder
    private func applyBodyTypography(to text: Text) -> some View {
        switch hierarchyLevel {
        case .level1:
            text.body1Typography()
            
        case .level2:
            text.body2Typography()
            
        case .level3:
            switch bodyTextEmphasis {
            case .default:
                text.body3Typography()
            case .emphasized:
                text.body3LinkTypography()
            }
            
        case .level4:
            switch bodyTextEmphasis {
            case .default:
                text.body4Typography()
            case .emphasized:
                text.body4LinkTypography()
            }
        }
    }
    
    @ViewBuilder
    private func applyMetaTypography(to text: Text) -> some View {
        switch hierarchyLevel {
        case .level1:
            text.meta1Typography()
        case .level2:
            text.meta2Typography()
        case .level3:
            text.meta3Typography()
        case .level4:
            text.meta4Typography()
        }
    }
    
    // MARK: - Color Application
    
    @ViewBuilder
    private func applyColor<T: View>(to view: T, customColor: String?, type: TextType) -> some View {
        let colorName = customColor ?? getDefaultColor(for: type)
        
        if parentContentType == .onMedia {
            view
                .foregroundStyle(Color(colorName))
                .textOnMediaShadow()
        } else {
            view.foregroundStyle(Color(colorName))
        }
    }
    
    // MARK: - Default Color Logic
    
    private func getDefaultColor(for type: TextType) -> String {
        let suffix: String
        switch parentContentType {
        case .surface:
            suffix = ""
        case .onMedia:
            suffix = "OnMedia"
        case .onColor:
            suffix = "OnColor"
        }
        
        switch type {
        case .headline:
            return "primaryText\(suffix)"
            
        case .body:
            // Body is secondaryText if headline exists and meta doesn't
            if headlineText != nil && metaText == nil {
                return "secondaryText\(suffix)"
            } else {
                return "primaryText\(suffix)"
            }
            
        case .meta:
            return "secondaryText\(suffix)"
        }
    }
}

// MARK: - Text Pairing Card Component
struct TextPairingCard<Content: View>: View {
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

// MARK: - FDSTextPairing Preview View
struct FDSTextPairingPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSTextPairing",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    // Hierarchy Levels
                    TextPairingCard(title: "Level 1") {
                        FDSTextPairing(
                            hierarchyLevel: .level1,
                            headlineText: FDSTextPairingHeadlineText(text: "Headline level 1"),
                            bodyText: FDSTextPairingBodyText(text: "Body text for level 1 with longer content to show multiple lines"),
                            metaText: FDSTextPairingMetaText(text: "Meta text")
                        )
                    }
                    
                    TextPairingCard(title: "Level 2") {
                        FDSTextPairing(
                            hierarchyLevel: .level2,
                            headlineText: FDSTextPairingHeadlineText(text: "Headline level 2"),
                            bodyText: FDSTextPairingBodyText(text: "Body text for level 2 with longer content"),
                            metaText: FDSTextPairingMetaText(text: "Meta text")
                        )
                    }
                    
                    TextPairingCard(title: "Level 3") {
                        FDSTextPairing(
                            hierarchyLevel: .level3,
                            headlineText: FDSTextPairingHeadlineText(text: "Headline level 3"),
                            bodyText: FDSTextPairingBodyText(text: "Body text for level 3"),
                            metaText: FDSTextPairingMetaText(text: "Meta text")
                        )
                    }
                    
                    TextPairingCard(title: "Level 4") {
                        FDSTextPairing(
                            hierarchyLevel: .level4,
                            headlineText: FDSTextPairingHeadlineText(text: "Headline level 4"),
                            bodyText: FDSTextPairingBodyText(text: "Body text for level 4"),
                            metaText: FDSTextPairingMetaText(text: "Meta text")
                        )
                    }
                    
                    // Headline Emphasis
                    TextPairingCard(title: "Headline emphasis (Level 4)") {
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level4,
                                headlineText: FDSTextPairingHeadlineText(text: "Emphasized", emphasis: .emphasized),
                                bodyText: FDSTextPairingBodyText(text: "Body text")
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level4,
                                headlineText: FDSTextPairingHeadlineText(text: "Default", emphasis: .default),
                                bodyText: FDSTextPairingBodyText(text: "Body text")
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level4,
                                headlineText: FDSTextPairingHeadlineText(text: "Deemphasized", emphasis: .deemphasized),
                                bodyText: FDSTextPairingBodyText(text: "Body text")
                            )
                        }
                    }
                    
                    // Body Emphasis
                    TextPairingCard(title: "Body emphasis (Level 3)") {
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline"),
                                bodyText: FDSTextPairingBodyText(text: "Default body text"),
                                bodyTextEmphasis: .default
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline"),
                                bodyText: FDSTextPairingBodyText(text: "Emphasized body text"),
                                bodyTextEmphasis: .emphasized
                            )
                        }
                    }
                    
                    // Alignment
                    TextPairingCard(title: "Horizontal alignment") {
                        VStack(spacing: 16) {
                            VStack(spacing: 0) {
                                FDSTextPairing(
                                    hierarchyLevel: .level3,
                                    horizontalAlignment: .start,
                                    headlineText: FDSTextPairingHeadlineText(text: "Start alignment"),
                                    bodyText: FDSTextPairingBodyText(text: "Text aligned to start")
                                )
                            }
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("borderResponsiveUi"), lineWidth: 1)
                            )
                            
                            VStack(spacing: 0) {
                                FDSTextPairing(
                                    hierarchyLevel: .level3,
                                    horizontalAlignment: .center,
                                    headlineText: FDSTextPairingHeadlineText(text: "Center alignment"),
                                    bodyText: FDSTextPairingBodyText(text: "Text centered")
                                )
                            }
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("borderResponsiveUi"), lineWidth: 1)
                            )
                            
                            VStack(spacing: 0) {
                                FDSTextPairing(
                                    hierarchyLevel: .level3,
                                    horizontalAlignment: .end,
                                    headlineText: FDSTextPairingHeadlineText(text: "End alignment"),
                                    bodyText: FDSTextPairingBodyText(text: "Text aligned to end")
                                )
                            }
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("borderResponsiveUi"), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Meta Position
                    TextPairingCard(title: "Meta position") {
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline"),
                                bodyText: FDSTextPairingBodyText(text: "Body text"),
                                metaText: FDSTextPairingMetaText(text: "Meta at top", metaPosition: .top)
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline"),
                                bodyText: FDSTextPairingBodyText(text: "Body text"),
                                metaText: FDSTextPairingMetaText(text: "Meta at bottom", metaPosition: .bottom)
                            )
                        }
                    }
                    
                    // Optional Text
                    TextPairingCard(title: "Optional text") {
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline only")
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline"),
                                bodyText: FDSTextPairingBodyText(text: "Body becomes secondary text")
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                bodyText: FDSTextPairingBodyText(text: "Body without headline"),
                                metaText: FDSTextPairingMetaText(text: "Meta text")
                            )
                        }
                    }
                    
                    // Custom Colors
                    TextPairingCard(title: "Custom colors") {
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Custom headline"),
                                headlineTextColor: "accentColor",
                                bodyText: FDSTextPairingBodyText(text: "Body text")
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Headline"),
                                bodyText: FDSTextPairingBodyText(text: "Custom body"),
                                bodyTextColor: "accentColor"
                            )
                        }
                    }
                    
                    // Rich Text (Markdown)
                    TextPairingCard(title: "Rich text with Markdown") {
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "**Bold headline** with emphasis"),
                                bodyText: FDSTextPairingBodyText(text: "Body text with **bold**, *italic*, and [a link](https://facebook.com)")
                            )
                            
                            FDSTextPairing(
                                hierarchyLevel: .level3,
                                headlineText: FDSTextPairingHeadlineText(text: "Mixed formatting"),
                                bodyText: FDSTextPairingBodyText(text: "Reacted by **Sarah**, **John**, and **15 others**"),
                                metaText: FDSTextPairingMetaText(text: "*2 hours ago*")
                            )
                        }
                    }
                    
                    // On Media Variants
                    VStack(spacing: 0) {
                        Text("On media variants")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .textOnMediaShadow()
                        
                        VStack(spacing: 16) {
                            FDSTextPairing(
                                hierarchyLevel: .level2,
                                parentContentType: .onMedia,
                                headlineText: FDSTextPairingHeadlineText(text: "Text on media"),
                                bodyText: FDSTextPairingBodyText(text: "This text has proper shadows for visibility"),
                                metaText: FDSTextPairingMetaText(text: "2 hours ago")
                            )
                            .padding(12)
                        }
                    }
                    .padding(.bottom, 12)
                    .background(
                        ZStack {
                            Image("image3")
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                            LinearGradient(
                                stops: [
                                    .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                    .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                    .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                    .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    )
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    FDSTextPairingPreviewView()
}
