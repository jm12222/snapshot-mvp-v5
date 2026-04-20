import SwiftUI

// MARK: - Glass Effect Settings
@Observable
class GlassEffectSettings {
    static let shared = GlassEffectSettings()
    var isEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "glassEffectEnabled")
        }
    }

    private init() {
        if UserDefaults.standard.object(forKey: "glassEffectEnabled") != nil {
            self.isEnabled = UserDefaults.standard.bool(forKey: "glassEffectEnabled")
        }
    }
}

// MARK: - Floating Tab Bar Settings
@Observable
class FloatingTabBarSettings {
    static let shared = FloatingTabBarSettings()
    var isEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "floatingTabBarEnabled")
        }
    }

    private init() {
        if UserDefaults.standard.object(forKey: "floatingTabBarEnabled") != nil {
            self.isEnabled = UserDefaults.standard.bool(forKey: "floatingTabBarEnabled")
        } else {
            self.isEnabled = true
        }
    }
}

// MARK: - Prototype Settings (Main Secret Menu)

struct PrototypeSettings: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Prototype settings",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Demo Mode — top level

                    VStack(spacing: 0) {
                        FDSUnitHeader(
                            headlineText: "Demo mode",
                            rightAddOn: .actionText(
                                label: DemoConceptSettings.shared.selectedConcept != .none ? "Reset" : "",
                                action: {
                                    DemoConceptSettings.shared.selectConcept(.none)
                                }
                            )
                        )

                        ForEach(DemoConcept.allCases, id: \.self) { concept in
                            FDSListCell(
                                headlineText: concept.displayName,
                                rightAddOn: DemoConceptSettings.shared.selectedConcept == concept ? .chevron : .chevron
                            ) {
                                // Select and dismiss back to app
                                DemoConceptSettings.shared.selectConcept(concept)
                                dismiss()
                            }
                        }
                    }

                    // MARK: Settings

                    FDSListCell(
                        headlineText: "Settings",
                        bodyText: "Prototype display options",
                        rightAddOn: .chevron
                    ) {
                        SettingsView().hideFDSTabBar(true)
                    }

                    // MARK: Foundations

                    FDSListCell(
                        headlineText: "Foundations",
                        bodyText: "Colors, type, icons, motion, shadows",
                        rightAddOn: .chevron
                    ) {
                        FoundationsView().hideFDSTabBar(true)
                    }

                    // MARK: Components

                    FDSListCell(
                        headlineText: "Components",
                        bodyText: "FDS Blueprint component library",
                        rightAddOn: .chevron
                    ) {
                        ComponentsView().hideFDSTabBar(true)
                    }
                }
                .padding(.horizontal, 0)
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Settings",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FDSUnitHeader(
                        headlineText: "Prototype display",
                        rightAddOn: .actionText(
                            label: "Reset",
                            action: {
                                GlassEffectSettings.shared.isEnabled = false
                                TouchSettings.shared.isEnabled = false
                                FloatingTabBarSettings.shared.isEnabled = true
                            }
                        )
                    )
                    VStack(spacing: 0) {
                        FDSListCell(
                            headlineText: "Liquid glass effect",
                            bodyText: GlassEffectSettings.shared.isEnabled ? "On" : "Off",
                            leftAddOn: .icon("water-outline", iconSize: 24),
                            rightAddOn: .toggle(isOn: Binding(
                                get: { GlassEffectSettings.shared.isEnabled },
                                set: { GlassEffectSettings.shared.isEnabled = $0 }
                            )),
                            action: {}
                        )
                        FDSListCell(
                            headlineText: "Enable floating tab bar",
                            bodyText: FloatingTabBarSettings.shared.isEnabled ? "On" : "Off",
                            leftAddOn: .icon("sidebar-down-blank-outline", iconSize: 24),
                            rightAddOn: .toggle(isOn: Binding(
                                get: { FloatingTabBarSettings.shared.isEnabled },
                                set: { FloatingTabBarSettings.shared.isEnabled = $0 }
                            )),
                            action: {}
                        )
                        FDSListCell(
                            headlineText: "Show touches",
                            bodyText: TouchSettings.shared.isEnabled ? "On" : "Off",
                            leftAddOn: .icon("poke-outline", iconSize: 24),
                            rightAddOn: .toggle(isOn: Binding(
                                get: { TouchSettings.shared.isEnabled },
                                set: { TouchSettings.shared.isEnabled = $0 }
                            )),
                            action: {}
                        )
                    }
                }
            }
            .background(Color("surfaceBackground"))
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Foundations View

struct FoundationsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Foundations",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        FDSListCell(headlineText: "Colors", leftAddOn: .icon("palette-outline", iconSize: 24), rightAddOn: .chevron) {
                            ColorsPreviewView().hideFDSTabBar(true)
                        }
                        FDSListCell(headlineText: "Icons", leftAddOn: .icon("photo-square-outline", iconSize: 24), rightAddOn: .chevron) {
                            IconsPreviewView().hideFDSTabBar(true)
                        }
                        FDSListCell(headlineText: "Typography", leftAddOn: .icon("text-outline", iconSize: 24), rightAddOn: .chevron) {
                            TypographyPreviewView().hideFDSTabBar(true)
                        }
                        FDSListCell(headlineText: "Motion", leftAddOn: .icon("text-animation-outline", iconSize: 24), rightAddOn: .chevron) {
                            MotionPreviewView().hideFDSTabBar(true)
                        }
                        FDSListCell(headlineText: "Shadows", leftAddOn: .icon("paper-stack-outline", iconSize: 24), rightAddOn: .chevron) {
                            ShadowPreviewView().hideFDSTabBar(true)
                        }
                    }
                }
            }
            .background(Color("surfaceBackground"))
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Components View

struct ComponentsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Components",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Navigation — how users move between screens
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Navigation", bodyText: "How users move between screens")
                        VStack(spacing: 0) {
                            FDSListCell(headlineText: "Navigation Bar", rightAddOn: .chevron) { NavigationBarPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Sub-Navigation Bar", rightAddOn: .chevron) { SubNavigationBarPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Tab Bar", rightAddOn: .chevron) { TabBarPreviewView().hideFDSTabBar(true) }
                        }
                    }

                    // Actions — how users take action
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Actions", bodyText: "How users take action")
                        VStack(spacing: 0) {
                            FDSListCell(headlineText: "Buttons & Chips", rightAddOn: .chevron) { ButtonsPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Icon Buttons", rightAddOn: .chevron) { IconButtonsPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Selection Cell", rightAddOn: .chevron) { SelectionCellPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Reaction Bar", rightAddOn: .chevron) { ReactionBarPreviewView().hideFDSTabBar(true) }
                        }
                    }

                    // Content — what users see
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Content", bodyText: "What users see")
                        VStack(spacing: 0) {
                            FDSListCell(headlineText: "List Cell", rightAddOn: .chevron) { ListCellsPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Notification Cell", rightAddOn: .chevron) { NotificationCellPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Unit Header", rightAddOn: .chevron) { UnitHeaderPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Text Pairing", rightAddOn: .chevron) { FDSTextPairingPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Comment", rightAddOn: .chevron) { CommentsPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Divider", rightAddOn: .chevron) { DividerPreviewView().hideFDSTabBar(true) }
                        }
                    }

                    // Identity & Media — people, entities, and visual content
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Identity & Media", bodyText: "People, entities, and visual content")
                        VStack(spacing: 0) {
                            FDSListCell(headlineText: "Profile Photo", rightAddOn: .chevron) { ProfilePhotoPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Facepile", rightAddOn: .chevron) { FacepilePreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Media Card", rightAddOn: .chevron) { MediaCardPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Asset Lockup", rightAddOn: .chevron) { AssetLockupPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Action Tile", rightAddOn: .chevron) { ActionTilesPreviewView().hideFDSTabBar(true) }
                        }
                    }

                    // Feedback & Status — system communicating state to the user
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Feedback & Status", bodyText: "System communicating state to the user")
                        VStack(spacing: 0) {
                            FDSListCell(headlineText: "Contextual Message", rightAddOn: .chevron) { ContextualMessagePreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Tooltip", rightAddOn: .chevron) { TooltipPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Badge", rightAddOn: .chevron) { BadgePreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Confirmation Dialogues (Toasts)", rightAddOn: .chevron) { InstantFeedbackPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Progress", rightAddOn: .chevron) { ProgressPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Glimmer (Loading)", rightAddOn: .chevron) { GlimmerPreviewView().hideFDSTabBar(true) }
                        }
                    }

                    // Inputs & Surfaces — data entry and overlay containers
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Inputs & Surfaces", bodyText: "Data entry and overlay containers")
                        VStack(spacing: 0) {
                            FDSListCell(headlineText: "Text Input", rightAddOn: .chevron) { TextInputsPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Search Bar", rightAddOn: .chevron) { SearchBarPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Bottom Sheet", rightAddOn: .chevron) { BottomSheetPreviewView().hideFDSTabBar(true) }
                            FDSListCell(headlineText: "Share Sheet", rightAddOn: .chevron) { ShareSheetPreviewView().hideFDSTabBar(true) }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color("surfaceBackground"))
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview
#Preview {
    PrototypeSettings()
        .environmentObject(FDSTabBarHelper())
}
