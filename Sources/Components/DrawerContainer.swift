import SwiftUI

// MARK: - Drawer Container

struct DrawerContainer<DrawerContent: View, MainContent: View>: View {
    @ObservedObject var drawerState: DrawerStateManager
    let drawerContent: DrawerContent
    let mainContent: MainContent
    
    private let drawerWidth: CGFloat = 335
    
    init(
        drawerState: DrawerStateManager,
        @ViewBuilder drawerContent: () -> DrawerContent,
        @ViewBuilder mainContent: () -> MainContent
    ) {
        self.drawerState = drawerState
        self.drawerContent = drawerContent()
        self.mainContent = mainContent()
    }
    
    var body: some View {
        ZStack {
            // Main content with dimming overlay on top
            ZStack {
                mainContent
                
                // Dimming overlay - lives on top of main content, animates with it
                Color.black
                    .opacity(drawerState.isDrawerOpen ? 0.4 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(drawerState.isDrawerOpen)
                    .onTapGesture {
                        drawerState.closeDrawer()
                    }
            }
            .offset(x: drawerState.isDrawerOpen ? drawerWidth : 0)
            
            // Drawer content - fixed width on left, positioned off-screen when closed
            HStack(spacing: 0) {
                drawerContent
                    .frame(width: drawerWidth)
                Spacer()
            }
            .offset(x: drawerState.isDrawerOpen ? 0 : -drawerWidth)
        }
        .animation(.swapShuffleIn(MotionDuration.mediumIn), value: drawerState.isDrawerOpen)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    
                    // Swipe from left edge to open
                    if gesture.translation.width > threshold && !drawerState.isDrawerOpen && gesture.startLocation.x < 50 {
                        drawerState.openDrawer()
                    }
                    // Swipe right to close (when drawer is open)
                    else if gesture.translation.width < -threshold && drawerState.isDrawerOpen {
                        drawerState.closeDrawer()
                    }
                }
        )
    }
}
