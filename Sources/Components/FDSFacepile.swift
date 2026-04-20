import SwiftUI

// MARK: - Facepile Size

enum FDSFacepileSize {
    case xSmall   // 20pt
    case small    // 24pt
    case medium   // 32pt
    case large    // 40pt
    
    var photoSize: CGFloat {
        switch self {
        case .xSmall: return 20
        case .small: return 24
        case .medium: return 32
        case .large: return 40
        }
    }
    
    var borderWidth: CGFloat {
        return 2  // Spec: 2dp ring for all sizes
    }
    
    var overlapOffset: CGFloat {
        return -4  // Spec: -4dp between faces for all sizes
    }
    
    var overflowIconSize: CGFloat {
        switch self {
        case .xSmall: return 10
        case .small: return 12
        case .medium: return 16
        case .large: return 24
        }
    }
}

// MARK: - Facepile Style

enum FDSFacepileStyle {
    case overlap   // Overlapping circles (default)
    case stack     // Side by side with spacing
}

// MARK: - Text Position

enum FDSFacepileTextPosition {
    case inline    // Text next to facepile
    case below     // Text below facepile
}

// MARK: - Facepile Type

enum FDSFacepileType {
    case `default`  // Uses SecondaryText
    case onMedia    // Uses SecondaryTextOnMedia
}

// MARK: - Text Hierarchy Level

enum FDSFacepileTextHierarchy {
    case level3  // Default
    case level4
}

// MARK: - FDSFacepile Component

struct FDSFacepile: View {
    // MARK: - Properties
    
    let profiles: [String]
    let size: FDSFacepileSize
    let style: FDSFacepileStyle
    let maxFacepiles: Int
    let bodyText: AttributedString?
    let textPosition: FDSFacepileTextPosition
    let textHierarchy: FDSFacepileTextHierarchy
    let type: FDSFacepileType
    
    // MARK: - Initializer
    
    init(
        profiles: [String],
        size: FDSFacepileSize = .small,
        style: FDSFacepileStyle = .overlap,
        maxFacepiles: Int = 3,
        bodyText: AttributedString? = nil,
        textPosition: FDSFacepileTextPosition = .inline,
        textHierarchy: FDSFacepileTextHierarchy = .level3,
        type: FDSFacepileType = .default
    ) {
        self.profiles = profiles
        self.size = size
        self.style = style
        self.maxFacepiles = maxFacepiles
        self.bodyText = bodyText
        self.textPosition = textPosition
        self.textHierarchy = textHierarchy
        self.type = type
    }
    
    
    
    // MARK: - Computed Properties
    
    private var visibleProfiles: [String] {
        Array(profiles.prefix(maxFacepiles))
    }
    
    private var overflowCount: Int {
        max(0, profiles.count - maxFacepiles)
    }
    
    private var hasOverflow: Bool {
        overflowCount > 0
    }
    
    private var overflowProfileImage: String? {
        guard profiles.count > maxFacepiles else { return nil }
        return profiles[maxFacepiles]
    }
    
    // MARK: - Body
    
    var body: some View {
        switch textPosition {
        case .inline:
            HStack(spacing: 4) {
                facepileStack
                if let text = bodyText {
                    bodyTextView(text)
                }
            }
        case .below:
            VStack(alignment: .leading, spacing: 8) {  // Spec: 8dp between faces and text
                facepileStack
                if let text = bodyText {
                    bodyTextView(text)
                }
            }
        }
    }
    
    // MARK: - Facepile Stack
    
    @ViewBuilder
    private var facepileStack: some View {
        switch style {
        case .overlap:
            overlappingFacepile
        case .stack:
            stackedFacepile
        }
    }
    
    // MARK: - Overlapping Facepile
    
    private var overlappingFacepile: some View {
        HStack(spacing: 0) {
            ForEach(Array(visibleProfiles.enumerated()), id: \.offset) { index, imageName in
                profilePhoto(imageName: imageName)
                    .padding(.leading, index == 0 ? 0 : size.overlapOffset)
                    .zIndex(Double(visibleProfiles.count - index))
            }
            
            if hasOverflow {
                overflowIndicator
                    .padding(.leading, size.overlapOffset)
                    .zIndex(0)
            }
        }
        .compositingGroup()
    }
    
    // MARK: - Stacked Facepile
    
    private var stackedFacepile: some View {
        HStack(spacing: 4) {
            ForEach(Array(visibleProfiles.enumerated()), id: \.offset) { index, imageName in
                profilePhoto(imageName: imageName)
            }
            
            if hasOverflow {
                overflowIndicator
            }
        }
        .compositingGroup()
    }
    
    // MARK: - Profile Photo
    
    private func profilePhoto(imageName: String) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: size.photoSize, height: size.photoSize)
                .clipShape(Circle())
            
            // Cutout border - uses opaque color to ensure full erasure
            Circle()
                .strokeBorder(Color.black, lineWidth: size.borderWidth)
                .frame(width: size.photoSize + (size.borderWidth * 2), height: size.photoSize + (size.borderWidth * 2))
                .blendMode(.destinationOut)
        }
        .frame(width: size.photoSize, height: size.photoSize)
    }
    
    // MARK: - Overflow Indicator
    
    private var overflowIndicator: some View {
        ZStack {
            // Background profile image
            if let imageName = overflowProfileImage {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.photoSize, height: size.photoSize)
                    .clipShape(Circle())
            }
            
            // Overlay
            Circle()
                .fill(Color("overlayOnMediaLight"))
                .frame(width: size.photoSize, height: size.photoSize)
            
            // Overflow icon
            Image("dots-3-horizontal-filled")
                .resizable()
                .scaledToFit()
                .frame(width: size.overflowIconSize, height: size.overflowIconSize)
                .foregroundStyle(Color("primaryIconOnMedia"))
                .iconOnMediaShadow()
            
            // Cutout border - uses opaque color to ensure full erasure
            Circle()
                .strokeBorder(Color.black, lineWidth: size.borderWidth)
                .frame(width: size.photoSize + (size.borderWidth * 2), height: size.photoSize + (size.borderWidth * 2))
                .blendMode(.destinationOut)
        }
        .frame(width: size.photoSize, height: size.photoSize)
    }
    
    // MARK: - Body Text View
    
    @ViewBuilder
    private func bodyTextView(_ text: AttributedString) -> some View {
        let textColor = type == .onMedia ? Color("secondaryTextOnMedia") : Color("secondaryText")
        
        Group {
            switch textHierarchy {
            case .level3:
                Text(text).meta3Typography()
            case .level4:
                Text(text).meta4Typography()
            }
        }
        .foregroundStyle(textColor)
        .if(type == .onMedia) { view in
            view.textOnMediaShadow()
        }
    }
    
}

// MARK: - AttributedString Extension Helper
extension AttributedString {
    init(plainText: String) {
        self.init(plainText)
    }
}

// MARK: - Facepile Group Card Component
struct FacepileGroupCard<Content: View>: View {
    let title: String
    let content: Content
    let onMedia: Bool
    
    init(title: String, onMedia: Bool = false, @ViewBuilder content: () -> Content) {
        self.title = title
        self.onMedia = onMedia
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                .if(onMedia) { view in
                    view.textOnMediaShadow()
                }
            
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
        if onMedia {
            ZStack {
                Image("image3")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                LinearGradient(
                    stops: [
                        .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                        .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.5),
                        .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        } else {
            Color("cardBackground")
        }
    }
}

// MARK: - Facepile Preview View
struct FacepilePreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Helper function to create attributed strings with bold names
    private func createRichText(_ parts: [(String, Bool)]) -> AttributedString {
        var result = AttributedString()
        for (text, isBold) in parts {
            var part = AttributedString(text)
            if isBold {
                part.font = .system(size: 13, weight: .semibold)
            }
            result.append(part)
        }
        return result
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSFacepile",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    FacepileGroupCard(title: "X-Small (20pt)") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .xSmall,
                                bodyText: "3 friends"
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4", "profile5"],
                                size: .xSmall,
                                maxFacepiles: 3,
                                bodyText: "5 friends were here"
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Small (24pt)") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .small,
                                bodyText: "3 friends like this"
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4", "profile5"],
                                size: .small,
                                maxFacepiles: 3,
                                bodyText: createRichText([("Alex", true), (", ", false), ("Jordan", true), (" and 3 others", false)])
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Medium (32pt)") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .medium,
                                bodyText: createRichText([("Alex", true), (", ", false), ("Jordan", true), (" and ", false), ("Sam", true)])
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4", "profile5", "profile6", "profile7"],
                                size: .medium,
                                maxFacepiles: 4,
                                bodyText: createRichText([("Sarah", true), (", ", false), ("Mike", true), (" and 5 others", false)])
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Large (40pt)") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2"],
                                size: .large,
                                bodyText: createRichText([("Emma", true), (" and ", false), ("Chris", true)])
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4", "profile5"],
                                size: .large,
                                maxFacepiles: 3,
                                bodyText: createRichText([("Taylor", true), (", ", false), ("Dana", true), (" and 3 others", false)])
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Rich text with bold names") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .small,
                                bodyText: createRichText([("Alex", true), (", ", false), ("Dan", true), (" and 20 others", false)])
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4"],
                                size: .medium,
                                maxFacepiles: 3,
                                bodyText: createRichText([("Jamie", true), (" reacted to this", false)])
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Styles") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .medium,
                                style: .overlap,
                                bodyText: "Overlap style"
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .medium,
                                style: .stack,
                                bodyText: "Stack style"
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Text positions") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .small,
                                bodyText: "Inline text position",
                                textPosition: .inline
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .small,
                                bodyText: "Below text position",
                                textPosition: .below
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Without text") {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .medium,
                                bodyText: nil
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4", "profile5"],
                                size: .medium,
                                maxFacepiles: 3,
                                bodyText: nil
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "Text hierarchy level 4", onMedia: false) {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .small,
                                bodyText: "Level 4 text (smaller)",
                                textHierarchy: .level4
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .small,
                                bodyText: "Level 3 text (default)",
                                textHierarchy: .level3
                            )
                        }
                    }
                    
                    FacepileGroupCard(title: "On media type", onMedia: true) {
                        VStack(alignment: .leading, spacing: 8) {
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3"],
                                size: .medium,
                                bodyText: "On media with shadow",
                                type: .onMedia
                            )
                            
                            FDSFacepile(
                                profiles: ["profile1", "profile2", "profile3", "profile4", "profile5"],
                                size: .medium,
                                maxFacepiles: 3,
                                bodyText: "5 people reacted",
                                type: .onMedia
                            )
                        }
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
    FacepilePreviewView()
}
