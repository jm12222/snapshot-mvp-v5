import SwiftUI

// MARK: - Selection Cell Right Add-On
enum FDSSelectionCellRightAddOn {
    case checkbox
    case radioButton
    case toggle
}

// MARK: - Selection Cell Left Add-On
enum FDSSelectionCellLeftAddOn {
    case icon(String)
    case containedIcon(String, backgroundColor: Color? = nil)
    case profilePhoto(String)
}

// MARK: - FDSSelectionCell Component
struct FDSSelectionCell: View {
    let headlineText: String
    let bodyText: String?
    let metaText: String?
    let isSelected: Bool
    let rightAddOn: FDSSelectionCellRightAddOn
    let leftAddOn: FDSSelectionCellLeftAddOn?
    let isError: Bool
    let action: () -> Void

    init(
        headlineText: String,
        bodyText: String? = nil,
        metaText: String? = nil,
        isSelected: Bool = false,
        rightAddOn: FDSSelectionCellRightAddOn = .checkbox,
        leftAddOn: FDSSelectionCellLeftAddOn? = nil,
        isError: Bool = false,
        action: @escaping () -> Void
    ) {
        self.headlineText = headlineText
        self.bodyText = bodyText
        self.metaText = metaText
        self.isSelected = isSelected
        self.rightAddOn = rightAddOn
        self.leftAddOn = leftAddOn
        self.isError = isError
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let leftAddOn = leftAddOn {
                    leftAddOnView(leftAddOn)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(headlineText)
                        .headline4Typography()
                        .foregroundStyle(Color("primaryText"))
                    if let bodyText = bodyText {
                        Text(bodyText)
                            .body3Typography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                    if let metaText = metaText {
                        Text(metaText)
                            .meta2Typography()
                            .foregroundStyle(isError ? Color("negative") : Color("secondaryText"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                rightAddOnView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("cardBackground"))
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0))
    }

    @ViewBuilder
    private func leftAddOnView(_ addOn: FDSSelectionCellLeftAddOn) -> some View {
        switch addOn {
        case .icon(let name):
            Image(name)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color("primaryIcon"))
        case .containedIcon(let name, let bgColor):
            Image(name)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color("alwaysWhite"))
                .frame(width: 40, height: 40)
                .background(bgColor ?? Color("accent"))
                .clipShape(Circle())
        case .profilePhoto(let imageName):
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    private var rightAddOnView: some View {
        switch rightAddOn {
        case .checkbox:
            Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                .font(.system(size: 22))
                .foregroundStyle(isSelected ? Color("accent") : Color("secondaryIcon"))
        case .radioButton:
            Circle()
                .strokeBorder(isSelected ? Color("accent") : Color("secondaryIcon"), lineWidth: 2)
                .frame(width: 22, height: 22)
                .overlay(
                    Circle()
                        .fill(isSelected ? Color("accent") : Color.clear)
                        .frame(width: 12, height: 12)
                )
        case .toggle:
            Toggle("", isOn: .constant(isSelected))
                .labelsHidden()
                .tint(Color("accent"))
        }
    }
}

// MARK: - Selection Cell Preview View
struct SelectionCellPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checkboxSelections: Set<Int> = [0, 2]
    @State private var radioSelection: Int = 1
    @State private var toggleStates: [Bool] = [true, false, true]

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Selection Cell",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Checkbox — multi-select") {
                            VStack(spacing: 0) {
                                ForEach(0..<3, id: \.self) { i in
                                    VStack(spacing: 0) {
                                        FDSSelectionCell(
                                            headlineText: ["Sports", "Technology", "Entertainment"][i],
                                            bodyText: ["NBA, NFL, Soccer", "AI, Gadgets, Coding", "Movies, Music, TV"][i],
                                            isSelected: checkboxSelections.contains(i),
                                            rightAddOn: .checkbox,
                                            action: {
                                                if checkboxSelections.contains(i) {
                                                    checkboxSelections.remove(i)
                                                } else {
                                                    checkboxSelections.insert(i)
                                                }
                                            }
                                        )
                                        if i < 2 { FDSDivider(inset: true) }
                                    }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        ButtonGroupCard(title: "Radio — single select") {
                            VStack(spacing: 0) {
                                ForEach(0..<3, id: \.self) { i in
                                    VStack(spacing: 0) {
                                        FDSSelectionCell(
                                            headlineText: ["Daily", "Weekly", "Monthly"][i],
                                            isSelected: radioSelection == i,
                                            rightAddOn: .radioButton,
                                            action: { radioSelection = i }
                                        )
                                        if i < 2 { FDSDivider(inset: true) }
                                    }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        ButtonGroupCard(title: "Toggle — with icon") {
                            VStack(spacing: 0) {
                                FDSSelectionCell(
                                    headlineText: "Push notifications",
                                    bodyText: "Get notified about activity",
                                    isSelected: toggleStates[0],
                                    rightAddOn: .toggle,
                                    leftAddOn: .icon("bell-filled"),
                                    action: { toggleStates[0].toggle() }
                                )
                                FDSDivider(inset: true)
                                FDSSelectionCell(
                                    headlineText: "Email updates",
                                    bodyText: "Receive weekly digest",
                                    isSelected: toggleStates[1],
                                    rightAddOn: .toggle,
                                    leftAddOn: .icon("mail-filled"),
                                    action: { toggleStates[1].toggle() }
                                )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "With profile photo") {
                            VStack(spacing: 0) {
                                FDSSelectionCell(
                                    headlineText: "Alex Chen",
                                    bodyText: "Product Designer",
                                    isSelected: true,
                                    rightAddOn: .checkbox,
                                    leftAddOn: .profilePhoto("profile1"),
                                    action: {}
                                )
                                FDSDivider(inset: true)
                                FDSSelectionCell(
                                    headlineText: "Jordan Park",
                                    bodyText: "Engineer",
                                    isSelected: false,
                                    rightAddOn: .checkbox,
                                    leftAddOn: .profilePhoto("profile2"),
                                    action: {}
                                )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        ButtonGroupCard(title: "With contained icon") {
                            FDSSelectionCell(
                                headlineText: "Location access",
                                bodyText: "Allow app to use your location",
                                metaText: "Required for nearby features",
                                isSelected: true,
                                rightAddOn: .checkbox,
                                leftAddOn: .containedIcon("pin-filled", backgroundColor: Color("decorativeIconBlue")),
                                action: {}
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        ButtonGroupCard(title: "Error state") {
                            FDSSelectionCell(
                                headlineText: "Terms and conditions",
                                metaText: "You must accept to continue",
                                isSelected: false,
                                rightAddOn: .checkbox,
                                isError: true,
                                action: {}
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
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
        SelectionCellPreviewView()
    }
}
