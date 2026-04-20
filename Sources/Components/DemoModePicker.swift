import SwiftUI

// MARK: - Demo Mode Settings View
// Matches PrototypeSettings format — full page push with FDSNavigationBarCentered + FDSListCell rows
// Selecting a concept (or re-selecting the current one) triggers resetID to restart the flow

struct DemoModeSettings: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedConcept = DemoConceptSettings.shared.selectedConcept

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Demo mode",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Active indicator
                    if selectedConcept != .none {
                        VStack(spacing: 0) {
                            FDSUnitHeader(
                                headlineText: "Active",
                                rightAddOn: .actionText(
                                    label: "Reset",
                                    action: {
                                        selectedConcept = .none
                                        DemoConceptSettings.shared.selectConcept(.none)
                                    }
                                )
                            )
                            FDSListCell(
                                headlineText: selectedConcept.displayName,
                                bodyText: "Tap any concept below to switch or re-trigger",
                                action: {}
                            )
                        }
                    }

                    // Concepts list
                    VStack(spacing: 0) {
                        FDSUnitHeader(headlineText: "Concepts")

                        ForEach(DemoConcept.allCases, id: \.self) { concept in
                            FDSListCell(
                                headlineText: concept.displayName,
                                rightAddOn: .chevron
                            ) {
                                // Always trigger — even if re-selecting current concept
                                selectedConcept = concept
                                DemoConceptSettings.shared.selectConcept(concept)
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
