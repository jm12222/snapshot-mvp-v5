import SwiftUI
import AVKit
import AVFoundation

// MARK: - Snapshot Reel Player View (Exact ReelsTabView Structure)
// This is the EXACT structure from ReelsTabView.swift in facebook-template-v0.4
// Modified to show multiple snapshot reels and include a back button

struct SnapshotReelPlayerView: View {
    let topicId: Int
    let mediaIndex: Int
    @Binding var isPresented: Bool
    @Binding var lastViewedTopicName: String?
    @State private var currentReelIndex: Int? = 0
    @State private var is2xSpeed = false
    @StateObject private var tabBarHelper = FDSTabBarHelper()
    @State private var shuffledReels: [FacebookReel] = []
    @State private var autoAdvanceTimer: Timer? = nil
    
    // Single reel per topic (default behavior)
    private var snapshotReels: [FacebookReel] {
        [
            FacebookReel(
                id: "snapshot1",
                username: "Becker Threads",
                profileImage: "pantone-1",
                caption: "Cloud Dancer by Pantone - the 2026 Color of the Year 🎨",
                timeAgo: "now",
                likes: 342,
                comments: 127,
                shares: 42,
                videoFileName: "Pantone video",
                verified: false,
                topicName: "Pantone's Color of the Year"
            ),
            FacebookReel(
                id: "snapshot2",
                username: "Denver Nuggets",
                profileImage: "nba_1",
                caption: "Jokic continues to dominate the MVP race 🏀",
                timeAgo: "2h",
                likes: 1240,
                comments: 256,
                shares: 89,
                videoFileName: "surf",
                verified: true,
                topicName: "Jokic MVP Race"
            ),
            FacebookReel(
                id: "snapshot3",
                username: "Children's Museum",
                profileImage: "winter1",
                caption: "Winter programs now open for registration ❄️",
                timeAgo: "4h",
                likes: 567,
                comments: 89,
                shares: 34,
                videoFileName: "dancing",
                verified: false,
                topicName: "Winter Programs"
            ),
            FacebookReel(
                id: "snapshot4",
                username: "Healthy Kids",
                profileImage: "ffmeal_1",
                caption: "High protein toddler snacks for busy parents 🍌",
                timeAgo: "6h",
                likes: 892,
                comments: 145,
                shares: 67,
                videoFileName: "handsin",
                verified: false,
                topicName: "Toddler Snacks"
            ),
            FacebookReel(
                id: "snapshot5",
                username: "Denver Eats",
                profileImage: "denver1",
                caption: "Restaurant Week is here! Check out these amazing spots 🍣",
                timeAgo: "8h",
                likes: 1456,
                comments: 234,
                shares: 123,
                videoFileName: "ocean",
                verified: true,
                topicName: "Restaurant Week"
            ),
            FacebookReel(
                id: "snapshot6",
                username: "Space News",
                profileImage: "profile14",
                caption: "SpaceX Starship could launch again this week pending FAA clearance 🚀",
                timeAgo: "10h",
                likes: 2134,
                comments: 412,
                shares: 198,
                videoFileName: "surf",
                verified: true,
                topicName: "SpaceX Starship"
            )
        ]
    }
    
    // MARK: - Single Topic Chaining Experience - End Card (commented out)
    // Chained reels for Pantone first media — 3 videos from same topic then end card
    //
    // private var pantoneChainedReels: [FacebookReel] {
    //     [
    //         FacebookReel(
    //             id: "pantone-chain-1",
    //             username: "Becker Threads",
    //             profileImage: "pantone-1",
    //             caption: "Cloud Dancer by Pantone - the 2026 Color of the Year 🎨",
    //             timeAgo: "now",
    //             likes: 342,
    //             comments: 127,
    //             shares: 42,
    //             videoFileName: "Pantone video1",
    //             verified: false,
    //             topicName: "Pantone's Color of the Year"
    //         ),
    //         FacebookReel(
    //             id: "pantone-chain-2",
    //             username: "Color Trends",
    //             profileImage: "pantone_new_2",
    //             caption: "How Cloud Dancer is already influencing spring fashion collections worldwide ✨",
    //             timeAgo: "3h",
    //             likes: 1089,
    //             comments: 203,
    //             shares: 78,
    //             videoFileName: "Pantone video2",
    //             verified: false,
    //             topicName: "Pantone's Color of the Year"
    //         ),
    //         FacebookReel(
    //             id: "pantone-chain-3",
    //             username: "Studio Palette",
    //             profileImage: "pantone-2",
    //             caption: "Interior designers react to Pantone's softest pick in a decade 🏠",
    //             timeAgo: "5h",
    //             likes: 756,
    //             comments: 164,
    //             shares: 55,
    //             videoFileName: "Pantone video3",
    //             verified: false,
    //             topicName: "Pantone's Color of the Year"
    //         )
    //     ]
    // }
    
    // MARK: - Multi Topic Chaining Experience (active)
    // Chained reels for Pantone first media — videos across multiple topics, auto-advance to Jokic
    private var pantoneMultiTopicChainedReels: [FacebookReel] {
        [
            FacebookReel(
                id: "pantone-chain-1",
                username: "Becker Threads",
                profileImage: "pantone-1",
                caption: "Cloud Dancer by Pantone - the 2026 Color of the Year 🎨",
                timeAgo: "now",
                likes: 342,
                comments: 127,
                shares: 42,
                videoFileName: "Pantone video1",
                verified: false,
                topicName: "Pantone's Color of the Year"
            ),
            FacebookReel(
                id: "pantone-chain-2",
                username: "Color Trends",
                profileImage: "pantone_new_2",
                caption: "How Cloud Dancer is already influencing spring fashion collections worldwide ✨",
                timeAgo: "3h",
                likes: 1089,
                comments: 203,
                shares: 78,
                videoFileName: "Pantone video2",
                verified: false,
                topicName: "Pantone's Color of the Year"
            ),
            FacebookReel(
                id: "pantone-chain-3",
                username: "Studio Palette",
                profileImage: "pantone-2",
                caption: "Interior designers react to Pantone's softest pick in a decade 🏠",
                timeAgo: "5h",
                likes: 756,
                comments: 164,
                shares: 55,
                videoFileName: "Pantone video3",
                verified: false,
                topicName: "Pantone's Color of the Year"
            ),
            FacebookReel(
                id: "jokic-chain-0",
                username: "Mile High Sports",
                profileImage: "nba_2",
                caption: "Another night, another Jokic triple-double 🃏",
                timeAgo: "1h",
                likes: 980,
                comments: 312,
                shares: 104,
                videoFileName: "jocik_3n",
                verified: false,
                topicName: "Jokic MVP race lead"
            ),
            FacebookReel(
                id: "jokic-chain-1",
                username: "Denver Nuggets",
                profileImage: "nba_1",
                caption: "Jokic continues to dominate the MVP race 🏀",
                timeAgo: "2h",
                likes: 1240,
                comments: 256,
                shares: 89,
                videoFileName: "jocik_1",
                verified: true,
                topicName: "Jokic MVP race lead"
            ),
            FacebookReel(
                id: "meals-chain-1",
                username: "Healthy Kids",
                profileImage: "ffmeal_1",
                caption: "Family-friendly meals the whole crew will actually eat 🍽️",
                timeAgo: "4h",
                likes: 892,
                comments: 145,
                shares: 67,
                videoFileName: "Family-friendly meals_silent",
                verified: false,
                topicName: "Family-friendly meals"
            )
        ]
    }
    
    // MARK: - Single Topic with Swipe Up (commented out)
    // Chained reels for Pantone first media — 3 videos from same topic then end card
    //
    // private var pantoneSingleTopicSwipeUpReels: [FacebookReel] {
    //     [
    //         FacebookReel(
    //             id: "pantone-chain-1",
    //             username: "Becker Threads",
    //             profileImage: "pantone-1",
    //             caption: "Cloud Dancer by Pantone - the 2026 Color of the Year 🎨",
    //             timeAgo: "now",
    //             likes: 342,
    //             comments: 127,
    //             shares: 42,
    //             videoFileName: "Pantone video1",
    //             verified: false,
    //             topicName: "Pantone's Color of the Year"
    //         ),
    //         FacebookReel(
    //             id: "pantone-chain-2",
    //             username: "Color Trends",
    //             profileImage: "pantone_new_2",
    //             caption: "How Cloud Dancer is already influencing spring fashion collections worldwide ✨",
    //             timeAgo: "3h",
    //             likes: 1089,
    //             comments: 203,
    //             shares: 78,
    //             videoFileName: "Pantone video2",
    //             verified: false,
    //             topicName: "Pantone's Color of the Year"
    //         ),
    //         FacebookReel(
    //             id: "pantone-chain-3",
    //             username: "Studio Palette",
    //             profileImage: "pantone-2",
    //             caption: "Interior designers react to Pantone's softest pick in a decade 🏠",
    //             timeAgo: "5h",
    //             likes: 756,
    //             comments: 164,
    //             shares: 55,
    //             videoFileName: "Pantone video3",
    //             verified: false,
    //             topicName: "Pantone's Color of the Year"
    //         )
    //     ]
    // }
    
    private var isPantoneChaining: Bool {
        topicId == 1 && mediaIndex == 0
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<shuffledReels.count, id: \.self) { index in
                                ReelVideoPlayer(
                                    reel: shuffledReels[index],
                                    reelIndex: index,
                                    isCurrentReel: currentReelIndex == index,
                                    bottomInset: 80,
                                    is2xSpeed: $is2xSpeed
                                )
                                .containerRelativeFrame([.horizontal, .vertical])
                                .clipped()
                                .id(index)
                            }
                            
                            if isPantoneChaining && !shuffledReels.isEmpty {
                                Image("chaining_endcard_1")
                                    .resizable()
                                    .scaledToFill()
                                    .containerRelativeFrame([.horizontal, .vertical])
                                    .clipped()
                                    .id(shuffledReels.count)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                    .scrollPosition(id: $currentReelIndex)
                    .background(Color("alwaysBlack"))
                    .statusBarHidden(false)
                    .ignoresSafeArea(.all, edges: .vertical)
                    
                    // Bottom "Add a comment" bar
                    VStack {
                            Spacer()
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Add a comment")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color.white.opacity(0.5))
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                
                                Color.black
                                    .frame(height: geometry.safeAreaInsets.bottom)
                            }
                            .background(Color.black)
                        }
                        .ignoresSafeArea(.all, edges: .bottom)
                    
                    // Top navigation bar
                    VStack(spacing: 0) {
                            VStack(spacing: 0) {
                                Color.clear
                                    .frame(height: geometry.safeAreaInsets.top)
                                
                                HStack(alignment: .center, spacing: 8) {
                                    Button(action: {
                                        syncLastViewedTopic()
                                        isPresented = false
                                    }) {
                                        Image("chevron-left-filled")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(Color("primaryIconOnMedia"))
                                    }
                                    .padding(.leading, 12)
                                    
                                    if let currentIndex = currentReelIndex,
                                       currentIndex < shuffledReels.count,
                                       let topicName = shuffledReels[currentIndex].topicName {
                                        Text(topicName)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(Color("primaryIconOnMedia"))
                                    }
                                    
                                    Spacer()
                                }
                                .frame(height: 52)
                                .opacity(is2xSpeed ? 0 : 1)
                                .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                            }
                            .background(
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
                                .frame(height: 180)
                                .opacity(is2xSpeed ? 0 : 1)
                                .animation(.swapShuffleIn(MotionDuration.shortIn), value: is2xSpeed)
                            )
                            Spacer()
                        }
                        .ignoresSafeArea(.all, edges: .top)
                }
            }
            .onChange(of: currentReelIndex) { _, newIndex in
                tabBarHelper.currentReelIndex = newIndex
                if let idx = newIndex, idx < shuffledReels.count {
                    lastViewedTopicName = shuffledReels[idx].topicName
                }
                if isPantoneChaining, let idx = newIndex, idx < shuffledReels.count {
                    startAutoAdvanceTimer()
                }
            }
            .onAppear {
                if isPantoneChaining {
                    shuffledReels = pantoneMultiTopicChainedReels
                } else {
                    let startIndex = max(0, min(topicId - 1, snapshotReels.count - 1))
                    shuffledReels = [snapshotReels[startIndex]]
                }
                currentReelIndex = 0
                tabBarHelper.currentReelIndex = currentReelIndex
                if !shuffledReels.isEmpty {
                    lastViewedTopicName = shuffledReels[0].topicName
                }
                if isPantoneChaining {
                    startAutoAdvanceTimer()
                }
            }
            .onDisappear {
                autoAdvanceTimer?.invalidate()
                autoAdvanceTimer = nil
            }
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width > 100 {
                            syncLastViewedTopic()
                            isPresented = false
                        }
                    }
            )
        }
        .environmentObject(tabBarHelper)
    }
    
    private func startAutoAdvanceTimer() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            guard let current = currentReelIndex else { return }
            let nextIndex = current + 1
            if nextIndex <= shuffledReels.count {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentReelIndex = nextIndex
                }
            }
        }
    }
    
    private func syncLastViewedTopic() {
        if let idx = currentReelIndex, idx < shuffledReels.count {
            lastViewedTopicName = shuffledReels[idx].topicName
        }
    }
}
