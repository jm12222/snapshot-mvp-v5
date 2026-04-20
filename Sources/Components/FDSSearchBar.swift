import SwiftUI

// MARK: - FDSSearchBar Component
struct FDSSearchBar: View {
    @Binding var text: String
    let placeholder: String
    let onSubmit: (() -> Void)?
    let onCancel: (() -> Void)?
    let showCancelButton: Bool
    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        placeholder: String = "Search",
        showCancelButton: Bool = true,
        onSubmit: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.showCancelButton = showCancelButton
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image("search-outline")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color("secondaryIcon"))

                TextField(placeholder, text: $text)
                    .body3Typography()
                    .foregroundStyle(Color("primaryText"))
                    .focused($isFocused)
                    .onSubmit { onSubmit?() }

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image("x-circle-filled")
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color("secondaryIcon"))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color("webWash"))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            if showCancelButton && isFocused {
                Button("Cancel") {
                    text = ""
                    isFocused = false
                    onCancel?()
                }
                .body3LinkTypography()
                .foregroundStyle(Color("accent"))
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.enterIn(MotionDuration.shortIn), value: isFocused)
    }
}

// MARK: - Search Bar Preview View
struct SearchBarPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText1 = ""
    @State private var searchText2 = "Lakers"
    @State private var searchText3 = ""

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Search Bar",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Empty state") {
                            FDSSearchBar(text: $searchText1)
                        }

                        ButtonGroupCard(title: "With text") {
                            FDSSearchBar(text: $searchText2)
                        }

                        ButtonGroupCard(title: "Custom placeholder") {
                            FDSSearchBar(
                                text: $searchText3,
                                placeholder: "Search notifications..."
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Without cancel button") {
                            FDSSearchBar(
                                text: .constant(""),
                                placeholder: "Search",
                                showCancelButton: false
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color("surfaceBackground"))
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        SearchBarPreviewView()
    }
}
