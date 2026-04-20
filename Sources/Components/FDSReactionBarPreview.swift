import SwiftUI

struct ReactionBarPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(title: "Reaction Bar", backAction: { dismiss() })
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    FDSUnitHeader(headlineText: "Default")
                    Text("Reaction bar component preview — see FDSReactionBar.swift for implementation.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color("surfaceBackground"))
        .toolbar(.hidden, for: .navigationBar)
    }
}
