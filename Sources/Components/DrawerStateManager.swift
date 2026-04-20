import SwiftUI
import Combine

// MARK: - Drawer State Manager

// MARK: - Demo Concept

enum DemoConcept: String, CaseIterable {
    case none = "none"
    // Add demo concepts here as the agent creates them
    // case concept1 = "concept1"

    var displayName: String {
        switch self {
        case .none: return "Default"
        }
    }
}

// MARK: - Demo Concept Settings

class DemoConceptSettings {
    static let shared = DemoConceptSettings()
    var selectedConcept: DemoConcept = .none {
        didSet {
            UserDefaults.standard.set(selectedConcept.rawValue, forKey: "demoConceptSelected")
            resetID = UUID()
        }
    }
    var resetID = UUID()

    func selectConcept(_ concept: DemoConcept) {
        // Always bump resetID — even if re-selecting the same concept
        // This forces the view to re-trigger the flow from the start
        resetID = UUID()
        selectedConcept = concept
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: "demoConceptSelected"),
           let concept = DemoConcept(rawValue: saved) {
            self.selectedConcept = concept
        }
    }
}

class DrawerStateManager: ObservableObject {
    @Published var isDrawerOpen: Bool = false
    @Published var showDemoModePicker: Bool = false
    
    /// Signal for navigation requests from the drawer.
    /// External code sets this, target components listen and handle navigation themselves.
    @Published var pendingNavigation: String? = nil
    
    /// Signal for tab switching requests from the drawer.
    @Published var pendingTabSwitch: String? = nil

    /// Signal a request to re-present the Today's Snapshot landing as a
    /// full-screen experience (used by entry points like the Feed QP).
    @Published var requestShowSnapshot: Bool = false
    
    func openDrawer() {
        withAnimation(.swapShuffleIn(MotionDuration.mediumIn)) {
            isDrawerOpen = true
        }
    }
    
    func closeDrawer() {
        withAnimation(.swapShuffleOut(MotionDuration.mediumOut)) {
            isDrawerOpen = false
        }
    }
    
    func toggleDrawer() {
        if isDrawerOpen {
            closeDrawer()
        } else {
            openDrawer()
        }
    }
    
    /// Request navigation to a destination. Closes the drawer and signals the target.
    func navigateTo(_ destination: String) {
        closeDrawer()
        // Delay slightly to let drawer close animation start
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pendingNavigation = destination
        }
    }
    
    /// Request switching to a specific tab.
    func switchToTab(_ tabName: String) {
        closeDrawer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pendingTabSwitch = tabName
        }
    }
    
    /// Switch to a tab and then navigate to a destination within that tab.
    /// Useful for navigating to views that live within a specific tab's NavigationStack.
    func switchToTabAndNavigate(tab: String, destination: String) {
        closeDrawer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pendingTabSwitch = tab
            // Give the tab switch time to complete before triggering navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.pendingNavigation = destination
            }
        }
    }
    
    /// Clear pending navigation after it's been handled.
    func clearPendingNavigation() {
        pendingNavigation = nil
    }
    
    /// Clear pending tab switch after it's been handled.
    func clearPendingTabSwitch() {
        pendingTabSwitch = nil
    }

    /// Request the Today's Snapshot landing to re-present (e.g. from a
    /// Feed entry point QP). ContentView observes `requestShowSnapshot`
    /// and animates the landing back in.
    func showSnapshot() {
        requestShowSnapshot = true
    }

    /// Clear the snapshot show request after it's been handled.
    func clearShowSnapshotRequest() {
        requestShowSnapshot = false
    }
}
