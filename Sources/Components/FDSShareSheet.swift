import SwiftUI


// MARK: - Share Bottom Sheet


struct ShareBottomSheet: View {
    let post: PostData
    let onShare: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var shareText: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        FDSBottomSheet(fitContent: false) {
            ScrollView {
                VStack(spacing: 0) {
                    // Post Composer Card
                    postComposerCard
                    
                    // Send in Messenger Section
                    FDSUnitHeader(
                        headlineText: "Send in Messenger",
                        hierarchyLevel: .level3
                    )
                    
                    messengerContactsScroll
                    
                    // Share to Section
                    FDSUnitHeader(
                        headlineText: "Share to",
                        hierarchyLevel: .level3
                    )
                    
                    shareOptionsScroll
                }
                .padding(.top, 4)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollBounceBehavior(.basedOnSize)
        }
        .presentationDetents([.height(528)])
    }
    
    // MARK: - Post Composer Card
    
    private var postComposerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with profile and name
            HStack(alignment: .top, spacing: 8) {
                Image("profile1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daniela Giménez")
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                        .padding(.top, 4)
                    
                    // Dropdown buttons
                    HStack(spacing: 8) {
                        FDSButton(
                            type: .secondary,
                            label: "Feed",
                            size: .small,
                            widthMode: .constrained,
                            isMenuButton: true,
                            action: {}
                        )
                        
                        FDSButton(
                            type: .secondary,
                            label: "Friends",
                            icon: "friends-filled",
                            size: .small,
                            widthMode: .constrained,
                            isMenuButton: true,
                            action: {}
                        )
                    }
                }
            }
            
            // Text input field
            ZStack(alignment: .topLeading) {
                if shareText.isEmpty {
                    Text("Say something about this...")
                        .body2Typography()
                        .foregroundStyle(Color("secondaryText"))
                        .padding(.top, 8)
                        .allowsHitTesting(false)
                }
                
                TextField("", text: $shareText, axis: .vertical)
                    .body2Typography()
                    .foregroundStyle(Color("primaryText"))
                    .tint(Color("logo"))
                    .lineLimit(1...10)
                    .focused($isTextFieldFocused)
                    .padding(.top, 8)
            }
            .frame(minHeight: 40, alignment: .topLeading)
            .padding(.bottom, 12)
            
            // Share now button
            HStack {
                Spacer()
                FDSButton(
                    type: .primary,
                    label: "Share now",
                    widthMode: .constrained,
                    action: {
                        onShare(shareText)
                        dismiss()
                    }
                )
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
        .cornerRadius(12)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    // MARK: - Messenger Contacts Scroll
    
    private var messengerContactsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                FDSAssetLockup(
                    size: .large,
                    label: "Tina\nWright",
                    asset: .profilePhoto(url: "profile6"),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "The\ngirlies",
                    asset: .dualProfilePhoto(
                        foreground: .init(imageUri: "profile4"),
                        background: .init(imageUri: "profile3"),
                        type: .chat
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Shira\nThomsen",
                    asset: .profilePhoto(url: "profile7"),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Lina and\nNastya",
                    asset: .dualProfilePhoto(
                        foreground: .init(imageUri: "profile11"),
                        background: .init(imageUri: "profile10"),
                        type: .chat
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Airi\nAnderson",
                    asset: .profilePhoto(url: "profile5"),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Diana\nRoss",
                    asset: .profilePhoto(url: "profile4"),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Jamie\nLee",
                    asset: .profilePhoto(url: "profile8"),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Fatih\nTekin",
                    asset: .profilePhoto(url: "profile9"),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "More",
                    asset: .containedIcon(
                        icon: "dots-3-horizontal-filled",
                        backgroundColor: Color("secondaryButtonBackground"),
                        iconColor: Color("primaryIcon")
                    ),
                    action: {}
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Share Options Scroll
    
    private var shareOptionsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                FDSAssetLockup(
                    size: .large,
                    label: "Copy link",
                    asset: .containedIcon(
                        icon: "link-outline",
                        backgroundColor: Color("secondaryButtonBackground"),
                        iconColor: Color("primaryIcon")
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "WhatsApp",
                    asset: .containedIcon(
                        icon: "app-whatsapp-filled",
                        backgroundColor: Color("decorativeIconGreen"),
                        iconColor: Color("alwaysWhite")
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Messenger",
                    asset: .containedIcon(
                        icon: "app-messenger-filled",
                        backgroundColor: Color("accentColor"),
                        iconColor: Color("alwaysWhite")
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Groups",
                    asset: .containedIcon(
                        icon: "group-filled",
                        backgroundColor: Color("secondaryButtonBackground"),
                        iconColor: Color("primaryIcon")
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Threads",
                    asset: .containedIcon(
                        icon: "app-threads-filled",
                        backgroundColor: Color("alwaysBlack"),
                        iconColor: Color("alwaysWhite")
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "Instagram",
                    asset: .containedIcon(
                        icon: "app-instagram-filled",
                        backgroundColor: Color("decorativeIconPink"),
                        iconColor: Color("alwaysWhite")
                    ),
                    action: {}
                )
                FDSAssetLockup(
                    size: .large,
                    label: "More",
                    asset: .containedIcon(
                        icon: "dots-3-horizontal-filled",
                        backgroundColor: Color("secondaryButtonBackground"),
                        iconColor: Color("primaryIcon")
                    ),
                    action: {}
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}


// MARK: - Preview


#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            ShareBottomSheet(
                post: PostData(
                    id: 1,
                    userName: "Test User",
                    timeStamp: "1h",
                    profileImage: "profile2",
                    attachment: nil,
                    text: "This is a test post"
                ),
                onShare: { text in
                    print("Share with text: \(text)")
                }
            )
        }
}
