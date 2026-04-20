import SwiftUI

// MARK: - Composer View
struct ComposerView: View {
    let onPost: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var postText: String = ""
    @State private var selectedAudience: String = "Public"
    @State private var instagramOn: Bool = true
    @State private var threadsOn: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "New post",
                backAction: { dismiss() },
                backIcon: "cross-filled",
                icon1: {
                    FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                }
            )
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        userProfileSection
                        actionChipsSection
                        textInputSection
                        
                        Spacer()
                            .frame(minHeight: 0)
                        
                        actionTilesSection
                    }
                    .frame(minHeight: geometry.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollDismissesKeyboard(.interactively)
            }
            .background(Color("surfaceBackground"))
            bottomBar
        }
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Subviews
    
    private var userProfileSection: some View {
            HStack(spacing: 12) {
            Image("profile1")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            Text("Daniela Giménez")
                .headline3EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .background(Color("surfaceBackground"))
    }
    
    private var actionChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FDSActionChip(
                    size: .medium,
                    label: "Music",
                    leftAddOn: .icon("music-filled"),
                    isEmphasized: true,
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "People",
                    leftAddOn: .icon("friend-tag-filled"),
                    isEmphasized: true,
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Location",
                    leftAddOn: .icon("pin-filled"),
                    isEmphasized: true,
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Feeling/activity",
                    leftAddOn: .icon("face-happy-filled"),
                    isEmphasized: true,
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Event",
                    leftAddOn: .icon("calendar-add-filled"),
                    isEmphasized: true,
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Fundraiser",
                    leftAddOn: .icon("fundraiser-filled"),
                    isEmphasized: true,
                    action: {}
                )
                
                FDSActionChip(
                    size: .medium,
                    label: "Album",
                    leftAddOn: .icon("photo-album-filled"),
                    isEmphasized: true,
                    action: {}
                )
            }
            .padding(.horizontal, 12)
        }
        .background(Color("surfaceBackground"))
    }
    
    private var textInputSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if postText.isEmpty {
                    Text("What's on your mind?")
                        .body1Typography()
                        .foregroundStyle(Color("secondaryText"))
                        .padding(.horizontal, 12)
                        .padding(.top, 20)
                        .allowsHitTesting(false)
                }
                
                TextField("", text: $postText, axis: .vertical)
                    .body1Typography()
                    .foregroundStyle(Color("primaryText"))
                    .tint(Color("logo"))
                    .lineLimit(5...15)
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
            }
        }
        .background(Color("surfaceBackground"))
        .padding(.bottom, -12)
    }
    
    private var actionTilesSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FDSActionTile(
                    type: .elevated,
                    hierarchyLevel: .level4,
                    topAddOn: .icon("photo-square-outline"),
                    horizontalAlignment: .center,
                    headline: "Gallery",
                    action: {}
                )
                .frame(width: 101.5)
                
                FDSActionTile(
                    type: .elevated,
                    hierarchyLevel: .level4,
                    topAddOn: .icon("gen-ai-imagine-outline"),
                    horizontalAlignment: .center,
                    headline: "AI media",
                    action: {}
                )
                .frame(width: 101.5)
                
                FDSActionTile(
                    type: .elevated,
                    hierarchyLevel: .level4,
                    topAddOn: .icon("gif-outline"),
                    horizontalAlignment: .center,
                    headline: "GIF",
                    action: {}
                )
                .frame(width: 101.5)
                
                FDSActionTile(
                    type: .elevated,
                    hierarchyLevel: .level4,
                    topAddOn: .icon("life-event-outline"),
                    horizontalAlignment: .center,
                    headline: "Life event",
                    action: {}
                )
                .frame(width: 101.5)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
        }
        .background(Color("surfaceBackground"))
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color("borderPersistentUi"))
                .frame(height: 1)
            
            HStack(spacing: 0) {
                HStack(spacing: 8) {
                    FDSActionChip(
                        type: .secondary,
                        size: .medium,
                        label: selectedAudience,
                        leftAddOn: .icon("globe-americas-filled"),
                        isEmphasized: true,
                        action: {}
                    )
                    
                    FDSActionChip(
                        type: .secondary,
                        size: .medium,
                        label: "On",
                        leftAddOn: .icon("app-instagram-filled"),
                        isEmphasized: true,
                        action: {}
                    )
                    
                    FDSActionChip(
                        type: .secondary,
                        size: .medium,
                        label: "On",
                        leftAddOn: .icon("app-threads-filled"),
                        isEmphasized: true,
                        action: {}
                    )
                }
                .padding(.leading, 12)
                
                Spacer()
                
                FDSButton(
                    type: .primary,
                    label: "Post",
                    size: .large,
                    isDisabled: postText.isEmpty,
                    widthMode: .constrained,
                    action: {
                        if !postText.isEmpty {
                            onPost(postText)
                            dismiss()
                        }
                    }
                )
                .padding(.trailing, 12)
            }
            .padding(.vertical, 12)
        }
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Preview
#Preview {
    ComposerView(onPost: { text in
        print("Posted: \(text)")
    })
}
