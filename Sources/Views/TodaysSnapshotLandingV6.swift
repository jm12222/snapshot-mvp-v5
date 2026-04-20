import SwiftUI
import AVKit
import AVFoundation
import CoreMedia

// MARK: - V6 Unit Model

struct V6SnapshotUnit: Identifiable, Hashable {
    let id: Int
    let title: String
    let body: String
    let image1: String
    let image2: String
    let image3: String
    let image4: String
    let usernames: [String]
}

// MARK: - Today's Snapshot v6

struct TodaysSnapshotLandingV6: View {
    var onBack: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @AppStorage("snapshotDemoMode") private var currentDemoMode: String = SnapshotDemoMode.v6.rawValue
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
    @State private var selectedUnit: V6SnapshotUnit? = nil

    // DEBUG: Toggle this to show/hide scroll position indicator
    private let showScrollDebug = false

    private var v6Units: [V6SnapshotUnit] {
        [
            V6SnapshotUnit(id: 0, title: "Snow finally comes to Colorado",                              body: "There's snow coming to Colorado! Here's a rundown of which ski resorts you should hit this weekend. Best prices and smallest crowds.",                                                 image1: "snow-colorado",     image2: "unsplash-skier-blue", image3: "unsplash-skier-jump", image4: "unsplash-snow-lake", usernames: ["Colorado Ski Authority", "Mountain Report", "Powder Alert", "Resort Guide"]),
            V6SnapshotUnit(id: 1, title: "Nothing Technologies unveils new headphones", body: "New earphone and camera are launched by Nothing Technologies that you are interested in.",                                                                                    image1: "headphones",        image2: "nothing-headphones", image3: "headphones",         image4: "nothing-headphones", usernames: ["The Verge", "Tech Insider", "Wired", "Engadget"]),
            V6SnapshotUnit(id: 2, title: "Brooklyn's liminal night photography spots this April",       body: "Brooklyn is known for its vibrant nightlife and unique photo opportunities. The best options are always hidden.",                                                                   image1: "brooklyn-photo",    image2: "la-cinema",          image3: "brooklyn-photo",    image4: "la-cinema",          usernames: ["Brooklyn Magazine", "NYC Photo", "Street Lens", "Urban Frame"]),
            V6SnapshotUnit(id: 3, title: "Upcoming birthdays",                                          body: "Frederic, Anna and Shelly have birthdays this week. Sabrina announced her graduation.",                                                                                                                    image1: "birthday",          image2: "children-museum-winter", image3: "pantone-color-year", image4: "birthday",         usernames: ["Frederic", "Anna", "Shelly", "Friends"]),
            V6SnapshotUnit(id: 4, title: "Syracuse plays Saint Joseph's on March 18",                  body: "Tip-off is 7pm ET at the JMA Wireless Dome. The Orange enter riding a four-game win streak and are favored by 6.5 against the Hawks.",                                            image1: "syracuse",          image2: "lakers-basketball",  image3: "syracuse",          image4: "lakers-basketball",  usernames: ["Syracuse Athletics", "CBS Sports", "ESPN", "March Madness"]),
            V6SnapshotUnit(id: 5, title: "Cassette player revival",                                    body: "Modern cassette players like the FiiO CP26 are sparking a retro tech revival among analog audio collectors.",                                                                      image1: "casette-fiio",      image2: "casette-fiio",       image3: "casette-fiio",      image4: "casette-fiio",       usernames: ["Analog Audio", "Retro Tech", "FiiO Official", "Sound Collector"]),
            V6SnapshotUnit(id: 6, title: "Lakers edge Warriors in OT thriller",                          body: "LeBron's late three forced overtime and Reaves sealed it with a fadeaway. LA pulls within a half-game of the Pacific Division lead.",                                              image1: "lakers-basketball", image2: "lakers-basketball",  image3: "lakers-basketball", image4: "lakers-basketball",  usernames: ["Lakers Nation", "ESPN", "Bleacher Report", "The Athletic"]),
        ]
    }
    
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
        .navigationDestination(item: $selectedUnit) { unit in
            SnapshotUnitDetailV6(unit: unit)
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
        }
    }
    
    // MARK: - Main Content Layer
    
    @ViewBuilder
    private func mainContentLayer(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Today's snapshot",
                backAction: {
                    // If the long-press just opened the secret menu, swallow the tap
                    // that fires on finger release (otherwise we'd dismiss immediately).
                    if showSecretMenu { return }
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
                },
                backgroundColor: Color("bottomSheetBackgroundDeemphasized")
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
                    headerSection
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

                    highlightsSection(proxy: proxy)
                }
            }
        }
        .background(Color("bottomSheetBackgroundDeemphasized").ignoresSafeArea())
    }
    
    // MARK: - Snapshot Units Container
    
    @ViewBuilder
    private func snapshotUnitsContainer(proxy: ScrollViewProxy) -> some View {
        snapshotUnit(
            unitId: 1,
            title: "Snow finally comes to Colorado",
            bodyText: "There's snow coming to Colorado! Here's a rundown of which ski resorts you should hit this weekend. Best prices and smallest crowds.",
            image1: "ski-colorado",
            image2: "snow-colorado",
            image3: "blizzard",
            image4: "ski-colorado",
            usernames: ["Colorado Ski Authority", "Mountain Report", "Powder Alert", "Resort Guide"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-1")

        snapshotUnit(
            unitId: 2,
            title: "Nothing Technologies unveils new headphones attracting tech nerds",
            bodyText: "New earphone and camera are launched by Nothing Technologies that you are interested in.",
            image1: "headphones",
            image2: "nothing-headphones",
            image3: "headphones",
            image4: "nothing-headphones",
            usernames: ["The Verge", "Tech Insider", "Wired", "Engadget"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-2")

        snapshotUnit(
            unitId: 3,
            title: "Brooklyn's liminal night photography spots this April",
            bodyText: "Brooklyn is known for its vibrant nightlife and unique photo opportunities. The best options are always hidden.",
            image1: "brooklyn-photo",
            image2: "la-cinema",
            image3: "brooklyn-photo",
            image4: "la-cinema",
            usernames: ["Brooklyn Magazine", "NYC Photo", "Street Lens", "Urban Frame"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-3")

        snapshotUnit(
            unitId: 4,
            title: "Upcoming birthdays from your Facebook friends",
            bodyText: "Frederic, Anna and Shelly have birthdays this week. Sabrina announced her graduation.",
            image1: "birthday",
            image2: "children-museum-winter",
            image3: "pantone-color-year",
            image4: "birthday",
            usernames: ["Frederic", "Anna", "Shelly", "Friends"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-4")

        snapshotUnit(
            unitId: 5,
            title: "Syracuse plays Saint Joseph's on March 18",
            bodyText: "Brandon Marcus, Amelia Santos and 20 others are celebrating their birthdays. Plan for their special day!",
            image1: "syracuse",
            image2: "lakers-basketball",
            image3: "syracuse",
            image4: "lakers-basketball",
            usernames: ["Syracuse Athletics", "CBS Sports", "ESPN", "March Madness"],
            proxy: proxy
        )
        .containerRelativeFrame(.vertical, alignment: .top)
        .background(Color("cardBackground"))
        .id("snapshot-5")

        snapshotUnit(
            unitId: 6,
            title: "Cassette player revival",
            bodyText: "Modern cassette players like the FiiO CP26 are sparking a retro tech revival among analog audio collectors.",
            image1: "casette-fiio",
            image2: "casette-fiio",
            image3: "casette-fiio",
            image4: "casette-fiio",
            usernames: ["Analog Audio", "Retro Tech", "FiiO Official", "Sound Collector"],
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
        Button(action: {
            selectedUnit = v6Units[0]
        }) {
            mediaCard(
                imageName: "ski-colorado",
                title: "Snow finally comes to Colorado",
                body: "There's snow coming to Colorado! Here's a rundown of which ski resorts you should hit this weekend. Best prices and smallest crowds."
            )
        }
        .buttonStyle(FDSPressedState(cornerRadius: 12)) // tuned: 8 → 12 (match thumbs + section container)
    }

    private func mediaCard(imageName: String, title: String, body: String) -> some View {
        // Pure-white text panel overlays the bottom of the image. The whole
        // card (image + panel) gets a subtle media-inner-border hairline so it
        // reads as a single unit against the page's faint grey background.
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                    .clipped()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .headline3EmphasizedTypography() // tuned: regular → emphasized (17pt bold)
                    .foregroundStyle(Color("primaryText"))
                WordTruncatedBody(text: body, foregroundColor: Color("secondaryText"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.top, 16) // tuned: 24 → 16 (-8 above headline)
            .padding(.bottom, 20) // tuned: 24 → 20 (-4 below body)
            .background(Color("cardBackground"))
        }
        // Card height shrunk 300 → 258 (~20% less visible image area, text panel
        // unchanged). At 350-ish pt wide, scaledToFill keeps the full image
        // vertical visible and recrops by reducing horizontal side-cropping.
        .frame(height: 258)
        .clipShape(RoundedRectangle(cornerRadius: 12)) // tuned: 8 → 12 (match thumbs + section container)
        .overlay(
            RoundedRectangle(cornerRadius: 12) // tuned: 8 → 12 (match thumbs + section container)
                .stroke(Color("mediaInnerBorder"), lineWidth: 0.5)
        )
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
                    .padding(.bottom, 4)

                // Subtitle "6 things to start your day" intentionally hidden per request.
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
        .background(Color("bottomSheetBackgroundDeemphasized"))
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

    private var v6PickedForYouUnits: [V6SnapshotUnit] {
        // Editorially-curated picks. Hero (index 0) renders separately as the
        // media card. Cassette (5) moved to the very bottom of the list.
        [v6Units[1]]
    }

    private var v6FriendsUnits: [V6SnapshotUnit] {
        // Birthdays and other people-centric updates from the user's network.
        [v6Units[3]]
    }

    private var v6SportsYouFollowUnits: [V6SnapshotUnit] {
        // Sports stories only — local items moved to dedicated LOCAL section.
        // Lakers (id 6) appended below Syracuse per request.
        [v6Units[4], v6Units[6]]
    }

    private var v6LocalUnits: [V6SnapshotUnit] {
        // LOCAL section per request: last 2 items go here (Brooklyn + Cassette).
        [v6Units[2], v6Units[5]]
    }

    private func highlightsSection(proxy: ScrollViewProxy) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Picked for you")
                .padding(.horizontal, 16)
                .padding(.top, 5) // tuned: 4 → 5 (+1 above all section headers)
                .padding(.bottom, 9) // tuned: 12 → 9 (-3 below all section headers)

            heroMediaCard
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

            groupedHighlights(units: v6PickedForYouUnits)
                .padding(.horizontal, 12)
                .padding(.bottom, 16) // 12 + 4 above next section header

            sectionHeader("Friends")
                .padding(.horizontal, 16)
                .padding(.top, 1) // tuned: +1 above all section headers
                .padding(.bottom, 9) // tuned: 12 → 9 (-3 below all section headers)

            groupedHighlights(units: v6FriendsUnits)
                .padding(.horizontal, 12)
                .padding(.bottom, 16) // 12 + 4 above next section header

            sectionHeader("Sports you follow")
                .padding(.horizontal, 16)
                .padding(.top, 1) // tuned: +1 above all section headers
                .padding(.bottom, 9) // tuned: 12 → 9 (-3 below all section headers)

            groupedHighlights(units: v6SportsYouFollowUnits)
                .padding(.horizontal, 12)
                .padding(.bottom, 16) // 12 + 4 above next section header

            sectionHeader("Local")
                .padding(.horizontal, 16)
                .padding(.top, 1) // tuned: +1 above all section headers
                .padding(.bottom, 9) // tuned: 12 → 9 (-3 below all section headers)

            groupedHighlights(units: v6LocalUnits)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .padding(.bottom, 140)
        .background(Color("bottomSheetBackgroundDeemphasized"))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .meta2Typography()
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(Color("secondaryText"))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func groupedHighlights(units: [V6SnapshotUnit]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(units.enumerated()), id: \.element.id) { index, unit in
                highlightRow(unit: unit, isLast: index == units.count - 1)
            }
        }
        .background(Color("cardBackground"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("mediaInnerBorder"), lineWidth: 0.5)
        )
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
    
    // MARK: - Highlight Row (with thumbnail + hairline)

    private func highlightRow(unit: V6SnapshotUnit, isLast: Bool) -> some View {
        Button(action: {
            selectedUnit = unit
        }) {
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(unit.image1)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 12)) // tuned: 8 → 12 (match hero + section container)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12) // tuned: 8 → 12 (match hero + section container)
                                .stroke(Color("mediaInnerBorder"), lineWidth: 0.5)
                        )

                    VStack(alignment: .leading, spacing: 10) { // tuned: 14 → 10 (-4 below headline)
                        Text(unit.title)
                            .headline3EmphasizedTypography() // reverted to emphasized (17pt bold) — matches hero
                            .foregroundColor(Color("primaryText"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        WordTruncatedBody(text: unit.body, foregroundColor: Color("secondaryText"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)

                if !isLast {
                    Rectangle()
                        .fill(Color("mediaInnerBorder"))
                        .frame(height: 0.5)
                        .padding(.leading, 16 + 64 + 12)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(FDSPressedState())
    }
    
    // MARK: - Helpers
    
    private func topicNameToSnapshotId(_ topicName: String) -> Int {
        switch topicName {
        case "Snow finally comes to Colorado": return 1
        case "Nothing Technologies unveils new headphones attracting tech nerds": return 2
        case "Brooklyn's liminal night photography spots this April": return 3
        case "Upcoming birthdays from your Facebook friends": return 4
        case "Syracuse plays Saint Joseph's on March 18": return 5
        case "Cassette player revival": return 6
        default: return selectedTopicId
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
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

// MARK: - Snapshot Unit Detail View (v6)

struct SnapshotUnitDetailV6: View {
    let unit: V6SnapshotUnit
    @Environment(\.dismiss) private var dismiss

    // Made-up sub-bullets that expand on the thesis sentence.
    private var detailBullets: [String] {
        [
            "Forecasters are calling for 18 to 24 inches of new snow above 9,000 feet between Friday night and Sunday morning.",
            "Heaviest accumulation is expected along the I-70 corridor, with several previously-closed lifts reopening in time for the weekend.",
            "Mountain towns have issued winter parking advisories; chains may be required on Loveland and Vail Pass after midnight Friday.",
            "Lift tickets are tracking 12% cheaper than the same weekend last year, and lodging availability is unusually strong for late-season powder.",
            "Vail, Breckenridge, and Copper are reporting the deepest base depths in the state heading into the storm."
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Today's snapshot",
                backAction: { dismiss() },
                icon1: { FDSIconButton(icon: "share-outline", action: {}) }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    Text(unit.title)
                        .headline2EmphasizedTypography()
                        .foregroundColor(Color("primaryText"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        .padding(.bottom, 12)

                    // Thesis sentence
                    Text(unit.body)
                        .body3Typography()
                        .foregroundColor(Color("primaryText"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 16)

                    // Sub-bullets (key facts at a glance)
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(detailBullets, id: \.self) { bullet in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
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
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)

                    // Sources sub-pill
                    HStack {
                        FDSActionChip(
                            size: .small,
                            label: "Sources",
                            isMenu: false,
                            action: {}
                        )
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 20)

                    // 2×2 media grid
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            detailMediaCard(imageName: unit.image1, username: unit.usernames[0])
                            detailMediaCard(imageName: unit.image2, username: unit.usernames[1])
                        }
                        HStack(spacing: 8) {
                            detailMediaCard(imageName: unit.image3, username: unit.usernames[2])
                            detailMediaCard(imageName: unit.image4, username: unit.usernames[3])
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 24)
                }
            }
            .background(Color("cardBackground"))
        }
        .background(Color("cardBackground"))
        .hideFDSTabBar(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private func detailMediaCard(imageName: String, username: String) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

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
            .frame(width: geo.size.width, height: geo.size.height)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("borderUiEmphasis"), lineWidth: 1))
            .clipped()
        }
        .aspectRatio(172 / 259.571, contentMode: .fit)
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Word-Boundary Truncated Body Text
//
// Truncates body3-styled text to fit in `lineLimit` lines while ALWAYS breaking
// after a complete word (so we never see "th…" or "announc…"). Measures the
// available width via a hidden GeometryReader, then walks word-by-word to find
// the longest prefix + "…" that still fits in the height budget.
struct WordTruncatedBody: View {
    let text: String
    let foregroundColor: Color
    var lineLimit: Int = 2

    @State private var availableWidth: CGFloat = 0

    private static let measurementFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    // tuned: 1 → 3 (loosened body3 line-spacing on highlight rows + hero by ~2pt)
    private static let lineSpacing: CGFloat = 3

    var body: some View {
        Text(displayText)
            .body3Typography()
            .lineSpacing(Self.lineSpacing) // overrides the 1pt baseline from body3Typography
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { availableWidth = geo.size.width }
                        .onChange(of: geo.size.width) { _, newValue in
                            availableWidth = newValue
                        }
                }
            )
    }

    private var displayText: String {
        guard availableWidth > 0 else { return text }
        return Self.wordBoundaryTruncate(
            text: text,
            font: Self.measurementFont,
            width: availableWidth,
            lineSpacing: Self.lineSpacing,
            lineLimit: lineLimit
        )
    }

    private static func wordBoundaryTruncate(
        text: String,
        font: UIFont,
        width: CGFloat,
        lineSpacing: CGFloat,
        lineLimit: Int
    ) -> String {
        guard width > 0 else { return text }
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        // SwiftUI's lineSpacing adds extra space between baselines, so the
        // total budget is N line heights + (N-1) extra spacing.
        let lineHeight = font.lineHeight
        let maxHeight = lineHeight * CGFloat(lineLimit)
            + lineSpacing * CGFloat(max(lineLimit - 1, 0))
            + 0.5 // small rounding buffer

        let measureSize = CGSize(width: width, height: .greatestFiniteMagnitude)

        let fullSize = (text as NSString).boundingRect(
            with: measureSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attrs,
            context: nil
        )
        if fullSize.height <= maxHeight { return text }

        let words = text.split(separator: " ", omittingEmptySubsequences: false)
        var lastFitting = ""
        var current = ""
        for word in words {
            let candidate = current.isEmpty ? String(word) : current + " " + String(word)
            let withEllipsis = candidate + "…"
            let s = (withEllipsis as NSString).boundingRect(
                with: measureSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attrs,
                context: nil
            )
            if s.height <= maxHeight {
                lastFitting = withEllipsis
                current = candidate
            } else {
                break
            }
        }
        return lastFitting.isEmpty ? text : lastFitting
    }
}

#Preview {
    TodaysSnapshotLandingV6()
}
