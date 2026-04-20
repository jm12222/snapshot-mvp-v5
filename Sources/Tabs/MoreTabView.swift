import SwiftUI

struct ProductItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let tabSwitch: String?
    let navigationValue: String?
    
    init(name: String, icon: String, tabSwitch: String? = nil, navigationValue: String? = nil) {
        self.name = name
        self.icon = icon
        self.tabSwitch = tabSwitch
        self.navigationValue = navigationValue
    }
}

struct MoreTabView: View {
    var bottomPadding: CGFloat = 0
    @EnvironmentObject private var drawerState: DrawerStateManager
    
    private let products = [
        ProductItem(name: "Groups", icon: "app-facebook-groups-outline", navigationValue: "nav:groupsTab"),
        ProductItem(name: "Events", icon: "calendar-star-outline"),
        ProductItem(name: "Memories", icon: "on-this-day-outline"),
        ProductItem(name: "Saved", icon: "bookmark-outline"),
        ProductItem(name: "Reels", icon: "app-facebook-reels-outline", tabSwitch: "reels"),
        ProductItem(name: "Marketplace", icon: "marketplace-outline", tabSwitch: "marketplace"),
        ProductItem(name: "Friends", icon: "friends-outline", tabSwitch: "friends"),
        ProductItem(name: "Feeds", icon: "feeds-outline")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                VStack(spacing: 12) {
                    profileCell
                    productGrid
                    seeMoreButton
                    settingsCells
                    prototypeSettingsButton
                    logOutButton
                }
                .padding(.top, 0)
                .padding(.bottom, bottomPadding + 12)
            }
        }
        .background(Color("surfaceBackground"))
    }
    
    
    private var profileCell: some View {
        Button {
            drawerState.switchToTab("profile")
        } label: {
            FDSListCell(
                headlineText: "Daniela Giménez",
                leftAddOn: .profilePhoto("profile1")
            )
            .padding(.vertical, 4)
        }

        .buttonStyle(FDSPressedState(cornerRadius: 12, isOnMedia: false, scale: .none))
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
    }
    
    private var productGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ], spacing: 8) {
            ForEach(products) { product in
                if let tabSwitch = product.tabSwitch {
                    // Tab switch items - use action to signal tab change
                    FDSActionTile(
                        topAddOn: .icon(product.icon),
                        headline: product.name,
                        action: {
                            drawerState.switchToTab(tabSwitch)
                        }
                    )
                } else if let navValue = product.navigationValue {
                    // Navigation items - push onto root NavigationStack (covers entire app)
                    FDSActionTile(
                        topAddOn: .icon(product.icon),
                        headline: product.name,
                        action: {
                            drawerState.navigateTo(navValue)
                        }
                    )
                } else {
                    // Non-navigating items
                    FDSActionTile(
                        topAddOn: .icon(product.icon),
                        headline: product.name,
                        action: {}
                    )
                }
            }
        }
        .padding(.horizontal, 12)
    }
    
    private var seeMoreButton: some View {
        FDSButton(
            type: .secondary,
            label: "See more",
            size: .medium
        ) {
            // Action
        }
        .padding(.horizontal, 12)
    }
    
    private var settingsCells: some View {
        VStack(spacing: 0) {
            FDSListCell(
                headlineText: "Help & support",
                leftAddOn: .icon("comment-questions-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
            
            FDSListCell(
                headlineText: "Settings & privacy",
                leftAddOn: .icon("settings-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
            
            FDSListCell(
                headlineText: "Professional access",
                leftAddOn: .icon("more-shapes-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
            
            FDSListCell(
                headlineText: "Also from Meta",
                leftAddOn: .icon("grid-9-outline", iconSize: 24),
                rightAddOn: .chevron,
                action: {}
            )
        }
    }
    
    private var prototypeSettingsButton: some View {
        FDSButton(
            type: .secondary,
            label: "Prototype settings",
            size: .medium
        ) {
            drawerState.navigateTo("nav:prototypeSettings")
        }
        .padding(.horizontal, 12)
    }
    
    private var logOutButton: some View {
        FDSButton(
            type: .secondary,
            label: "Log out",
            size: .medium
        ) {
            // Log out action
        }
        .padding(.horizontal, 12)
    }
}

#Preview {
    MoreTabView()
        .environmentObject(FDSTabBarHelper())
        .environmentObject(DrawerStateManager())
}
