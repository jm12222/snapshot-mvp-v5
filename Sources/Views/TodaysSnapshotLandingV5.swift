import SwiftUI
import AVKit
import AVFoundation
import CoreMedia

// MARK: - Today's Snapshot v5

struct TodaysSnapshotLandingV5: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @AppStorage("snapshotDemoMode") private var currentDemoMode: String = SnapshotDemoMode.v5.rawValue
    @AppStorage("snapshotShowOnboarding") private var currentOnboardingVariant: String = SnapshotOnboardingVariant.off.rawValue
    @AppStorage("snapshotSearchVariant") private var currentSearchVariant: String = SnapshotSearchVariant.off.rawValue
    @AppStorage("snapshotMediaCardVariant") private var currentMediaCardVariant: String = MediaCardVariant.whiteCard.rawValue
    @AppStorage("snapshotExpandedFooter") private var currentFooterVariant: String = SnapshotFooterVariant.compact.rawValue
    @AppStorage("snapshotTextHierarchy") private var currentTextHierarchy: String = TextHierarchyVariant.heavy.rawValue
    @State private var showSecretMenu = false
    @State private var showContextualMessage = true
    @State private var showOnboardingQuiz = false
    @State private var scrollOffset: CGFloat = 0
    @State private var initialY: CGFloat = 0
    @State private var showVideoPlayer = false
    @State private var selectedTopicId: Int = 1
    @State private var selectedMediaIndex: Int = 0
    @State private var expandedUnits: [Int: Bool] = [:]
    @State private var showSourcesSheet: Int? = nil
    @State private var isProgrammaticScroll = false
    @State private var footerStarRating: Int = 0
    @State private var showRatingToast = false
    @State private var showTopicPicker = false
    @State private var selectedTopicChips: Set<String> = []
    @State private var lastViewedTopicName: String? = nil
    @State private var unitFeedback: [Int: String] = [:]
    @State private var showFeedbackToast = false
    @State private var feedbackToastUnitId: Int? = nil
    @State private var selectedPivotQuery: String? = nil
    
    // DEBUG: Toggle this to show/hide scroll position indicator
    private let showScrollDebug = false
    
    var body: some View {
        ScrollViewReader { proxy in
            mainScrollContent(proxy: proxy)
                .navigationBarHidden(true)
                .onChange(of: footerStarRating) { oldValue, newValue in
                    if oldValue == 0 && newValue > 0 {
                        showRatingToast = true
                        isProgrammaticScroll = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.easeInOut(duration: 0.45)) {
                                proxy.scrollTo("footer", anchor: .bottom)
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            isProgrammaticScroll = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showTopicPicker = true
                            }
                            isProgrammaticScroll = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                withAnimation(.easeInOut(duration: 0.45)) {
                                    proxy.scrollTo("footer", anchor: .bottom)
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                isProgrammaticScroll = false
                            }
                        }
                    }
                }
                .onChange(of: showVideoPlayer) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        isProgrammaticScroll = true
                        if let topicName = lastViewedTopicName {
                            let targetUnit = topicNameToSnapshotId(topicName)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.45)) {
                                    proxy.scrollTo("snapshot-\(targetUnit)", anchor: .top)
                                }
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            isProgrammaticScroll = false
                        }
                    }
                }
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            SnapshotReelPlayerView(topicId: selectedTopicId, mediaIndex: selectedMediaIndex, isPresented: $showVideoPlayer, lastViewedTopicName: $lastViewedTopicName)
                .transition(.move(edge: .trailing))
        }
        .navigationDestination(item: $selectedPivotQuery) { query in
            SearchAIExplorerView(queryTitle: query)
        }
        .overlay(sourcesOverlay)
        .overlay {
            InstantFeedbackContainer(
                isVisible: $showRatingToast,
                content: "Thanks for your feedback!",
                actionText: "Undo",
                leftAddOn: .none,
                onAction: {
                    footerStarRating = 0
                    showTopicPicker = false
                },
                autoDismissDelay: 2.0,
                entryDelay: 0,
                bottomPadding: 42
            )
        }
        .overlay {
            InstantFeedbackContainer(
                isVisible: $showFeedbackToast,
                content: "Feedback submitted.",
                actionText: nil,
                leftAddOn: .icon("hand-thumbs-up-outline"),
                onAction: nil,
                autoDismissDelay: 2.5
            )
        }
        .overlay(secretMenuOverlay)
        .fullScreenCover(isPresented: $showOnboardingQuiz) {
            OnboardingQuizView(onComplete: { _, _, _, _ in
                withAnimation(.moveOut(MotionDuration.shortOut)) {
                    showContextualMessage = false
                }
            })
        }
        .onChange(of: currentOnboardingVariant) { _, newValue in
            if newValue == SnapshotOnboardingVariant.on.rawValue {
                withAnimation(.moveIn(MotionDuration.shortIn)) {
                    showContextualMessage = true
                }
            }
        }
    }
    
    // MARK: - Main Scroll Content
    
    @ViewBuilder
    private func mainScrollContent(proxy: ScrollViewProxy) -> some View {
        ZStack(alignment: .topLeading) {
            mainContentLayer(proxy: proxy)
            debugOverlay
            floatingActionButton(proxy: proxy)
        }
    }
    
    // MARK: - Main Content Layer
    
    @ViewBuilder
    private func mainContentLayer(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Today's snapshot",
                backAction: {
                    if scrollOffset >= 10 {
                        withAnimation(.easeInOut(duration: 0.45)) {
                            proxy.scrollTo("header", anchor: .top)
                        }
                    } else {
                        if let onBack = onBack {
                            onBack()
                        } else {
                            dismiss()
                        }
                    }
                }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.6)
                    .onEnded { _ in
                        showSecretMenu = true
                    }
            )
            .shadow(
                color: scrollOffset >= 10 ? Color.black.opacity(0.1) : Color.clear,
                radius: scrollOffset >= 10 ? 4 : 0,
                x: 0,
                y: 1
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Page 1: Header + Highlights
                    VStack(spacing: 0) {
                        heroMediaCard
                            .id("header")
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onChange(of: geo.frame(in: .global).minY) { oldValue, newValue in
                                            if initialY == 0 {
                                                initialY = newValue
                                            }
                                            scrollOffset = max(0, initialY - newValue)
                                        }
                                }
                            )

                        headerSection

                        if currentOnboardingVariant == SnapshotOnboardingVariant.on.rawValue && showContextualMessage {
                            FDSContextualMessage(
                                headlineText: "✨ Personalize your daily snapshot",
                                bodyText: "Daily updates on what matters to you. Take a quick quiz to shape your feed.",
                                showDismiss: true,
                                onDismiss: {
                                    withAnimation(.moveOut(MotionDuration.shortOut)) {
                                        showContextualMessage = false
                                    }
                                },
                                bottomAddOn: .button(label: "Take quiz", variant: .primary, action: {
                                    showOnboardingQuiz = true
                                })
                            )
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        
                        highlightsSection(proxy: proxy)
                            .id("highlights")
                    }
                    .containerRelativeFrame(.vertical, alignment: .top)
                    
                    // Pages 2+: Snapshot Units (each full-page) + Footer
                    snapshotUnitsContainer(proxy: proxy)
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
        }
    }
    
    // MARK: - Snapshot Units Container
    
    @ViewBuilder
    private func snapshotUnitsContainer(proxy: ScrollViewProxy) -> some View {
        snapshotUnit(
            unitId: 1,
            title: "🎨 Pantone's color of the year",
            bodyText: "Pantone named Cloud Dancer its 2026 Color of the Year, signaling a shift toward softer palettes across design and fashion.",
            bullets: [
                "The warm off-white tone reflects a global desire for calm and simplicity in visual culture.",
                "Fashion houses are already incorporating Cloud Dancer into upcoming spring collections.",
                "Interior designers call it Pantone's softest and most versatile pick in over a decade."
            ],
            pivots: [
                (label: "Cloud Dancer", image: nil),
                (label: "Spring collections", image: nil),
                (label: "Interior design", image: nil)
            ],
            image1: "pantone_new_1",
            image2: "pantone_new_2",
            image3: "pantone-2",
            image4: "pantone-3",
            usernames: ["Design Weekly", "Color Trends", "Studio Palette", "Creative Space"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-1")
        
        snapshotUnit(
            unitId: 2,
            title: "🏀 Jokic MVP race lead",
            bodyText: "Despite missing recent games to minor injuries, Nikola Jokic remains the clear frontrunner in the MVP race this season.",
            bullets: [
                "His per-game efficiency and triple-double pace continue to separate him from other contenders.",
                "Denver's record without Jokic underscores how central he is to the team's success.",
                "Analysts say his playmaking and court control make the strongest case for a fourth MVP."
            ],
            pivots: [
                (label: "Nikola Jokic", image: nil),
                (label: "Denver Nuggets", image: nil),
                (label: "MVP race", image: nil)
            ],
            image1: "nba_1",
            image2: "nba_2",
            image3: "nba_3",
            image4: "nba_4",
            usernames: ["Nuggets Nation", "Mile High Sports", "NBA Central", "Hoop Digest"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-2")
        
        snapshotUnit(
            unitId: 3,
            title: "❄️ Children Museum winter programs",
            bodyText: "Denver's Children Museum launched new winter programs focused on movement, sensory play, and early learning for younger kids.",
            bullets: [
                "Sessions use shorter time blocks and caregiver-friendly pacing for toddlers and preschoolers.",
                "Indoor activities are designed to keep families active during Colorado's colder months.",
                "Registration is now open with limited spots available for the February session."
            ],
            pivots: [
                (label: "Children's Museum", image: nil),
                (label: "Winter programs", image: nil),
                (label: "Early learning", image: nil)
            ],
            image1: "WInterKids",
            image2: "WInterKids-1",
            image3: "WInterKids-2",
            image4: "WInterKids-3",
            usernames: ["Denver Museums", "Family Activities", "Kids Learning", "Play & Explore"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-3")
        
        snapshotUnit(
            unitId: 4,
            title: "🍌 High protein toddler snacks",
            bodyText: "Dietitians are sharing easy ways to boost protein in toddler snacks using pantry staples like hemp hearts and nut butters.",
            bullets: [
                "Hemp hearts are a complete protein with all nine essential amino acids in a toddler-safe form.",
                "Adding cottage cheese or Greek yogurt to fruit gives a quick protein bump without extra prep.",
                "Experts say small ingredient swaps can meaningfully support healthy growth in early years."
            ],
            pivots: [
                (label: "Hemp hearts", image: nil),
                (label: "Protein snacks", image: nil),
                (label: "Toddler meals", image: nil)
            ],
            image1: "toddler",
            image2: "toddler-1",
            image3: "toddler-2",
            image4: "toddler-3",
            usernames: ["Healthy Kids", "Parent Nutrition", "Toddler Meals", "Smart Snacks"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-4")
        
        snapshotUnit(
            unitId: 5,
            title: "🍣 Denver Restaurant Week",
            bodyText: "Denver Restaurant Week returns with multi-course prix-fixe menus across the metro area, giving diners a chance to explore at lower prices.",
            bullets: [
                "Participating restaurants span downtown, RiNo, LoHi, and neighborhoods across the city.",
                "Set price tiers make it easier to try higher-end spots that are usually harder to access.",
                "Reservations are already booking fast for the most popular locations this year."
            ],
            pivots: [
                (label: "RiNo District", image: nil),
                (label: "Prix-fixe menus", image: nil),
                (label: "Reservations", image: nil)
            ],
            image1: "DenverRestaruant",
            image2: "DenverRestaruant-1",
            image3: "DenverRestaruant-2",
            image4: "DenverRestaruant-3",
            usernames: ["Denver Eats", "Food Scene", "Mile High Dining", "Restaurant Guide"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-5")
        
        snapshotUnit(
            unitId: 6,
            title: "🚀 SpaceX Starship launch window",
            bodyText: "SpaceX is targeting a new Starship test flight as early as this week, pending final FAA clearance for the next-generation launch system.",
            bullets: [
                "The 48-hour launch window could open mid-week from Boca Chica with upgraded heat shielding.",
                "Rapid reusability tests on the booster stage are the primary objective for this flight.",
                "A successful mission would mark the fastest turnaround between Starship launches to date."
            ],
            pivots: [
                (label: "SpaceX", image: nil),
                (label: "Starship", image: nil),
                (label: "FAA clearance", image: nil)
            ],
            image1: "image1",
            image2: "image2",
            image3: "image3",
            image4: "image4",
            usernames: ["Space News", "Launch Watch", "Orbit Daily", "Rocket Report"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-6")
        
        footerSection
            .containerRelativeFrame(.vertical)
            .id("footer")
    }
    
    // MARK: - Debug Overlay
    
    @ViewBuilder
    private var debugOverlay: some View {
        if showScrollDebug {
            Text("\(Int(scrollOffset))")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.8))
                .cornerRadius(6)
                .padding(.leading, 12)
                .padding(.top, 8)
                .allowsHitTesting(false)
        }
    }
    
    // MARK: - Floating Action Button
    
    @ViewBuilder
    private func floatingActionButton(proxy: ScrollViewProxy) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if scrollOffset < 10 {
                    exploreMoreButton(proxy: proxy)
                }
                Spacer()
            }
        }
        .padding(.bottom, -6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(true)
    }
    
    @ViewBuilder
    private func exploreMoreButton(proxy: ScrollViewProxy) -> some View {
        Button {
            isProgrammaticScroll = true
            withAnimation(.easeInOut(duration: 0.45)) {
                proxy.scrollTo("snapshot-1", anchor: .top)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isProgrammaticScroll = false
            }
        } label: {
            HStack(spacing: 6) {
                Image("arrow-down-outline")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color("accentColor"))
                
                Text("More")
                    .body3LinkTypography()
                    .foregroundStyle(Color("accentColor"))
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 32)
            .background(
                RoundedRectangle(cornerRadius: 9999)
                    .fill(Color("cardBackground"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9999)
                    .stroke(Color("borderUiEmphasis"), lineWidth: 0.5)
            )
        }
        .buttonStyle(FDSPressedState(cornerRadius: 9999, scale: .medium))
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 2)
        .transition(.opacity)
    }
    
    @ViewBuilder
    private func nextItemButton(proxy: ScrollViewProxy) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.45)) {
                proxy.scrollTo("snapshot-1", anchor: .top)
            }
        } label: {
            Image("arrow-down-outline")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundStyle(Color("secondaryButtonText"))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(Color("cardBackground"))
                )
                .overlay(
                    Circle()
                        .stroke(Color("borderUiEmphasis"), lineWidth: 0.5)
                )
        }
        .buttonStyle(FDSPressedState(circle: true, scale: .medium))
        .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 2)
        .transition(.opacity)
    }
    
    // MARK: - Sources Overlay
    
    @ViewBuilder
    private var sourcesOverlay: some View {
        ZStack(alignment: .bottom) {
            if showSourcesSheet != nil {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSourcesSheet = nil
                        }
                    }
                    .transition(.opacity)
                
                sourcesBottomSheet(unitId: showSourcesSheet!)
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: showSourcesSheet)
    }
    
    // MARK: - Hero Media Card

    private var heroMediaCard: some View {
        mediaCard(
            imageName: "ski-colorado",
            title: "⛷️ Ski season in Colorado",
            body: "Resorts across the state are reporting some of the best conditions in years following a strong December snowpack."
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    private func mediaCard(imageName: String, title: String, body: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            .frame(height: 237)

            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0.0), location: 0.0),
                    .init(color: Color.black.opacity(0.10), location: 0.35),
                    .init(color: Color.black.opacity(0.40), location: 0.65),
                    .init(color: Color.black.opacity(0.55), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 160)
            .frame(maxWidth: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .headline3EmphasizedTypography()
                    .foregroundStyle(Color("primaryTextOnMedia"))
                    .textOnMediaShadow()
                Text(body)
                    .body3Typography()
                    .foregroundStyle(Color("secondaryTextOnMedia"))
                    .textOnMediaShadow()
                    .lineLimit(2)
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title + Meta Container with specific padding
            VStack(alignment: .leading, spacing: 0) {
                // Title
                Text(formattedDate)
                    .headline1EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                
                // 12px gap between title and meta
                Spacer().frame(height: 12)
                
                // Metadata
                HStack(spacing: 4) {
                    Image("gen-ai-star-filled")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color("secondaryText"))
                    
                    Text("Generated by AI")
                        .meta2Typography()
                        .foregroundStyle(Color("secondaryText"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)  // Inner bottom padding
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)  // Outer top padding
            .padding(.bottom, 16)
            
            // --- Weather: MVP variant (hidden) ---
            // weatherChipMVP
            
            // --- Weather: Post-MVP variant (hidden) ---
            // weatherChipPostMVP
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Weather Chip (MVP)
    
    private var weatherChipMVP: some View {
        HStack(spacing: 8) {
            FDSActionChip(
                size: .medium,
                label: "☀️72° Palo Alto",
                isMenu: false,
                action: {}
            )
            .fixedSize()
            .allowsHitTesting(false)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    // MARK: - Weather Chip (Post-MVP)
    
    private var weatherChipPostMVP: some View {
        HStack(spacing: 8) {
            FDSActionChip(
                size: .medium,
                label: "☀️72° Palo Alto",
                isMenu: true,
                action: {}
            )
            .fixedSize()
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
    
    // MARK: - Highlights Section
    
    private func highlightsSection(proxy: ScrollViewProxy) -> some View {
        // Highlights section with individual cards on gray background
        VStack(alignment: .leading, spacing: 0) {
            // Section Header: "Highlights for you"
            FDSUnitHeader(
                headlineText: "Highlights for you",
                hierarchyLevel: .level3
            )
            
            // Individual highlight cards
            VStack(spacing: 8) {
                ForEach(highlightItems.indices, id: \.self) { index in
                    highlightListItem(item: highlightItems[index], index: index, proxy: proxy)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .padding(.bottom, 140)
        .background(Color("bottomSheetBackgroundDeemphasized"))  // Gray background F2F4F7
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 0) {
            if currentFooterVariant == SnapshotFooterVariant.expanded.rawValue {
                footerMVP
            } else {
                footerV2
            }
        }
        .background(Color("surfaceBackground"))
    }
    
    // MARK: - Footer (Original V1 - compact)
    
//    private var footerV1: some View {
//        VStack(spacing: 0) {
//            // "You're all caught up" headline - centered
//            Text("✨ You're all caught up today!")
//                .headline3EmphasizedTypography()
//                .foregroundColor(Color("primaryText"))
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.horizontal, 12)
//                .padding(.top, 24)
//                .padding(.bottom, 24)
//
//            // Subtitle - centered
//            Text("Let us know what you'd like to see more of")
//                .body4Typography()
//                .foregroundColor(Color("secondaryText"))
//                .multilineTextAlignment(.center)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.horizontal, 12)
//
//            // Action chips - centered
//            HStack(spacing: 8) {
//                FDSActionChip(
//                    size: .medium,
//                    label: "Grammys",
//                    action: {}
//                )
//
//                FDSActionChip(
//                    size: .medium,
//                    label: "Robotaxis",
//                    action: {}
//                )
//
//                FDSActionChip(
//                    size: .medium,
//                    label: "Add a topic",
//                    leftAddOn: .icon("plus-outline"),
//                    action: {}
//                )
//            }
//            .padding(.horizontal, 12)
//            .padding(.top, 8)
//            .padding(.bottom, 24)
//
//            // "Previous snapshots" footer button - centered
//            Button(action: {}) {
//                HStack(spacing: 4) {
//                    Text("Previous snapshots")
//                        .button2Typography()
//                        .foregroundColor(Color("secondaryText"))
//
//                    Image("chevron-down-filled")
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 12, height: 12)
//                        .foregroundColor(Color("secondaryText"))
//                }
//                .frame(maxWidth: .infinity)
//                .frame(height: 32)
//            }
//            .buttonStyle(FDSPressedState(cornerRadius: 6))
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//            .padding(.bottom, 22)
//        }
//        .background(Color("surfaceBackground"))
//    }
    
    // MARK: - Footer V2 (Variable Height + Post-Rating Topic Chips)
    
    private var footerV2: some View {
        let hasRated = footerStarRating > 0
        let topicChips = ["Grammys", "Robotaxis", "AI startups", "MLB spring training", "Meal prep"]
        
        return VStack(spacing: 0) {
            Rectangle()
                .fill(Color("borderUiEmphasis"))
                .frame(height: 0.5)
                .padding(.horizontal, 12)
            
            Text(showTopicPicker ? "What would you like to see tomorrow?" : "Was today's snapshot worth your time?")
                .headline3EmphasizedTypography()
                .foregroundColor(Color("primaryText"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.top, 40)
            
            HStack(spacing: 0) {
                (Text("Ratings help improve your experience. ")
                    .foregroundColor(Color("secondaryText"))
                 + Text("Learn more")
                    .foregroundColor(Color("accentColor"))
                )
                .body4Typography()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            
            if showTopicPicker {
                WrappingHStack(spacing: 8) {
                    ForEach(topicChips, id: \.self) { topic in
                        let isSelected = selectedTopicChips.contains(topic)
                        FDSActionChip(
                            type: isSelected ? .secondary : .primary,
                            size: .medium,
                            label: topic,
                            leftAddOn: .icon(isSelected ? "checkmark-outline" : "plus-outline"),
                            action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if isSelected {
                                        selectedTopicChips.remove(topic)
                                    } else {
                                        selectedTopicChips.insert(topic)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 24)
                .padding(.bottom, 36)
                .transition(.opacity)
            } else {
                // Star rating
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                footerStarRating = index
                            }
                        } label: {
                            Image(index <= footerStarRating ? "star-filled" : "star-outline")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(Color("ratingStarActive"))
                        }
                        .buttonStyle(FDSPressedState(scale: .small))
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 36)
                .transition(.opacity)
            }
            
            // "Previous snapshots" button
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("Previous snapshots")
                        .button2Typography()
                        .foregroundColor(Color("secondaryText"))
                    
                    Image("chevron-down-filled")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color("secondaryText"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
            }
            .buttonStyle(FDSPressedState(cornerRadius: 6))
            .padding(.horizontal, 12)
            .padding(.top, 24)
            .padding(.bottom, 4)
        }
        .animation(.easeInOut(duration: 0.3), value: hasRated)
    }
    
    // MARK: - Footer V1 (Variable Height - commented out)
    //
    // private var footerV1: some View {
    //     VStack(spacing: 0) {
    //         Rectangle()
    //             .fill(Color("borderUiEmphasis"))
    //             .frame(height: 0.5)
    //             .padding(.horizontal, 12)
    //
    //         Text("Was today's snapshot worth your time?")
    //             .headline3EmphasizedTypography()
    //             .foregroundColor(Color("primaryText"))
    //             .multilineTextAlignment(.center)
    //             .frame(maxWidth: .infinity, alignment: .center)
    //             .padding(.horizontal, 24)
    //             .padding(.top, 40)
    //
    //         HStack(spacing: 0) {
    //             (Text("Ratings help improve your experience. ")
    //                 .foregroundColor(Color("secondaryText"))
    //              + Text("Learn more")
    //                 .foregroundColor(Color("accentColor"))
    //             )
    //             .body4Typography()
    //             .multilineTextAlignment(.center)
    //             .frame(maxWidth: .infinity, alignment: .center)
    //         }
    //         .padding(.horizontal, 24)
    //         .padding(.top, 12)
    //
    //         HStack(spacing: 12) {
    //             ForEach(1...5, id: \.self) { index in
    //                 Button {
    //                     footerStarRating = index
    //                     showRatingToast = true
    //                 } label: {
    //                     Image(index <= footerStarRating ? "star-filled" : "star-outline")
    //                         .renderingMode(.template)
    //                         .resizable()
    //                         .scaledToFit()
    //                         .frame(width: 32, height: 32)
    //                         .foregroundStyle(Color("ratingStarActive"))
    //                 }
    //                 .buttonStyle(FDSPressedState(scale: .small))
    //             }
    //         }
    //         .padding(.top, 28)
    //         .padding(.bottom, 12)
    //
    //         Button(action: {}) {
    //             HStack(spacing: 4) {
    //                 Text("Previous snapshots")
    //                     .button2Typography()
    //                     .foregroundColor(Color("secondaryText"))
    //
    //                 Image("chevron-down-filled")
    //                     .renderingMode(.template)
    //                     .resizable()
    //                     .scaledToFit()
    //                     .frame(width: 12, height: 12)
    //                     .foregroundColor(Color("secondaryText"))
    //             }
    //             .frame(maxWidth: .infinity)
    //             .frame(height: 32)
    //         }
    //         .buttonStyle(FDSPressedState(cornerRadius: 6))
    //         .padding(.horizontal, 12)
    //         .padding(.top, 24)
    //         .padding(.bottom, 4)
    //     }
    // }
    
    // MARK: - Footer (MVP Full-Page)
    
    private var footerMVP: some View {
        VStack(spacing: 0) {
            // Accent divider
            Rectangle()
                .fill(Color("accentColor"))
                .frame(height: 3)
                .padding(.horizontal, 12)
                .padding(.top, 24)
            
            Spacer(minLength: 40)
            
            // Rating content
            VStack(spacing: 0) {
                Text("Was today's snapshot worth your time?")
                    .headline2EmphasizedTypography()
                    .foregroundColor(Color("primaryText"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                
                HStack(spacing: 0) {
                    (Text("Ratings help improve your experience. ")
                        .foregroundColor(Color("secondaryText"))
                     + Text("Learn more")
                        .foregroundColor(Color("accentColor"))
                    )
                    .body4Typography()
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                
                // 5-star rating
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { index in
                        Button {
                            footerStarRating = index
                        } label: {
                            Image(index <= footerStarRating ? "star-filled" : "star-outline")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(Color("ratingStarActive"))
                        }
                        .buttonStyle(FDSPressedState(scale: .small))
                    }
                }
                .padding(.top, 20)
            }
            
            Spacer(minLength: 40)
            
            // "Previous snapshots" pinned to bottom
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text("Previous snapshots")
                        .button2Typography()
                        .foregroundColor(Color("secondaryText"))
                    
                    Image("chevron-down-filled")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color("secondaryText"))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 32)
            }
            .buttonStyle(FDSPressedState(cornerRadius: 6))
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
        }
        .frame(minHeight: UIScreen.main.bounds.height - 100)
    }
    
    // MARK: - Star Rating Card (reusable, currently hidden in footer)
    
    private var starRatingCard: some View {
        VStack(spacing: 12) {
            Text("Was the above content worth your time?")
                .headline4EmphasizedTypography()
                .foregroundColor(Color("primaryText"))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Your review will be private")
                .meta2Typography()
                .foregroundColor(Color("secondaryText"))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // 5-star rating
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { index in
                    Button {
                        footerStarRating = index
                    } label: {
                        Image(index <= footerStarRating ? "star-filled" : "star-outline")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(Color("ratingStarActive"))
                    }
                    .buttonStyle(FDSPressedState(scale: .small))
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color("cardBackground"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 0.5)
        )
        .padding(.horizontal, 12)
        .padding(.top, 24)
    }
    
    // MARK: - Snapshot Unit
    
    private func snapshotUnit(unitId: Int, title: String, bodyText: String, bullets: [String] = [], pivots: [(label: String, image: String?)] = [], image1: String = "pantone-1", image2: String = "pantone-2", image3: String? = nil, image4: String? = nil, usernames: [String] = ["User", "User", "User", "User"], proxy: ScrollViewProxy? = nil) -> some View {
        let isHeavy = currentTextHierarchy == TextHierarchyVariant.heavy.rawValue
        
        return VStack(spacing: 0) {
            FDSUnitHeader(
                headlineText: title,
                hierarchyLevel: isHeavy ? .level2 : .level3,
                rightAddOn: .iconButton(
                    icon: "dots-3-horizontal-filled",
                    action: {},
                    isDisabled: false
                )
            )
            .padding(.bottom, 4)
            
            // Body Text - Summary + Bullets
            VStack(alignment: .leading, spacing: 12) {
                Text(bodyText)
                    .body3Typography()
                    .foregroundColor(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !bullets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .body3Typography()
                                    .foregroundColor(Color("primaryText"))
                                Text(bullet)
                                    .body3Typography()
                                    .foregroundColor(Color("primaryText"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            .lineLimit(8)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            
            // "Sources" Action Chip (visible only when a search variant is active)
            if currentSearchVariant != SnapshotSearchVariant.off.rawValue && currentSearchVariant != SnapshotSearchVariant.searchPivots.rawValue {
                Spacer().frame(height: 8)
                HStack {
                    FDSActionChip(
                        size: .small,
                        label: "Sources",
                        isMenu: false,
                        action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSourcesSheet = unitId
                            }
                        }
                    )
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 20)
            }
            
            // Search Pivots (conditional)
            if !pivots.isEmpty && currentSearchVariant == SnapshotSearchVariant.searchPivots.rawValue {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(pivots.enumerated()), id: \.offset) { index, pivot in
                            FDSActionChip(
                                size: .medium,
                                label: pivot.label,
                                leftAddOn: index == 0 ? .expressiveIconAsset("fb-meta-ai-assistant") : nil,
                                action: {
                                    selectedPivotQuery = pivot.label
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 20)
            }
            
            // Row of Posts - 2x1 by default, 2x2 when expanded
            VStack(spacing: 8) {
                // First Row (always visible)
                HStack(spacing: 8) {
                    // Post 1
                    Button(action: {
                        guard showSourcesSheet == nil else { return }
                        selectedTopicId = unitId
                        selectedMediaIndex = 0
                        showVideoPlayer = true
                    }) {
                        placeholderPostCard(imageName: image1, username: usernames[0])
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 12))
                    
                    // Post 2
                    Button(action: {
                        guard showSourcesSheet == nil else { return }
                        selectedTopicId = unitId
                        selectedMediaIndex = 1
                        showVideoPlayer = true
                    }) {
                        placeholderPostCard(imageName: image2, username: usernames[1])
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 12))
                }
                
                // Second Row (visible when expanded)
                if expandedUnits[unitId] == true {
                    HStack(spacing: 8) {
                        // Post 3
                        Button(action: {
                            guard showSourcesSheet == nil else { return }
                            selectedTopicId = unitId
                            selectedMediaIndex = 2
                            showVideoPlayer = true
                        }) {
                            placeholderPostCard(imageName: image3 ?? image1, username: usernames[2])
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FDSPressedState(cornerRadius: 12))
                        
                        // Post 4
                        Button(action: {
                            guard showSourcesSheet == nil else { return }
                            selectedTopicId = unitId
                            selectedMediaIndex = 3
                            showVideoPlayer = true
                        }) {
                            placeholderPostCard(imageName: image4 ?? image2, username: usernames[3])
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(FDSPressedState(cornerRadius: 12))
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .id("expanded-\(unitId)")
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // "See more" Button (hidden when expanded)
            if expandedUnits[unitId] != true {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        expandedUnits[unitId] = true
                    }
                    // Snap to expanded position
                    if let proxy = proxy {
                        isProgrammaticScroll = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.easeInOut(duration: 0.45)) {
                                if unitId == 5 {
                                    // Last unit: snap bottom of footer to bottom of viewport
                                    proxy.scrollTo("footer", anchor: .bottom)
                                } else {
                                    proxy.scrollTo("snapshot-\(unitId)", anchor: UnitPoint(x: 0.5, y: 0.832))
                                }
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            isProgrammaticScroll = false
                        }
                    }
                }) {
                    HStack(spacing: 4) {
                        Text("See more")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("secondaryText"))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Color("secondaryText"))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, -4)
            }
            
            // Footer Action Chips (thumbs up/down)
            HStack(spacing: 8) {
                if unitFeedback[unitId] == nil {
                    FDSActionChip(
                        size: .large,
                        label: "",
                        leftAddOn: .icon("hand-thumbs-up-outline"),
                        action: {
                            unitFeedback[unitId] = "up"
                            feedbackToastUnitId = unitId
                            showFeedbackToast = true
                        }
                    )
                    
                    FDSActionChip(
                        size: .large,
                        label: "",
                        leftAddOn: .icon("hand-thumbs-down-outline"),
                        action: {
                            unitFeedback[unitId] = "down"
                            feedbackToastUnitId = unitId
                            showFeedbackToast = true
                        }
                    )
                } else {
                    FDSActionChip(
                        type: .secondary,
                        size: .large,
                        label: "",
                        leftAddOn: .icon(unitFeedback[unitId] == "up" ? "hand-thumbs-up-filled" : "hand-thumbs-down-filled"),
                        action: {}
                    )
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 30)
            .id("footer-\(unitId)")
        }
        .background(Color("cardBackground"))  // White background
    }
    
    // MARK: - Placeholder Post Card
    
    private func placeholderPostCard(imageName: String, username: String = "User") -> some View {
        // ZStack with full-bleed image and overlaid text
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Base Layer: Full-bleed image fills entire card
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                // Top Layer: Header with text shadow for readability
                HStack(spacing: 8) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                    
                    Text(username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                }
                .padding(12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("borderUiEmphasis"), lineWidth: 1)
            )
            .clipped()
        }
        .aspectRatio(172/259.571, contentMode: .fit)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Highlight List Item
    
    private func highlightListItem(item: HighlightItem, index: Int, proxy: ScrollViewProxy) -> some View {
        let isHeavy = currentTextHierarchy == TextHierarchyVariant.heavy.rawValue
        
        return Button(action: {
            isProgrammaticScroll = true
            
            withAnimation(.easeInOut(duration: 0.45)) {
                proxy.scrollTo("snapshot-\(index + 1)", anchor: .top)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isProgrammaticScroll = false
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(item.emoji) \(item.title)")
                    .if(isHeavy) { $0.headline3EmphasizedTypography() }
                    .if(!isHeavy) { $0.headline4Typography() }
                    .foregroundColor(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(item.body)
                    .body3Typography()
                    .foregroundColor(Color(isHeavy ? "secondaryText" : "primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .contentShape(Rectangle())
        }
        .background(Color("cardBackground"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .buttonStyle(FDSPressedState(cornerRadius: 12))
    }
    
    // MARK: - Helpers
    
    private func topicNameToSnapshotId(_ topicName: String) -> Int {
        switch topicName {
        case "Pantone's Color of the Year": return 1
        case "Jokic MVP race lead": return 2
        case "Children Museum winter programs": return 3
        case "High protein toddler snacks": return 4
        case "Denver Restaurant Week": return 5
        case "SpaceX Starship launch window": return 6
        default: return selectedTopicId
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Sources Bottom Sheet
    
    private func sourcesBottomSheet(unitId: Int) -> some View {
        VStack(spacing: 0) {
            // Scroll Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("bottomSheetHandle"))
                .frame(width: 40, height: 4)
                .padding(.top, 6)
                .padding(.bottom, 6)
            
            // Header with title and X button
            sourcesSheetHeader
            
            // Source Links List using FDSListCell
            sourcesSheetList(unitId: unitId)
            
            // Home Affordance (iOS bottom bar indicator)
            Color.clear
                .frame(height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black)
                        .frame(width: 134, height: 5)
                )
                .background(Color("bottomSheetBackgroundDeemphasized"))
        }
        .background(Color("bottomSheetBackgroundDeemphasized"))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -1)
        .shadow(color: Color.black.opacity(0.05), radius: 0, x: 0, y: -1)
    }
    
    @ViewBuilder
    private var sourcesSheetHeader: some View {
        ZStack {
            Text("Sources")
                .headline4EmphasizedTypography()
                .foregroundColor(Color("primaryText"))
            
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSourcesSheet = nil
                    }
                }) {
                    Image("nav-cross-filled")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color("primaryIcon"))
                }
                .buttonStyle(FDSPressedState(circle: true, scale: .medium))
                .padding(.trailing, 12)
            }
        }
        .frame(height: 48)
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }
    
    @ViewBuilder
    private func sourcesSheetList(unitId: Int) -> some View {
        let sources = getSourceLinks(for: unitId)
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(Array(sources.enumerated()), id: \.offset) { index, title in
                    FDSListCell(
                        hierarchyLevel: .level4,
                        headlineText: title,
                        rightAddOn: .chevron,
                        showHairline: index < sources.count - 1,
                        action: {}
                    )
                }
            }
            .background(Color("cardBackground"))
            .cornerRadius(8)
        }
        .padding(12)
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }
    
    // MARK: - Source Links Data
    
    private func getSourceLinks(for unitId: Int) -> [String] {
        switch unitId {
        case 1: // Pantone
            return [
                "Pantone Color of the Year",
                "Pantone names its Color of the Year for...",
                "A guide to All the Pantone Colors"
            ]
        case 2: // Jokic
            return [
                "Nikola Jokić leading MVP race again",
                "Denver Nuggets center dominates stats",
                "MVP voting tracker - January update"
            ]
        case 3: // Winter Kids
            return [
                "Winter programs at Children's Museum",
                "Sensory play for cold weather months",
                "Registration opens for 2026 sessions"
            ]
        case 4: // Toddler Snacks
            return [
                "High-protein snacks for toddlers",
                "Hemp hearts: Complete protein source",
                "Easy toddler snack recipes"
            ]
        case 5: // Denver Restaurant Week
            return [
                "Denver Restaurant Week 2026 guide",
                "Top participating restaurants in RiNo",
                "How to make reservations early"
            ]
        default:
            return []
        }
    }
    
    // MARK: - Secret Menu Dropdown Row
    
    private func secretMenuDropdownRow(label: String, currentValue: Binding<String>, options: [String], isEnabled: Bool, showHairline: Bool = true) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .body2Typography()
                    .foregroundStyle(isEnabled ? Color("primaryText") : Color("disabledText"))
                
                Spacer()
                
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            currentValue.wrappedValue = option
                        }) {
                            if currentValue.wrappedValue == option {
                                Label(option, image: "checkmark-outline")
                            } else {
                                Text(option)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(currentValue.wrappedValue)
                            .body2Typography()
                            .foregroundStyle(isEnabled ? Color("secondaryText") : Color("disabledText"))
                        
                        VStack(spacing: 0) {
                            Image("chevron-up-filled")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                            Image("chevron-down-filled")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                        }
                        .foregroundStyle(isEnabled ? Color("secondaryIcon") : Color("disabledIcon"))
                    }
                }
                .disabled(!isEnabled)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            if showHairline {
                Rectangle()
                    .fill(Color("borderDeemphasized"))
                    .frame(height: 0.5)
                    .padding(.leading, 16)
            }
        }
    }
    
    // MARK: - Secret Menu Overlay
    
    @ViewBuilder
    private var secretMenuOverlay: some View {
        ZStack(alignment: .bottom) {
            if showSecretMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSecretMenu = false
                        }
                    }
                    .transition(.opacity)
                
                secretMenuBottomSheet
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.easeInOut(duration: 0.3), value: showSecretMenu)
    }
    
    private var secretMenuBottomSheet: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("bottomSheetHandle"))
                .frame(width: 40, height: 4)
                .padding(.top, 6)
                .padding(.bottom, 6)
            
            Text("Demo modes")
                .headline3EmphasizedTypography()
                .foregroundColor(Color("primaryText"))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color("bottomSheetBackgroundDeemphasized"))
            
            VStack(spacing: 0) {
                let isMVPv1 = currentDemoMode == SnapshotDemoMode.mvpV1.rawValue
                let otherModes = SnapshotDemoMode.allCases.filter { $0 != .mvpV1 }
                
                VStack(spacing: 0) {
                    FDSListCell(
                        headlineText: SnapshotDemoMode.mvpV1.rawValue,
                        leftAddOn: .icon(SnapshotDemoMode.mvpV1.icon, iconSize: 24),
                        rightAddOn: isMVPv1 ? .icon("checkmark-outline") : nil,
                        showHairline: true,
                        action: {
                            currentDemoMode = SnapshotDemoMode.mvpV1.rawValue
                        }
                    )
                    
                    secretMenuDropdownRow(
                        label: "Onboarding",
                        currentValue: $currentOnboardingVariant,
                        options: SnapshotOnboardingVariant.allCases.map { $0.rawValue },
                        isEnabled: isMVPv1
                    )
                    
                    secretMenuDropdownRow(
                        label: "Text hierarchy",
                        currentValue: $currentTextHierarchy,
                        options: TextHierarchyVariant.allCases.map { $0.rawValue },
                        isEnabled: isMVPv1
                    )
                    
                    secretMenuDropdownRow(
                        label: "Search",
                        currentValue: $currentSearchVariant,
                        options: SnapshotSearchVariant.allCases.map { $0.rawValue },
                        isEnabled: isMVPv1
                    )
                    
                    secretMenuDropdownRow(
                        label: "Footer",
                        currentValue: $currentFooterVariant,
                        options: SnapshotFooterVariant.allCases.map { $0.rawValue },
                        isEnabled: isMVPv1,
                        showHairline: false
                    )
                }
                .background(Color("cardBackground"))
                .cornerRadius(8)
                
                Spacer().frame(height: 12)
                
                VStack(spacing: 0) {
                    let isMediaCard = currentDemoMode == SnapshotDemoMode.v2MediaCard.rawValue
                    ForEach(Array(otherModes.enumerated()), id: \.offset) { index, mode in
                        FDSListCell(
                            headlineText: mode.rawValue,
                            leftAddOn: .icon(mode.icon, iconSize: 24),
                            rightAddOn: currentDemoMode == mode.rawValue ? .icon("checkmark-outline") : nil,
                            showHairline: true,
                            action: {
                                currentDemoMode = mode.rawValue
                            }
                        )
                        
                        if mode == .v2MediaCard {
                            secretMenuDropdownRow(
                                label: "Card style",
                                currentValue: $currentMediaCardVariant,
                                options: MediaCardVariant.allCases.map { $0.rawValue },
                                isEnabled: isMediaCard
                            )
                        }
                    }
                }
                .background(Color("cardBackground"))
                .cornerRadius(8)
            }
            .padding(12)
            .background(Color("bottomSheetBackgroundDeemphasized"))
            
            Color.clear
                .frame(height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.black)
                        .frame(width: 134, height: 5)
                )
                .background(Color("bottomSheetBackgroundDeemphasized"))
        }
        .background(Color("bottomSheetBackgroundDeemphasized"))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -1)
        .shadow(color: Color.black.opacity(0.05), radius: 0, x: 0, y: -1)
    }
    
}

#Preview {
    TodaysSnapshotLandingV5()
}
