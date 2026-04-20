import SwiftUI

// MARK: - Photo View
struct PhotoView: View {
    @Binding var isPresented: Bool
    let imageNames: [String]
    let startingIndex: Int
    let postData: PhotoViewPostData?
    
    @State private var currentIndex: Int
    @State private var dragOffset: CGFloat = 0
    @State private var hasCrossedThreshold: Bool = false
    @State private var isDragging: Bool = false
    @State private var likeCount: Int
    @State private var isLiked: Bool = false
    @State private var commentCount: Int
    @State private var shareCount: Int
    @State private var reactions: [String]
    @State private var showShareSheet: Bool = false
    
    init(isPresented: Binding<Bool>, imageNames: [String], startingIndex: Int = 0, postData: PhotoViewPostData? = nil) {
        self._isPresented = isPresented
        self.imageNames = imageNames
        self.startingIndex = startingIndex
        self.postData = postData
        self._currentIndex = State(initialValue: startingIndex)
        self._likeCount = State(initialValue: postData?.likeCount ?? 0)
        self._commentCount = State(initialValue: postData?.commentCount ?? 0)
        self._shareCount = State(initialValue: postData?.shareCount ?? 0)
        self._reactions = State(initialValue: postData?.reactions ?? [])
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
    
    private func calculateImageDisplaySize(imageName: String, containerWidth: CGFloat) -> CGSize {
        guard let uiImage = UIImage(named: imageName) else {
            return CGSize(width: containerWidth, height: containerWidth)
        }
        
        let imageSize = uiImage.size
        guard imageSize.width > 0 else {
            return CGSize(width: containerWidth, height: containerWidth)
        }
        
        // Scale to fit container width while maintaining aspect ratio
        let scaleFactor = containerWidth / imageSize.width
        let displayHeight = imageSize.height * scaleFactor
        
        return CGSize(width: containerWidth, height: displayHeight)
    }
    
    var body: some View {
        ZStack {
            // Black background that fades during dismissal
            Color.black
                .ignoresSafeArea()
                .opacity(1 - (abs(dragOffset) / 150.0))
            
            // Blurred background image
            GeometryReader { geometry in
                let imageSize = calculateImageDisplaySize(
                    imageName: imageNames[currentIndex],
                    containerWidth: geometry.size.width
                )
                let blurHeight = imageSize.height + 400
                
                Image(imageNames[currentIndex])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: blurHeight)
                    .blur(radius: 40)
                    .opacity(1 - (abs(dragOffset) / 150.0))
                    .clipped()
                    .mask(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: Color.white.opacity(0.75), location: 0.5),
                                .init(color: .clear, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .transition(.opacity)
                    .id(currentIndex)
            }
            .ignoresSafeArea()
            .animation(.swapShuffleIn(MotionDuration.extraLong), value: currentIndex)
            
            // Images - TabView for multiple, single Image for one
            if imageNames.count > 1 {
                TabView(selection: $currentIndex) {
                    ForEach(0..<imageNames.count, id: \.self) { index in
                        PhotoPageView(
                            imageName: imageNames[index],
                            dragOffset: $dragOffset,
                            isDragging: $isDragging,
                            hasCrossedThreshold: $hasCrossedThreshold,
                            isPresented: $isPresented
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            } else {
                PhotoPageView(
                    imageName: imageNames[0],
                    dragOffset: $dragOffset,
                    isDragging: $isDragging,
                    hasCrossedThreshold: $hasCrossedThreshold,
                    isPresented: $isPresented
                )
            }
            
            // Header with navigation bar (fixed position, fades out when dragging)
            VStack(spacing: 0) {
                FDSNavigationBarCentered(
                    title: imageNames.count > 1 ? "\(currentIndex + 1) of \(imageNames.count)" : nil,
                    backAction: {
                        withAnimation(.exitOut) {
                            isPresented = false
                        }
                    },
                    backIcon: "cross-filled",
                    onMedia: true,
                    icon3: {
                        FDSIconButton(
                            icon: "dots-3-horizontal-outline",
                            size: .size24,
                            color: .primary,
                            onMedia: true,
                            action: {}
                        )
                    }
                )
                .opacity(isDragging ? 0 : 1)
                .animation(.fadeOut(MotionDuration.extraShortOut), value: isDragging)
                
                Spacer()
            }
            
            // Bottom section with post metadata and reaction bar
            if let postData = postData {
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Post metadata (name and time)
                        VStack(alignment: .leading, spacing: 10) {
                            // Headline (actor name for normal posts, group name for group posts)
                            if let groupName = postData.groupName {
                                Text(groupName)
                                    .headline4EmphasizedTypography()
                                    .foregroundStyle(Color("primaryTextOnMedia"))
                                    .textOnMediaShadow()
                            } else {
                                Text(postData.userName)
                                    .headline4EmphasizedTypography()
                                    .foregroundStyle(Color("primaryTextOnMedia"))
                                    .textOnMediaShadow()
                            }
                            
                            // Timestamp with actor name for group posts
                            HStack(alignment: .center, spacing: 4) {
                                if postData.groupName != nil {
                                    Text(postData.userName)
                                        .meta4Typography()
                                        .foregroundStyle(Color("secondaryTextOnMedia"))
                                        .textOnMediaShadow()
                                    Text("·")
                                        .meta4Typography()
                                        .foregroundStyle(Color("secondaryTextOnMedia"))
                                        .textOnMediaShadow()
                                }
                                
                                Text(postData.timeStamp)
                                    .meta4Typography()
                                    .foregroundStyle(Color("secondaryTextOnMedia"))
                                    .textOnMediaShadow()
                                Text("·")
                                    .meta4Typography()
                                    .foregroundStyle(Color("secondaryTextOnMedia"))
                                    .textOnMediaShadow()
                                Image("globe-americas-12")
                                    .foregroundColor(Color("secondaryIconOnMedia"))
                                    .iconOnMediaShadow()
                                    .frame(width: 12, height: 12)
                                    .frame(height: 8)
                            }
                        }
                        
                        // Reaction bar
                        HStack(alignment: .center, spacing: 0) {
                            HStack(alignment: .center, spacing: 4) {
                                ReactionPicker(
                                    count: likeCount,
                                    onSelect: { reaction in
                                        withAnimation {
                                            if !isLiked {
                                                likeCount += 1
                                                isLiked = true
                                            }
                                        }
                                    },
                                    onDeselect: {
                                        withAnimation {
                                            if isLiked {
                                                likeCount -= 1
                                                isLiked = false
                                            }
                                        }
                                    },
                                    onMedia: true
                                )
                                
                                Button(action: {}) {
                                    HStack(spacing: 6) {
                                        Image("comment-outline")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color("secondaryIconOnMedia"))
                                            .iconOnMediaShadow()
                                            .frame(width: 20, height: 20)
                                        
                                        if commentCount > 0 {
                                            Text(formatNumber(commentCount))
                                                .body4LinkTypography()
                                                .foregroundColor(Color("secondaryTextOnMedia"))
                                                .textOnMediaShadow()
                                        }
                                    }
                                    .frame(height: 36)
                                    .padding(.horizontal, 8)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(FDSPressedState(cornerRadius: 8, isOnMedia: true))
                                
                                Button(action: { showShareSheet = true }) {
                                    HStack(spacing: 6) {
                                        Image("share-outline")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color("secondaryIconOnMedia"))
                                            .iconOnMediaShadow()
                                            .frame(width: 20, height: 20)
                                        
                                        if shareCount > 0 {
                                            Text(formatNumber(shareCount))
                                                .body4LinkTypography()
                                                .foregroundColor(Color("secondaryTextOnMedia"))
                                                .textOnMediaShadow()
                                        }
                                    }
                                    .frame(height: 36)
                                    .padding(.horizontal, 8)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(FDSPressedState(cornerRadius: 8, isOnMedia: true))
                            }
                            
                            Spacer()
                            
                            InlineReactionsOnMedia(reactions: reactions)
                                .padding(.trailing, 12)
                        }
                        .padding(.leading, -8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)
                    .opacity(isDragging ? 0 : 1)
                    .animation(.fadeOut(MotionDuration.extraShortOut), value: isDragging)
                }
            }
        }
        .presentationBackground(.clear)
        .sheet(isPresented: $showShareSheet) {
            ShareBottomSheet(
                post: PostData(
                    id: 0,
                    userName: postData?.userName ?? "Unknown",
                    timeStamp: postData?.timeStamp ?? "",
                    profileImage: "profile1",
                    attachment: .photos(imageNames),
                    text: nil
                ),
                onShare: { text in
                    // Photo view share - can be enhanced later
                    print("Share from photo view: \(text)")
                }
            )
        }
    }
}

// MARK: - Photo Page View
struct PhotoPageView: View {
    let imageName: String
    @Binding var dragOffset: CGFloat
    @Binding var isDragging: Bool
    @Binding var hasCrossedThreshold: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .ignoresSafeArea()
            .offset(y: dragOffset)
            .scaleEffect(1 - (abs(dragOffset) / 2000.0))
            .opacity(1 - (abs(dragOffset) / 800.0))
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        // Only allow downward dragging
                        if value.translation.height > 0 {
                            isDragging = true
                            dragOffset = value.translation.height
                            
                            // Trigger haptic when crossing dismissal threshold
                            if value.translation.height > 150 && !hasCrossedThreshold {
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                                hasCrossedThreshold = true
                            }
                        }
                    }
                    .onEnded { value in
                        // Dismiss if dragged down more than 150 points
                        if value.translation.height > 150 {
                            hasCrossedThreshold = false
                            // Keep isDragging = true so buttons stay hidden during dismissal
                            withAnimation(.exitOut) {
                                isPresented = false
                            }
                        } else {
                            // Bounce back with animation
                            withAnimation(.swapShuffleIn(MotionDuration.shortIn)) {
                                dragOffset = 0
                                isDragging = false
                            }
                            hasCrossedThreshold = false
                        }
                    }
            )
    }
}

// MARK: - Inline Reactions (On Media variant)

struct InlineReactionsOnMedia: View {
    let reactions: [String]
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(reactions.enumerated()), id: \.element) { index, reaction in
                ZStack {
                    Image(reaction)
                        .resizable()
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .strokeBorder(Color.black, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .blendMode(.destinationOut)
                }
                .frame(width: 16, height: 16)
                .zIndex(Double(reactions.count - index))
            }
        }
        .compositingGroup()
    }
}

// MARK: - Photo View Post Data

public struct PhotoViewPostData {
    let userName: String
    let timeStamp: String
    let groupName: String?
    let likeCount: Int
    let commentCount: Int
    let shareCount: Int
    let reactions: [String]
    
    public init(
        userName: String,
        timeStamp: String,
        groupName: String? = nil,
        likeCount: Int = 0,
        commentCount: Int = 0,
        shareCount: Int = 0,
        reactions: [String] = []
    ) {
        self.userName = userName
        self.timeStamp = timeStamp
        self.groupName = groupName
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.shareCount = shareCount
        self.reactions = reactions
    }
}

// MARK: - Photo View Item

public struct PhotoViewItem: Identifiable {
    public let id = UUID()
    public let imageNames: [String]
    public let startingIndex: Int
    public let postData: PhotoViewPostData?
    
    public init(imageNames: [String], startingIndex: Int, postData: PhotoViewPostData? = nil) {
        self.imageNames = imageNames
        self.startingIndex = startingIndex
        self.postData = postData
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        
        let samplePostData = PhotoViewPostData(
            userName: "Sarah Chen",
            timeStamp: "2h",
            groupName: nil,
            likeCount: 24,
            commentCount: 8,
            shareCount: 12,
            reactions: ["like", "love", "haha"]
        )
        
        var body: some View {
            PhotoView(
                isPresented: $isPresented,
                imageNames: ["ocean", "image2", "image3"],
                startingIndex: 0,
                postData: samplePostData
            )
        }
    }
    
    return PreviewWrapper()
}

