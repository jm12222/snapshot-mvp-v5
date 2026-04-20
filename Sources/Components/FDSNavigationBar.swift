import SwiftUI

// MARK: - FDSNavigationBar (Original - Logo/Title + Icons)
struct FDSNavigationBar<Icon0: View, Icon1: View, Icon2: View, Icon3: View>: View {
    // MARK: - Properties
    let title: String?
    let titleAction: (() -> Void)?
    let logoAction: (() -> Void)?
    let backAction: (() -> Void)?
    let menuAction: (() -> Void)?
    let onMedia: Bool
    let icon0: Icon0
    let icon1: Icon1
    let icon2: Icon2
    let icon3: Icon3
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    
    // MARK: - Initializer
    init(
        title: String? = nil,
        titleAction: (() -> Void)? = nil,
        logoAction: (() -> Void)? = nil,
        backAction: (() -> Void)? = nil,
        menuAction: (() -> Void)? = nil,
        onMedia: Bool = false,
        @ViewBuilder icon0: () -> Icon0 = { EmptyView() },
        @ViewBuilder icon1: () -> Icon1 = { EmptyView() },
        @ViewBuilder icon2: () -> Icon2 = { EmptyView() },
        @ViewBuilder icon3: () -> Icon3 = { EmptyView() }
    ) {
        self.title = title
        self.titleAction = titleAction
        self.logoAction = logoAction
        self.backAction = backAction
        self.menuAction = menuAction
        self.onMedia = onMedia
        self.icon0 = icon0()
        self.icon1 = icon1()
        self.icon2 = icon2()
        self.icon3 = icon3()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Menu button if provided
            if menuAction != nil {
                icon0
            }
            // Auto-detect if we should show back button based on presentation context
            else if isPresented {
                FDSIconButton(icon: "chevron-left-filled", onMedia: onMedia, action: {
                    if let backAction = backAction {
                        backAction()
                    } else {
                        dismiss()
                    }
                })
            }
            titleView
            Spacer()
            HStack(spacing: 20) {
                icon1
                icon2
                icon3
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(onMedia ? Color.clear : Color("surfaceBackground"))
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private var titleView: some View {
        if let title = title {
            if let titleAction = titleAction {
                Button(action: titleAction) {
                    Text(title)
                        .headline0EmphasizedFBSansTypography()
                        .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                        .frame(height: 26, alignment: .leading)
                        .if(onMedia) { view in
                            view.textOnMediaShadow()
                        }
                }
            } else {
                Text(title)
                    .headline0EmphasizedFBSansTypography()
                    .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                    .frame(height: 26, alignment: .leading)
                    .if(onMedia) { view in
                        view.textOnMediaShadow()
                    }
            }
        } else {
            if let action = logoAction {
                Button(action: action) {
                    logoImage
                }
            } else {
                logoImage
            }
        }
    }
    
    private var logoImage: some View {
        Image("facebookLogo")
            .foregroundColor(onMedia ? Color("primaryIconOnMedia") : Color("logo"))
            .scaledToFit()
            .frame(width: 128, height: 24)
            .padding(.bottom, 2)
            .if(onMedia) { view in
                view.iconOnMediaShadow()
            }
    }
}

// MARK: - Convenience Initializer for Simple Icons
extension FDSNavigationBar where Icon0 == AnyView, Icon1 == AnyView, Icon2 == AnyView, Icon3 == AnyView {
    init(
        title: String? = nil,
        titleAction: (() -> Void)? = nil,
        logoAction: (() -> Void)? = nil,
        backAction: (() -> Void)? = nil,
        menuAction: (() -> Void)? = nil,
        onMedia: Bool = false,
        icon1Name: String,
        icon1Action: @escaping () -> Void = {},
        icon2Name: String,
        icon2Action: @escaping () -> Void = {},
        icon3Name: String,
        icon3Action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.titleAction = titleAction
        self.logoAction = logoAction
        self.backAction = backAction
        self.menuAction = menuAction
        self.onMedia = onMedia
        // Navigation bars always use primaryIcon and size24
        self.icon0 = AnyView(EmptyView())
        self.icon1 = AnyView(FDSIconButton(icon: icon1Name, onMedia: onMedia, action: icon1Action))
        self.icon2 = AnyView(FDSIconButton(icon: icon2Name, onMedia: onMedia, action: icon2Action))
        self.icon3 = AnyView(FDSIconButton(icon: icon3Name, onMedia: onMedia, action: icon3Action))
    }
}

// MARK: - FDSNavigationBarCentered (Centered Title + Back Button + Icons)
struct FDSNavigationBarCentered<Icon1: View, Icon2: View, Icon3: View>: View {
    let title: String?
    let backAction: () -> Void
    let backIcon: String
    let onMedia: Bool
    let icon1: Icon1
    let icon2: Icon2
    let icon3: Icon3
    
    init(
        title: String? = nil,
        backAction: @escaping () -> Void,
        backIcon: String = "chevron-left-filled",
        onMedia: Bool = false,
        @ViewBuilder icon1: () -> Icon1 = { EmptyView() },
        @ViewBuilder icon2: () -> Icon2 = { EmptyView() },
        @ViewBuilder icon3: () -> Icon3 = { EmptyView() }
    ) {
        self.title = title
        self.backAction = backAction
        self.backIcon = backIcon
        self.onMedia = onMedia
        self.icon1 = icon1()
        self.icon2 = icon2()
        self.icon3 = icon3()
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Left section - back button
            FDSIconButton(icon: backIcon, onMedia: onMedia, action: backAction)
            
            Spacer()
            
            // Right section - icons
            HStack(spacing: 20) {
                icon1
                icon2
                icon3
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(onMedia ? Color.clear : Color("surfaceBackground"))
        .overlay {
            // Title centered in the entire bar with constrained width
            if let title = title {
                HStack {
                    Spacer(minLength: 56) // Reserve space for left button
                    Text(title)
                        .headline3EmphasizedTypography()
                        .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: .infinity)
                        .if(onMedia) { view in
                            view.textOnMediaShadow()
                        }
                    Spacer(minLength: 56) // Reserve space for right icons
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

// MARK: - FDSNavigationBarSearch (Back Button + Search Field)
struct FDSNavigationBarSearch: View {
    @Binding var searchText: String
    let placeholder: String
    @FocusState.Binding var isFocused: Bool
    let backAction: () -> Void
    let onMedia: Bool
    let onSubmit: () -> Void
    
    init(
        searchText: Binding<String>,
        placeholder: String = "Search",
        isFocused: FocusState<Bool>.Binding,
        backAction: @escaping () -> Void,
        onMedia: Bool = false,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self._isFocused = isFocused
        self.backAction = backAction
        self.onMedia = onMedia
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack(spacing: 12) {
            FDSIconButton(icon: "chevron-left-filled", onMedia: onMedia, action: backAction)
            
            HStack(spacing: 6) {
                Image("magnifying-glass-outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(onMedia ? Color("secondaryIconOnMedia") : Color("secondaryIcon"))
                
                TextField("", text: $searchText, prompt: Text(placeholder).foregroundStyle(onMedia ? Color("secondaryTextOnMedia") : Color("secondaryText")))
                    .body2Typography()
                    .foregroundStyle(onMedia ? Color("primaryTextOnMedia") : Color("primaryText"))
                    .tint(Color("logo"))
                    .keyboardType(.default)
                    .focused($isFocused)
                    .onSubmit {
                        onSubmit()
                    }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(onMedia ? Color("textInputBarBackgroundOnMedia") : Color("inputBarBackground"))
            .cornerRadius(25)
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background(onMedia ? Color.clear : Color("surfaceBackground"))
    }
}

// MARK: - FDSNavigationBarMessaging (Close Button + Profile + Name + Action Icons)
struct FDSNavigationBarMessaging: View {
    let profileImage: String
    let name: String
    let isActiveNow: Bool
    let closeAction: () -> Void
    let phoneAction: () -> Void
    let videoAction: () -> Void
    
    init(
        profileImage: String,
        name: String,
        isActiveNow: Bool = false,
        closeAction: @escaping () -> Void,
        phoneAction: @escaping () -> Void = {},
        videoAction: @escaping () -> Void = {}
    ) {
        self.profileImage = profileImage
        self.name = name
        self.isActiveNow = isActiveNow
        self.closeAction = closeAction
        self.phoneAction = phoneAction
        self.videoAction = videoAction
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Close button
            FDSIconButton(
                icon: "cross-filled",
                size: .size24,
                color: .accent,
                action: closeAction
            )
            
            // Profile photo with conditional active status
            ZStack(alignment: .bottomTrailing) {
                Image(profileImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                // Active indicator - only show if isActiveNow is true
                if isActiveNow {
                    Circle()
                        .fill(Color("positive"))
                        .frame(width: 8, height: 8)
                        .overlay(
                            Circle()
                                .stroke(Color("surfaceBackground"), lineWidth: 1.5)
                        )
                }
            }
            
            // Name
            Text(name)
                .headline3EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 24) {
                FDSIconButton(
                    icon: "phone-filled",
                    size: .size24,
                    color: .accent,
                    action: phoneAction
                )
                
                FDSIconButton(
                    icon: "camcorder-filled",
                    size: .size24,
                    color: .accent,
                    action: videoAction
                )
            }
            .padding(.trailing, 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(height: 56)
        .background(Color("navBarBackground"))
    }
}

// MARK: - Helper Extension
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Navigation Bar Group Card Component
struct NavigationBarGroupCard<Content: View>: View {
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
                .padding(.horizontal, 12)
            
            content
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Navigation Bar Preview View
struct NavigationBarPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var subNavIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSNavigationBar",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    NavigationBarGroupCard(title: "Logo variant with icons") {
                        FDSNavigationBar(
                            icon1Name: "plus-square-outline",
                            icon2Name: "magnifying-glass-outline",
                            icon3Name: "app-messenger-outline",
                    )}
                    
                    NavigationBarGroupCard(title: "Text title variant") {
                        FDSNavigationBar(
                            title: "Marketplace",
                            icon1Name: "app-messenger-outline",
                            icon2Name: "profile-outline",
                            icon3Name: "magnifying-glass-outline"
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Centered title with back button") {
                        FDSNavigationBarCentered(
                            title: "Profile settings",
                            backAction: {},
                            icon1: {
                                FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                            }
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Centered title null (blank space)") {
                        FDSNavigationBarCentered(
                            backAction: {},
                            icon1: {
                                FDSIconButton(icon: "share-outline", action: {})
                            },
                            icon2: {
                                FDSIconButton(icon: "bookmark-outline", action: {})
                            },
                            icon3: {
                                FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                            }
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Search variant") {
                        FDSNavigationBarSearch(
                            searchText: $searchText,
                            placeholder: "Search with Meta AI",
                            isFocused: $isSearchFocused,
                            backAction: {}
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Messaging variant (with active status)") {
                        FDSNavigationBarMessaging(
                            profileImage: "profile3",
                            name: "Alice Smith",
                            isActiveNow: true,
                            closeAction: {},
                            phoneAction: {},
                            videoAction: {}
                        )
                    }
                    
                    NavigationBarGroupCard(title: "Messaging variant (no active status)") {
                        FDSNavigationBarMessaging(
                            profileImage: "profile2",
                            name: "Bob Johnson",
                            isActiveNow: false,
                            closeAction: {},
                            phoneAction: {},
                            videoAction: {}
                        )
                    }
                    
                    NavigationBarGroupCard(title: "SubNavigation (composable with FDSSubNavigationBar)") {
                        HStack(alignment: .center, spacing: 12) {
                            FDSSubNavigationBar(
                                items: [
                                    SubNavigationItem("For you"),
                                    SubNavigationItem("Explore")
                                ],
                                selectedIndex: $subNavIndex
                            )
                            
                            Spacer()
                            
                            HStack(spacing: 20) {
                                FDSIconButton(icon: "magnifying-glass-outline", action: {})
                                FDSIconButton(icon: "profile-outline", action: {})
                            }
                        }
                        .frame(height: 52)
                        .background(Color("surfaceBackground"))
                    }
                    
                    VStack(spacing: 0) {
                        Text("OnMedia variants")
                            .meta4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .textOnMediaShadow()
                        
                        VStack(spacing: 12) {
                            FDSNavigationBar(
                                title: "Video",
                                onMedia: true,
                                icon1: {
                                    FDSIconButton(icon: "share-outline", onMedia: true, action: {})
                                }
                            )
                            
                            HStack(alignment: .center, spacing: 12) {
                                FDSSubNavigationBar(
                                    items: [
                                        SubNavigationItem("For you"),
                                        SubNavigationItem("Explore")
                                    ],
                                    selectedIndex: $subNavIndex,
                                    onMedia: true
                                )
                                
                                Spacer()
                                
                                HStack(spacing: 20) {
                                    FDSIconButton(icon: "magnifying-glass-outline", onMedia: true, action: {})
                                    FDSIconButton(icon: "profile-outline", onMedia: true, action: {})
                                }
                            }
                            .padding(.trailing, 12)
                            .frame(height: 52)
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
    NavigationBarPreviewView()
}
