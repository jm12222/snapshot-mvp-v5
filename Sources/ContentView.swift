import SwiftUI

enum TabSelection: String, CaseIterable, FDSTab {
    case home = "Home"
    case friends = "Friends"
    case reels = "Reels"
    case marketplace = "Marketplace"
    case notifications = "Notifications"
    case profile = "Profile"
    
    var iconFilled: String {
        switch self {
        case .home: return "news-feed-home-filled"
        case .friends: return "friends-filled"
        case .reels: return "app-facebook-reels-filled"
        case .marketplace: return "marketplace-filled"
        case .notifications: return "notifications-filled"
        case .profile: return "profile-filled"
        }
    }
    
    var iconOutline: String {
        switch self {
        case .home: return "news-feed-home-outline"
        case .friends: return "friends-outline"
        case .reels: return "app-facebook-reels-outline"
        case .marketplace: return "marketplace-outline"
        case .notifications: return "notifications-outline"
        case .profile: return "profile-outline"
        }
    }
    
    var usesDarkTabBar: Bool {
        self == .reels
    }
    
    var profileImage: String? {
        switch self {
        case .profile: return ProfileData.currentUser.profileImage
        default: return nil
        }
    }
}

struct ContentView: View {
    @State private var selection: TabSelection = .home
    @StateObject private var drawerState = DrawerStateManager()
    @StateObject private var tabBarHelper = FDSTabBarHelper()
    
    // Root-level navigation state for app-wide navigation (covers tab bar)
    @State private var showGroupsTab = false
    @State private var showPrototypeSettings = false
    @State private var showSearch = false
    
    // Landing destination: Today's snapshot (MVP-v1). Hidden once user backs out.
    @State private var showTodaysSnapshot = true
    
    var body: some View {
        Group {
            if showTodaysSnapshot {
                NavigationStack {
                    TodaysSnapshotLandingMVPv1(onBack: {
                        selection = .notifications
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showTodaysSnapshot = false
                        }
                    })
                }
                .transition(.opacity)
            } else {
                tabExperience
                    .transition(.opacity)
            }
        }
        .touchVisualizer()
        .environmentObject(drawerState)
        .environmentObject(tabBarHelper)
        .fullScreenCover(isPresented: $drawerState.showDemoModePicker) {
            NavigationStack {
                PrototypeSettings()
            }
            .environmentObject(tabBarHelper)
            .environmentObject(drawerState)
        }
        .onReceive(drawerState.$pendingTabSwitch) { tabName in
            guard let tabName = tabName else { return }
            switch tabName.lowercased() {
            case "home": selection = .home
            case "friends": selection = .friends
            case "reels": selection = .reels
            case "marketplace": selection = .marketplace
            case "notifications": selection = .notifications
            case "profile": selection = .profile
            default: break
            }
            drawerState.clearPendingTabSwitch()
        }
        .onReceive(drawerState.$pendingNavigation) { destination in
            guard let destination = destination else { return }
            switch destination {
            case "nav:groupsTab":
                showGroupsTab = true
            case "nav:prototypeSettings":
                showPrototypeSettings = true
            case "nav:search":
                showSearch = true
            default:
                break
            }
            drawerState.clearPendingNavigation()
        }
    }
    
    // MARK: - Tab Experience
    
    private var tabExperience: some View {
        NavigationStack {
            DrawerContainer(drawerState: drawerState) {
                // Drawer content - the old More tab
                MoreTabView(bottomPadding: 0)
            } mainContent: {
                // Main content - tab view
                FDSTabView(selection: $selection) { tab, tabHeight in
                    switch tab {
                    case .home:
                        HomeTab(bottomPadding: tabHeight)
                    case .friends:
                        NavigationStack {
                            FriendsTab(bottomPadding: tabHeight)
                                .withNavigationDestinations(bottomPadding: tabHeight)
                        }
                    case .reels:
                        NavigationStack {
                            ReelsTabView()
                                .withNavigationDestinations(bottomPadding: tabHeight)
                        }
                    case .marketplace:
                        NavigationStack {
                            MarketplaceTabView(bottomPadding: tabHeight)
                                .withNavigationDestinations(bottomPadding: tabHeight)
                        }
                    case .notifications:
                        NavigationStack {
                            NotificationsTab(bottomPadding: tabHeight)
                                .withNavigationDestinations(bottomPadding: tabHeight)
                        }
                    case .profile:
                        NavigationStack {
                            ProfileView(profile: ProfileData.currentUser, isTopLevelTab: true)
                                .withNavigationDestinations(bottomPadding: tabHeight)
                        }
                    }
                }
            }
            // Root-level navigation destinations - these push over the entire app including tab bar
            .navigationDestination(isPresented: $showGroupsTab) {
                GroupsTabView(bottomPadding: 0)
                    .withNavigationDestinations(bottomPadding: 0)
            }
            .navigationDestination(isPresented: $showPrototypeSettings) {
                PrototypeSettings()
            }
            .navigationDestination(isPresented: $showSearch) {
                SearchView()
            }
            .withNavigationDestinations(bottomPadding: 0)
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Navigation Modifier

struct NavigationDestinations: ViewModifier {
    let bottomPadding: CGFloat
    
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: PostData.self) { post in
                PostPermalinkView(post: post)
            }
            .navigationDestination(for: String.self) { identifier in
                destinationView(for: identifier, bottomPadding: bottomPadding)
            }
            .navigationDestination(for: GroupNavigationValue.self) { groupNav in
                if let groupData = groupDataMap[groupNav.groupImage] {
                    GroupView(group: groupData)
                }
            }
    }
    
    @ViewBuilder
    private func destinationView(for identifier: String, bottomPadding: CGFloat) -> some View {
        if identifier.hasPrefix("nav:") {
            let destination = identifier.replacingOccurrences(of: "nav:", with: "")
            switch destination {
            case "groupsTab":
                GroupsTabView(bottomPadding: bottomPadding)
            case "friends":
                FriendsTab(bottomPadding: bottomPadding)
            case "marketplace":
                MarketplaceTabView(bottomPadding: bottomPadding)
            case "search":
                SearchView()
            case "prototypeSettings":
                PrototypeSettings()
            default:
                EmptyView()
            }
        } else {
            if let profileData = profileDataMap[identifier] {
                ProfileView(profile: profileData)
            }
        }
    }
}

extension View {
    func withNavigationDestinations(bottomPadding: CGFloat) -> some View {
        modifier(NavigationDestinations(bottomPadding: bottomPadding))
    }
    func apply<V: View>(@ViewBuilder transform: (Self) -> V) -> some View {
        transform(self)
    }
}

// MARK: Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
