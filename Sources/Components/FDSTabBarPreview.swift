import SwiftUI

// AGENT RULES (not shown in UI):
// - Use the floating tab bar built into this template (FDSTabView). Never build a new tab bar.
// - 3-6 tabs. Home always first, More always last. Don't change static tab order.
// - Static tabs: Home, Notifications, More. Targeted tabs fill the middle.
// - States: default (outline icon), active (filled icon), number badge.
// - Long press opens context menu. Double-tap profile switches accounts.
// - Labels: sentence case, max two words, name of the surface it navigates to.

struct TabBarPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(title: "Tab Bar", backAction: { dismiss() })

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    FDSListCell(
                        headlineText: "Floating tab bar",
                        bodyText: "Default — used across all surfaces",
                        action: {}
                    )

                    FDSListCell(
                        headlineText: "5 tabs",
                        bodyText: "Home, Video, Groups, Notifications, More",
                        action: {}
                    )

                    FDSListCell(
                        headlineText: "Active state",
                        bodyText: "Filled icon + label highlight",
                        action: {}
                    )

                    FDSListCell(
                        headlineText: "Number badge",
                        bodyText: "Red badge on Notifications tab",
                        action: {}
                    )

                    FDSUnitHeader(headlineText: "Appendix")

                    FDSListCell(
                        headlineText: "Dark tab bar",
                        bodyText: "Used on Reels surface only",
                        action: {}
                    )

                    FDSListCell(
                        headlineText: "Profile photo tab",
                        bodyText: "When 2+ profiles, bookmark becomes profile photo",
                        action: {}
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color("surfaceBackground"))
        .toolbar(.hidden, for: .navigationBar)
    }
}
