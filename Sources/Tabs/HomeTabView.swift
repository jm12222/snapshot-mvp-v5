import SwiftUI

// MARK: - Navigation Value Types

struct GroupNavigationValue: Hashable {
    let groupImage: String
}

struct IABNavigationValue: Hashable {
    let url: URL
    let pageTitle: String
}

// MARK: Home Tab

struct HomeTab: View {
    var bottomPadding: CGFloat = 0
    @State private var showSearch = false
    @State private var navigationToPrototypeSettings = false
    @State private var showGroupsTab = false
    @State private var showComposer = false
    @State private var scrollProxy: ScrollViewProxy?
    @EnvironmentObject private var tabBarHelper: FDSTabBarHelper
    @EnvironmentObject private var drawerState: DrawerStateManager
    @State private var isNavigating = false
    @State private var isCreatingPost = false

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        FDSNavigationBar(
                            logoAction: { navigationToPrototypeSettings = true },
                            menuAction: { drawerState.openDrawer() },
                            icon0: {
                                FDSIconButton(icon: "more-outline", action: { drawerState.openDrawer() })
                            },
                            icon1: {
                                Menu {
                                    Button(action: {}) {
                                        Label("Post", image: "compose-outline")
                                    }
                                    Button(action: {}) {
                                        Label("Story", image: "instagram-new-story-outline")
                                    }
                                    Button(action: {}) {
                                        Label("Reel", image: "app-facebook-reels-outline")
                                    }
                                    Button(action: {}) {
                                        Label("Live", image: "camcorder-live-outline")
                                    }
                                    Button(action: {}) {
                                        Label("Note", image: "content-note-outline")
                                    }
                                } label: {
                                    FDSIconButton(icon: "plus-square-outline", action: {})
                                }
                                .tint(Color("primaryIcon"))
                            },
                            icon2: {
                                FDSIconButton(icon: "magnifying-glass-outline", action: { showSearch = true })
                            },
                            icon3: {
                                FDSIconButton(icon: "app-messenger-outline", action: {
                                    if let url = URL(string: "msgrproto://") {
                                        UIApplication.shared.open(url)
                                    }
                                })
                            }
                        )
                        .id("top")
                        PostComposer(showComposer: $showComposer)
                        StoriesTray()

                        // Today's Snapshot quick promotion: re-entry point
                        // into the snapshot landing experience. Sits directly
                        // under the stories tray so it's the first content
                        // unit in the feed.
                        FeedSnapshotQuickPromotion()

                        if isCreatingPost {
                            Separator()
                            FeedPostGlimmer()
                        }
                        
                        ForEach(postData, id: \.id) { post in
                            Separator()
                            FeedPost(from: post, onShare: { text, originalPost in
                                createResharePost(text: text, originalPost: originalPost)
                            })
                            .id("post-\(post.id)")
                        }
                    }
                    .padding(.bottom, bottomPadding)
                }
                .hideTabBarOnScrollWithDwell(threshold: 0, dwellTime: 1.5)
                .background(Color("surfaceBackground"))
                .onAppear {
                    scrollProxy = proxy
                    DispatchQueue.main.async {
                        tabBarHelper.isHomeTabActive = true
                    }
                }
                .onDisappear {
                    DispatchQueue.main.async {
                        tabBarHelper.isHomeTabActive = false
                    }
                }
            }
            .navigationDestination(isPresented: $showSearch) {
                SearchView()
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
            .navigationDestination(isPresented: $navigationToPrototypeSettings) {
                PrototypeSettings()
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
            .navigationDestination(for: PostData.self) { post in
                PostPermalinkView(post: post)
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
            .navigationDestination(for: String.self) { profileImageId in
                if let profileData = profileDataMap[profileImageId] {
                    ProfileView(profile: profileData)
                        .onAppear { isNavigating = true }
                        .onDisappear { isNavigating = false }
                }
            }
            .navigationDestination(for: GroupNavigationValue.self) { groupNav in
                if let groupData = groupDataMap[groupNav.groupImage] {
                    GroupView(group: groupData)
                        .onAppear { isNavigating = true }
                        .onDisappear { isNavigating = false }
                }
            }
            .fullScreenCover(isPresented: $showComposer) {
                ComposerView(onPost: { text in
                    createNewPost(text: text)
                })
            }
            .navigationDestination(isPresented: $showGroupsTab) {
                GroupsTabView(bottomPadding: bottomPadding)
                    .onAppear { isNavigating = true }
                    .onDisappear { isNavigating = false }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createNewPost(text: String) {
        withAnimation(.enterIn(MotionDuration.mediumIn)) {
            scrollProxy?.scrollTo("top", anchor: .top)
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            await MainActor.run {
                isCreatingPost = true
            }
            
            try? await Task.sleep(nanoseconds: 600_000_000)
            
            await MainActor.run {
                let newPost = PostData(
                    id: (postData.map { $0.id }.max() ?? 0) + 1,
                    userName: "Daniela Giménez",
                    timeStamp: "Just now",
                    profileImage: "profile1",
                    attachment: nil,
                    text: text,
                    actionChips: nil,
                    likeCount: 0,
                    commentCount: 0,
                    shareCount: 0,
                    reactions: []
                )
                
                withAnimation(.enterIn(MotionDuration.mediumIn)) {
                    isCreatingPost = false
                    postData.insert(newPost, at: 0)
                }
            }
        }
    }
    
    private func createResharePost(text: String, originalPost: PostData) {
        withAnimation(.enterIn(MotionDuration.mediumIn)) {
            scrollProxy?.scrollTo("top", anchor: .top)
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            await MainActor.run {
                isCreatingPost = true
            }
            
            try? await Task.sleep(nanoseconds: 600_000_000)
            
            await MainActor.run {
                let resharedData = ResharedPostData(
                    userName: originalPost.userName,
                    timeStamp: originalPost.timeStamp,
                    profileImage: originalPost.profileImage,
                    text: originalPost.text,
                    attachment: originalPost.attachment
                )
                
                let resharePost = PostData(
                    id: (postData.map { $0.id }.max() ?? 0) + 1,
                    userName: "Daniela Giménez",
                    timeStamp: "Just now",
                    profileImage: "profile1",
                    attachment: .reshare(resharedData),
                    text: text.isEmpty ? nil : text,
                    actionChips: nil,
                    likeCount: 0,
                    commentCount: 0,
                    shareCount: 0,
                    reactions: []
                )
                
                withAnimation(.enterIn(MotionDuration.mediumIn)) {
                    isCreatingPost = false
                    postData.insert(resharePost, at: 0)
                }
            }
        }
    }
}

// MARK: - Separator

struct Separator: View {
    var body: some View {
        Rectangle()
            .frame(height: 2)
            .foregroundColor(Color("wash"))
    }
}

// MARK: - Post Composer

struct PostComposer: View {
    @Binding var showComposer: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            NavigationLink(value: "profile1") {
                Image("profile1")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(100)
            }
            Button {
                showComposer = true
            } label: {
                Text("What's on your mind?")
                    .body3Typography()
                    .foregroundStyle(Color("secondaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            FDSIconButton(icon: "photo-filled", color: .secondary, action: { showComposer = true })
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Stories Tray

struct StoriesTray: View {
    @State private var showStories = false
    @State private var selectedStoryIndex = 0
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                StoryTile(userName: "Add to Story", storyImage: "story0", profileImage: "plus-filled")
                    .frame(width: 114, height: 203)
                ForEach(Array(storyData.enumerated()), id: \.element.profileImage) { index, story in
                    Button {
                        selectedStoryIndex = index
                        showStories = true
                    } label: {
                        StoryTile(userName: story.userName, storyImage: story.storyImage, profileImage: story.profileImage)
                            .frame(width: 114, height: 203)
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 12, scale: .medium))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color("surfaceBackground"))
        .fullScreenCover(isPresented: $showStories) {
            StoriesView(isPresented: $showStories, stories: storyData, startingIndex: selectedStoryIndex)
        }
    }
}

// MARK: - Stories Tile

struct StoryTile: View {
    var userName: String
    var storyImage: String
    var profileImage: String
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                Image(storyImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .background(Color.clear)
                VStack(alignment: .leading) {
                    if userName == "Add to Story" {
                        ZStack {
                            Image(profileImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color("secondaryButtonIconOnMedia"))
                                .padding(4)
                                .background(Color("secondaryButtonBackgroundOnMedia"))
                                .cornerRadius(32)
                        }
                        .padding(8)
                    } else {
                        Image(profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color("accentColor"), lineWidth: 3))
                            .padding(8)
                    }
                    Spacer()
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            stops: [
                                .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 60)
                        HStack(alignment: .center, spacing: 4) {
                            Text(userName)
                                .body4LinkTypography()
                                .foregroundColor(Color("primaryTextOnMedia"))
                                .textOnMediaShadow()
                        }
                        .padding(8)
                    }
                }
            }
            .cornerRadius(12)
        }
    }
}

// MARK: - Post Header Content

struct PostHeaderContent: View {
    let post: PostData
    let relationshipType: ProfileRelationship
    let disableProfileNavigation: Bool
    let hideGroupInfo: Bool

    var isGroupPost: Bool {
        post.groupName != nil && !hideGroupInfo
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if isGroupPost {
                groupPhotoLockup
            } else {
                profilePhoto
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 4) {
                    if isGroupPost {
                        groupHeadline
                    } else {
                        actorHeadline
                    }
                }

                HStack(alignment: .center, spacing: 4) {
                    if isGroupPost {
                        actorNameLink
                        Text("·")
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                    }

                    Text(post.timeStamp)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Text("·")
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Image("globe-americas-12")
                        .foregroundColor(Color("secondaryIcon"))
                        .frame(width: 12, height: 12)
                        .frame(height: 8)
                }
                .allowsHitTesting(isGroupPost) // Allow clicks on actor name for group posts
            }
            .frame(minHeight: 40)
        }
    }

    @ViewBuilder
    private var profilePhoto: some View {
        if disableProfileNavigation {
            Image(post.profileImage)
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(25)
        } else {
            NavigationLink(value: post.profileImage) {
                Image(post.profileImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(25)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var groupPhotoLockup: some View {
        if let groupImage = post.groupImage, !disableProfileNavigation {
            NavigationLink(value: GroupNavigationValue(groupImage: groupImage)) {
                groupPhotoLockupContent
            }
            .buttonStyle(.plain)
        } else {
            groupPhotoLockupContent
        }
    }

    private var groupPhotoLockupContent: some View {
        ZStack(alignment: .bottomTrailing) {
            if let groupImage = post.groupImage {
                Image(groupImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .offset(x: 0, y: 0)
            }

            Circle()
                .fill(Color("surfaceBackground"))
                .frame(width: 26, height: 26)
                .offset(x: 2, y: 2)

            Image(post.profileImage)
                .resizable()
                .frame(width: 24, height: 24)
                .cornerRadius(12)
                .offset(x: 1, y: 1)
        }
        .frame(width: 40, height: 40)
    }

    // MARK: - Headline Components

    @ViewBuilder
    private var actorHeadline: some View {
        if disableProfileNavigation {
            Text(post.userName)
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
        } else {
            NavigationLink(value: post.profileImage) {
                Text(post.userName)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
            ))
        }

        if relationshipType == .stranger && !disableProfileNavigation {
            Text("·")
                .headline4Typography()
                .foregroundStyle(Color("primaryText"))
            Button {
                // Follow action
            } label: {
                Text("Follow")
                    .headline4Typography()
                    .foregroundStyle(Color("blueLink"))
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
            ))
        }
    }

    @ViewBuilder
    private var groupHeadline: some View {
        if let groupName = post.groupName, let groupImage = post.groupImage {
            if disableProfileNavigation {
                Text(groupName)
                    .headline4Typography()
                    .foregroundStyle(Color("primaryText"))
            } else {
                NavigationLink(value: GroupNavigationValue(groupImage: groupImage)) {
                    Text(groupName)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                }
                .buttonStyle(FDSPressedState(
                    cornerRadius: 6,
                    padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
                ))
            }
        }
    }

    @ViewBuilder
    private var actorNameLink: some View {
        if disableProfileNavigation {
            Text(post.userName)
                .meta4LinkTypography()
                .foregroundStyle(Color("secondaryText"))
        } else {
            NavigationLink(value: post.profileImage) {
                Text(post.userName)
                    .meta4LinkTypography()
                    .foregroundStyle(Color("secondaryText"))
            }
            .buttonStyle(FDSPressedState(
                cornerRadius: 6,
                padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
            ))
        }
    }
}

// MARK: - Feed Post

struct FeedPost: View {
    let post: PostData
    let isPermalink: Bool
    let disableProfileNavigation: Bool
    let hideGroupInfo: Bool
    let onShare: ((String, PostData) -> Void)?
    @State private var currentReaction: String? = nil
    @State private var likeCount: Int
    @State private var navigateToIAB: IABNavigationValue?
    @State private var commentCount: Int
    @State private var shareCount: Int
    @State private var reactions: [String]
    @State private var selectedPhoto: PhotoViewItem?
    @State private var showShareSheet = false
    @EnvironmentObject private var tabBarHelper: FDSTabBarHelper

    private var relationshipType: ProfileRelationship {
        profileDataMap[post.profileImage]?.relationshipType ?? .stranger
    }

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            let thousands = Double(number) / 1000.0
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(thousands))K"
            } else {
                return String(format: "%.1fK", thousands)
            }
        }
        return "\(number)"
    }

    init(from post: PostData, isPermalink: Bool = false, disableProfileNavigation: Bool = false, hideGroupInfo: Bool = false, onShare: ((String, PostData) -> Void)? = nil) {
        self.post = post
        self.isPermalink = isPermalink
        self.disableProfileNavigation = disableProfileNavigation
        self.hideGroupInfo = hideGroupInfo
        self.onShare = onShare
        self.likeCount = post.likeCount ?? Int.random(in: 3...2000)
        self.commentCount = post.commentCount ?? Int.random(in: 3...2000)
        self.shareCount = post.shareCount ?? Int.random(in: 3...2000)
        self.reactions = post.reactions ?? Array(["like", "love", "haha", "support"].shuffled().prefix(Int.random(in: 2...3)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            VStack(alignment: .leading, spacing: 12) {
                postHeader

                if let text = post.text {
                    Group {
                        if text.count < 83 && post.attachment == nil {
                            Text(text)
                                .body1Typography()
                                .foregroundStyle(Color("primaryText"))
                        } else {
                            Text(text)
                                .body3Typography()
                                .foregroundStyle(Color("primaryText"))
                        }
                    }
                }

                if let attachment = post.attachment {
                    attachmentView(for: attachment)
                        .zIndex(2)
                }

                if let actionChips = post.actionChips, !actionChips.isEmpty {
                    ActionChipHScroll(spacing: 8) {
                        ForEach(actionChips.indices, id: \.self) { index in
                            let chip = actionChips[index]
                            FDSActionChip(
                                size: .large,
                                label: chip.label,
                                leftAddOn: chip.iconName != nil ? .expressiveIconAsset(chip.iconName!) : nil,
                                action: {}
                            )
                        }
                    }
                    .padding(.horizontal, -12)
                }
            }

            HStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 4) {
                    ReactionPicker(
                        count: likeCount,
                        onSelect: { reaction in
                            withAnimation {
                                // Convert reaction ID to inline format (strip "-large" suffix)
                                let reactionId = reaction.id.replacingOccurrences(of: "-large", with: "")
                                
                                if let oldReaction = currentReaction {
                                    // Changing reactions - remove old, add new
                                    if let index = reactions.firstIndex(of: oldReaction) {
                                        reactions.remove(at: index)
                                    }
                                    // Add new reaction if not already in the array and there's room
                                    if !reactions.contains(reactionId) && reactions.count < 3 {
                                        reactions.append(reactionId)
                                    }
                                    currentReaction = reactionId
                                } else {
                                    // Adding new reaction - increment count
                                    likeCount += 1
                                    currentReaction = reactionId
                                    // Only add reaction if it's not already there and there are fewer than 3 reactions
                                    if !reactions.contains(reactionId) && reactions.count < 3 {
                                        reactions.append(reactionId)
                                    }
                                }
                            }
                        },
                        onDeselect: {
                            withAnimation {
                                if currentReaction != nil {
                                    likeCount -= 1
                                    currentReaction = nil
                                    // Only remove if there are no more likes
                                    if likeCount == 0 {
                                        reactions.removeAll()
                                    }
                                }
                            }
                        }
                    )
                    
                    if isPermalink {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image("comment-outline")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color("secondaryIcon"))
                                    .frame(width: 20, height: 20)
                                
                                if commentCount > 0 {
                                    Text(formatNumber(commentCount))
                                        .body4LinkTypography()
                                        .foregroundColor(Color("secondaryText"))
                                }
                            }
                            .frame(height: 36)
                            .padding(.horizontal, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(FDSPressedState(cornerRadius: 8))
                    } else {
                        NavigationLink(value: post) {
                            HStack(spacing: 6) {
                                Image("comment-outline")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(Color("secondaryIcon"))
                                    .frame(width: 20, height: 20)
                                
                                if commentCount > 0 {
                                    Text(formatNumber(commentCount))
                                        .body4LinkTypography()
                                        .foregroundColor(Color("secondaryText"))
                                }
                            }
                            .frame(height: 36)
                            .padding(.horizontal, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(FDSPressedState(cornerRadius: 8))
                    }
                    
                    Button(action: { showShareSheet = true }) {
                        HStack(spacing: 6) {
                            Image("share-outline")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color("secondaryIcon"))
                                .frame(width: 20, height: 20)
                            
                            if shareCount > 0 {
                                Text(formatNumber(shareCount))
                                    .body4LinkTypography()
                                    .foregroundColor(Color("secondaryText"))
                            }
                        }
                        .frame(height: 36)
                        .padding(.horizontal, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 8))
                }
                
                Spacer()
                
                if !reactions.isEmpty {
                    InlineReactions(reactions: reactions)
                        .padding(.trailing, 12)
                }
            }
            .padding(.leading, -8)
            .padding(.trailing, -12)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color("surfaceBackground"))
        .navigationDestination(item: $navigateToIAB) { iabNav in
            IABView(url: iabNav.url, pageTitle: iabNav.pageTitle)
        }
        .fullScreenCover(item: $selectedPhoto) { photoItem in
            PhotoView(
                isPresented: .init(
                    get: { selectedPhoto != nil },
                    set: { if !$0 { selectedPhoto = nil } }
                ),
                imageNames: photoItem.imageNames,
                startingIndex: photoItem.startingIndex,
                postData: photoItem.postData
            )
        }
        .sheet(isPresented: $showShareSheet) {
            ShareBottomSheet(post: post, onShare: { text in
                onShare?(text, post)
            })
        }
    }

    private var postHeader: some View {
        ZStack(alignment: .topLeading) {
            if !isPermalink {
                NavigationLink(value: post) {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainNoHighlightButtonStyle())
            }

            HStack(alignment: .top) {
                PostHeaderContent(
                    post: post,
                    relationshipType: relationshipType,
                    disableProfileNavigation: disableProfileNavigation,
                    hideGroupInfo: hideGroupInfo
                )

                Spacer()
                    .allowsHitTesting(false)

                if !isPermalink {
                    HStack(spacing: 20) {
                        PostMenuView()
                        FDSIconButton(icon: "nav-cross", size: .size20, color: .secondary, action: {})
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func attachmentView(for attachment: PostAttachment) -> some View {
        switch attachment {
        case .photos(let imageNames):
            photosAttachment(imageNames: imageNames)

        case .link(let linkData):
            linkAttachment(data: linkData)
            
        case .reshare(let resharedPost):
            reshareAttachment(resharedPost: resharedPost)
        }
    }

    // MARK: - Photos Attachment
    
    private var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    @ViewBuilder
    private func photosAttachment(imageNames: [String]) -> some View {
        photoGridView(
            imageNames: imageNames,
            photoPostData: PhotoViewPostData(
                userName: post.userName,
                timeStamp: post.timeStamp,
                groupName: post.groupName,
                likeCount: likeCount,
                commentCount: commentCount,
                shareCount: shareCount,
                reactions: reactions
            ),
            containerWidth: screenWidth,
            inReshare: false
        )
        .padding(.horizontal, -12)
    }
    
    private func constrainedHeight(for image: UIImage, width: CGFloat) -> CGFloat {
        let aspectRatio = image.size.width / image.size.height
        let naturalHeight = width / aspectRatio
        let minHeight = width / (16.0 / 9.0)
        let maxHeight = width / (4.0 / 5.0)
        return min(max(naturalHeight, minHeight), maxHeight)
    }

    @ViewBuilder
    private func linkAttachment(data: LinkAttachmentData) -> some View {
        Button {
            if let url = URL(string: data.url) {
                navigateToIAB = IABNavigationValue(url: url, pageTitle: data.title)
            }
        } label: {
            VStack(alignment: .leading) {
                Image(data.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .clipped()
                VStack(alignment: .leading, spacing: 10) {
                    Text(data.domain)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Text(data.title)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
                .padding(.top, 2)
            }
            .background(Color("cardBackgroundFlat"))
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0))
        .padding(.horizontal, -12)
    }
    
    // MARK: - Reshare Attachment
    
    private func hasVisibleAttachment(_ attachment: PostAttachment?) -> Bool {
        guard let attachment = attachment else { return false }
        if case .reshare = attachment {
            return false
        }
        return true
    }
    
    @ViewBuilder
    private func reshareAttachment(resharedPost: ResharedPostData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                NavigationLink(value: resharedPost.profileImage) {
                    Image(resharedPost.profileImage)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .cornerRadius(16)
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 8) {
                    NavigationLink(value: resharedPost.profileImage) {
                        Text(resharedPost.userName)
                            .headline4Typography()
                            .foregroundStyle(Color("primaryText"))
                    }
                    .buttonStyle(FDSPressedState(
                        cornerRadius: 6,
                        padding: EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
                    ))
                    
                    HStack(alignment: .center, spacing: 4) {
                        Text(resharedPost.timeStamp)
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                        Text("·")
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                        Image("globe-americas-12")
                            .foregroundColor(Color("secondaryIcon"))
                            .frame(width: 12, height: 12)
                            .frame(height: 8)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, resharedPost.text == nil && !hasVisibleAttachment(resharedPost.attachment) ? 12 : 0)
            
            if let text = resharedPost.text {
                Text(text)
                    .body3Typography()
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, !hasVisibleAttachment(resharedPost.attachment) ? 12 : 0)
            }
            
            if let attachment = resharedPost.attachment {
                resharedAttachmentView(for: attachment, resharedPost: resharedPost)
            }
        }
        .background(Color("surfaceBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("mediaInnerBorder"), lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func resharedAttachmentView(for attachment: PostAttachment, resharedPost: ResharedPostData) -> some View {
        switch attachment {
        case .photos(let imageNames):
            photoGridView(
                imageNames: imageNames,
                photoPostData: PhotoViewPostData(
                    userName: resharedPost.userName,
                    timeStamp: resharedPost.timeStamp,
                    groupName: nil
                ),
                containerWidth: UIScreen.main.bounds.width - 24,
                inReshare: true
            )
            
        case .link(let linkData):
            VStack(alignment: .leading, spacing: 0) {
                Image(linkData.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 180)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(linkData.domain)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                    Text(linkData.title)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .padding(.top, 12)
            
        case .reshare:
            EmptyView()
        }
    }
    
    // MARK: - Photo Orientation Detection
    
    private enum PhotoOrientation {
        case portrait, landscape, square
    }
    
    private func detectPhotoOrientation(imageNames: [String]) -> PhotoOrientation {
        guard let firstImage = UIImage(named: imageNames[0]) else { return .square }
        let ratio = firstImage.size.width / firstImage.size.height
        if ratio < 0.9 { return .portrait }   // Taller than wide
        if ratio > 1.1 { return .landscape }  // Wider than tall
        return .square
    }
    
    // MARK: - Reusable Photo Grid
    
    @ViewBuilder
    private func photoGridView(imageNames: [String], photoPostData: PhotoViewPostData, containerWidth: CGFloat, inReshare: Bool = false) -> some View {
        let photoSpacing: CGFloat = 2
        let topPadding: CGFloat = inReshare ? 12 : 0
        
        switch imageNames.count {
        case 1:
            if let image = UIImage(named: imageNames[0]) {
                Button {
                    selectedPhoto = PhotoViewItem(imageNames: imageNames, startingIndex: 0, postData: photoPostData)
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: containerWidth, height: constrainedHeight(for: image, width: containerWidth))
                        .clipped()
                }
                .buttonStyle(FDSPressedState())
                .padding(.top, topPadding)
            }
        case 2:
            let orientation = detectPhotoOrientation(imageNames: imageNames)
            if orientation == .landscape {
                // Landscape: stack vertically, whole media ~1:1
                let photoHeight = (containerWidth - photoSpacing) / 2
                VStack(spacing: photoSpacing) {
                    ForEach(0..<2, id: \.self) { index in
                        photoGridItem(imageNames: imageNames, index: index, width: containerWidth, height: photoHeight, photoPostData: photoPostData)
                    }
                }
                .padding(.top, topPadding)
            } else {
                // Portrait or Square: side by side
                let width = (containerWidth - photoSpacing) / 2
                let height = orientation == .portrait ? width * (16.0 / 9.0) : width
                HStack(spacing: photoSpacing) {
                    ForEach(0..<2, id: \.self) { index in
                        photoGridItem(imageNames: imageNames, index: index, width: width, height: height, photoPostData: photoPostData)
                    }
                }
                .padding(.top, topPadding)
            }
        case 3:
            let orientation = detectPhotoOrientation(imageNames: imageNames)
            if orientation == .landscape {
                // Landscape: large on top, 2 squares at bottom
                let smallSize = (containerWidth - photoSpacing) / 2
                let largeHeight = containerWidth - smallSize - photoSpacing
                VStack(spacing: photoSpacing) {
                    photoGridItem(imageNames: imageNames, index: 0, width: containerWidth, height: largeHeight, photoPostData: photoPostData)
                    HStack(spacing: photoSpacing) {
                        photoGridItem(imageNames: imageNames, index: 1, width: smallSize, height: smallSize, photoPostData: photoPostData)
                        photoGridItem(imageNames: imageNames, index: 2, width: smallSize, height: smallSize, photoPostData: photoPostData)
                    }
                }
                .padding(.top, topPadding)
            } else {
                // Portrait/Square: split in half, 2 square images on right
                let halfWidth = (containerWidth - photoSpacing) / 2
                let smallSize = halfWidth
                let totalHeight = smallSize * 2 + photoSpacing
                HStack(spacing: photoSpacing) {
                    photoGridItem(imageNames: imageNames, index: 0, width: halfWidth, height: totalHeight, photoPostData: photoPostData)
                    VStack(spacing: photoSpacing) {
                        photoGridItem(imageNames: imageNames, index: 1, width: smallSize, height: smallSize, photoPostData: photoPostData)
                        photoGridItem(imageNames: imageNames, index: 2, width: smallSize, height: smallSize, photoPostData: photoPostData)
                    }
                }
                .padding(.top, topPadding)
            }
        default: // 4+
            let size = (containerWidth - photoSpacing) / 2
            let extraCount = imageNames.count - 4
            VStack(spacing: photoSpacing) {
                HStack(spacing: photoSpacing) {
                    photoGridItem(imageNames: imageNames, index: 0, width: size, height: size, photoPostData: photoPostData)
                    photoGridItem(imageNames: imageNames, index: 1, width: size, height: size, photoPostData: photoPostData)
                }
                HStack(spacing: photoSpacing) {
                    photoGridItem(imageNames: imageNames, index: 2, width: size, height: size, photoPostData: photoPostData)
                    if extraCount > 0 {
                        // 5+ photos: show overlay on 4th image
                        Button {
                            selectedPhoto = PhotoViewItem(imageNames: imageNames, startingIndex: 3, postData: photoPostData)
                        } label: {
                            ZStack {
                                Image(imageNames[3])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size, height: size)
                                    .clipped()
                                Color.black.opacity(0.5)
                                Text("+\(extraCount)")
                                    .headline1EmphasizedTypography()
                                    .foregroundStyle(Color("primaryTextOnMedia"))
                                    .textOnMediaShadow()
                            }
                            .frame(width: size, height: size)
                        }
                        .buttonStyle(FDSPressedState())
                    } else {
                        photoGridItem(imageNames: imageNames, index: 3, width: size, height: size, photoPostData: photoPostData)
                    }
                }
            }
            .padding(.top, topPadding)
        }
    }
    
    private func photoGridItem(imageNames: [String], index: Int, width: CGFloat, height: CGFloat, photoPostData: PhotoViewPostData) -> some View {
        Button {
            selectedPhoto = PhotoViewItem(imageNames: imageNames, startingIndex: index, postData: photoPostData)
        } label: {
            Image(imageNames[index])
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipped()
        }
        .buttonStyle(FDSPressedState())
    }
}

// MARK: - Plain No Highlight Button Style

private struct PlainNoHighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

// MARK: - Inline Reactions

struct InlineReactions: View {
    let reactions: [String]
    var body: some View {
        HStack(spacing: -2) {
            ForEach(reactions, id: \.self) { reaction in
                Image(reaction)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .zIndex(Double(reactions.count - reactions.firstIndex(of: reaction)!))
                    .padding(.horizontal, 1)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("surfaceBackground"), lineWidth: 2)
                    )
            }
        }
    }
}

// MARK: Post Menu Component

struct PostMenuView: View {
    var size: FDSIconButtonSize = .size20
    var color: FDSIconButtonColor = .secondary

    var body: some View {
        Menu {
            ControlGroup {
                Button {
                } label: {
                    Label("Show more", image: "arrow-up-circle-outline")
                }
                Button {
                } label: {
                    Label("Show less", image: "arrow-down-circle-outline")
                }
            }
            .controlGroupStyle(.menu)
            Button(action: {}) {
                Label("Save post", image: "bookmark-outline")
            }
            Button(action: {}) {
                Label("Hide post", image: "hide-outline")
            }
            Button(action: {}) {
                Label("Report post", image: "report-outline")
            }
            Button(action: {}) {
                Label("Why am I seeing this", image: "info-circle-outline")
            }
            Button(action: {}) {
                Text("Snooze for 30 days")
                Image("clock-outline")
            }
            Divider()
            Button(action: {}) {
                Label("Content preferences", image: "filter-sliders-outline")
            }
        } label: {
            FDSIconButton(icon: "dots-3-horizontal", size: size, color: color, action: {})
        }
        .tint(Color("primaryIcon"))
    }
}

// MARK: Story Data

struct StoryData: Hashable {
    var userName: String
    var storyImage: String
    var profileImage: String
    var segments: [String]
}

let storyData = [
    StoryData(userName: "Alice Smith", storyImage: "story1", profileImage: "profile3", segments: ["story1", "image1", "image2"]),
    StoryData(userName: "Bob Johnson", storyImage: "story2", profileImage: "profile2", segments: ["story2", "image3", "ocean"]),
    StoryData(userName: "Fatih Tekin", storyImage: "story3", profileImage: "profile9", segments: ["story3", "image4", "image5"]),
    StoryData(userName: "Diana Ross", storyImage: "story4", profileImage: "profile4", segments: ["story4", "image6"]),
    StoryData(userName: "Tina Wright", storyImage: "story5", profileImage: "profile6", segments: ["story5", "image7", "image8"]),
    StoryData(userName: "Kelsey Fung", storyImage: "story6", profileImage: "profile11", segments: ["story6", "jade1", "jade2"]),
    StoryData(userName: "Taina Thomsen", storyImage: "story7", profileImage: "profile7", segments: ["story7", "jade3", "jadesurfs"]),
    StoryData(userName: "Alex Kim", storyImage: "story8", profileImage: "profile5", segments: ["story8", "bandpractice1", "bandpractice2"]),
]

// MARK: Post Data

struct ActionChipData: Hashable {
    var label: String
    var iconName: String?
}

// MARK: - Post Attachments

indirect enum PostAttachment: Hashable {
    case photos([String])
    case link(LinkAttachmentData)
    case reshare(ResharedPostData)
}

struct LinkAttachmentData: Hashable {
    var imageName: String
    var title: String
    var url: String

    var domain: String {
        guard let url = URL(string: url),
              let host = url.host else {
            return url
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }
}

struct ResharedPostData: Hashable {
    var userName: String
    var timeStamp: String
    var profileImage: String
    var text: String?
    var attachment: PostAttachment?
}

struct PostData: Hashable {
    var id: Int
    var userName: String
    var timeStamp: String
    var profileImage: String
    var attachment: PostAttachment?
    var text: String?
    var actionChips: [ActionChipData]?
    var groupName: String?
    var groupImage: String?
    var likeCount: Int?
    var commentCount: Int?
    var shareCount: Int?
    var reactions: [String]?
}

var postData = [
    PostData(id: 1, userName: "Alice Smith", timeStamp: "2m", profileImage: "profile3", attachment: .photos(["image1"]), text:"Spring brights, all sustainable vintage clothing! everything shown was made before 1982, except the 🌼", actionChips: nil),
    
    PostData(id: 2, userName: "Bob Johnson", timeStamp: "1h", profileImage: "profile2", attachment: nil, text: "just finished my morning coffee and already planning my next adventure. anyone else feel like the day has endless possibilities?", actionChips: nil),
    
    PostData(id: 15, userName: "Diana Ross", timeStamp: "35m", profileImage: "profile4", attachment: .reshare(ResharedPostData(userName: "Sarah Chen", timeStamp: "2h", profileImage: "profile10", text: "My little plant babies are growing so nicely 🌿", attachment: .photos(["product3"]))), text: "Your plants look amazing! Need some tips for mine 🪴", actionChips: nil),

    PostData(id: 13, userName: "John Stockholm", timeStamp: "45m", profileImage: "profile12", attachment: .photos(["bandpractice1"]), text: "Thanks to everyone who joined last night—what a crowd! Still recovering from all the high notes.", actionChips: nil, groupName: "Karaoke Rockstars of Chicago", groupImage: "groupcover"),

    PostData(id: 3, userName: "Fatih Tekin", timeStamp: "19m", profileImage: "profile9", attachment: .photos(["image5"]), text: "I love putting Eddie in a costume...gets me every time! 🐶", actionChips: [
        ActionChipData(label: "Are Corgis good dogs?", iconName: "fb-meta-ai-assistant"),
        ActionChipData(label: "Where are Corgis bred?", iconName: nil),
        ActionChipData(label: "Costume ideas for Corgis", iconName: nil),
        ActionChipData(label: "How much do Corgis weigh", iconName: nil)
    ]),
    
    PostData(id: 16, userName: "Alex Kim", timeStamp: "15m", profileImage: "profile5", attachment: .photos(["bandpractice1", "bandpractice2"]), text: "Band practice was fire today 🎸🔥", actionChips: nil),
    
    PostData(id: 4, userName: "Diana Ross", timeStamp: "5m", profileImage: "profile4", attachment: nil, text: "Where can I find skate spots in SLC that are off the beaten path?", actionChips: nil),
    
    PostData(id: 17, userName: "Kelsey Fung", timeStamp: "25m", profileImage: "profile11", attachment: .photos(["jade1", "jade2", "jade3"]), text: "Best weekend getaway 🌊", actionChips: nil),
    
    PostData(id: 5, userName: "Tina Wright", timeStamp: "20m", profileImage: "profile6", attachment: .photos(["image4"]), text: "vibes on point", actionChips: nil),
    
    PostData(id: 6, userName: "Kelsey Fung", timeStamp: "4h", profileImage: "profile11", attachment: nil, text: "just got back from Diplo's Run Club. feeling so energized!", actionChips: nil),
    
    PostData(id: 7, userName: "Taina Thomsen", timeStamp: "2h", profileImage: "profile7", attachment: .link(LinkAttachmentData(imageName: "link-attachment", title: "Roberta's Pizza Dough Recipe - NYT Cooking", url: "https://cooking.nytimes.com/recipes/1016230-robertas-pizza-dough")), text:"y'all, THIS is the winning recipe. You don't need a stand mixer, either.", actionChips: nil),

    PostData(id: 8, userName: "Alex Kim", timeStamp: "10m", profileImage: "profile5", attachment: .photos(["image2"]), text: "went to the competition. incredible energy!! if you feel stuck, go to one for serious motivation", actionChips: nil),
    
    PostData(id: 9, userName: "Sarah Chen", timeStamp: "30m", profileImage: "profile10", attachment: nil, text:"New design system just dropped at work! So excited to finally share what we've been working on ✨", actionChips: nil),
    
    PostData(id: 10, userName: "Sarah Chen", timeStamp: "30m", profileImage: "profile10", attachment: .photos(["product3"]), text:"My little plant babies are growing so nicely 🌿", actionChips: nil),
    
    PostData(id: 11, userName: "Taina Thomsen", timeStamp: "12m", profileImage: "profile7", attachment: nil, text: "Just finished my morning run! Nothing beats that post-workout feeling 🏃‍♂️💪", actionChips: nil),
    
    PostData(id: 12, userName: "Jamie Lee", timeStamp: "25m", profileImage: "profile8", attachment: nil, text: "Anyone else obsessed with this new coffee shop downtown? Their oat milk latte is incredible ☕️", actionChips: nil),
    
    PostData(id: 18, userName: "Alice Smith", timeStamp: "40m", profileImage: "profile3", attachment: .photos(["image1", "image2", "image4", "image5"]), text: "Had an amazing weekend! 📸", actionChips: nil),
    
    PostData(id: 19, userName: "Bob Johnson", timeStamp: "50m", profileImage: "profile2", attachment: .photos(["jade1", "jade2", "jade3", "image1", "image2", "image4"]), text: "So many great memories from this trip! 🌴✨", actionChips: nil),
    
    PostData(id: 20, userName: "Daniela Giménez", timeStamp: "3h", profileImage: "profile1", attachment: .photos(["jade1", "jade2"]), text: "Weekend vibes at the beach 🌊 Nothing beats the sound of waves and good company!", actionChips: nil),
    
    PostData(id: 21, userName: "Daniela Giménez", timeStamp: "1d", profileImage: "profile1", attachment: nil, text: "Just finished reading an amazing book! Any recommendations for what to read next? 📚", actionChips: nil),
]

#Preview {
    HomeTab()
        .environmentObject(FDSTabBarHelper())
        .environmentObject(DrawerStateManager())
}
