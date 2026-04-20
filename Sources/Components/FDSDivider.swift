import SwiftUI

// MARK: - Divider Surface Type
enum FDSDividerSurface {
    case surface
    case media
    case color
}

// MARK: - Divider Orientation
enum FDSDividerOrientation {
    case horizontal
    case vertical
}

// MARK: - FDSDivider Component
struct FDSDivider: View {
    let surface: FDSDividerSurface
    let orientation: FDSDividerOrientation
    let inset: Bool

    init(
        surface: FDSDividerSurface = .surface,
        orientation: FDSDividerOrientation = .horizontal,
        inset: Bool = false
    ) {
        self.surface = surface
        self.orientation = orientation
        self.inset = inset
    }

    private var dividerColor: Color {
        switch surface {
        case .surface: return Color("borderUiEmphasis")
        case .media: return Color("borderOnMedia")
        case .color: return Color("borderOnColor")
        }
    }

    var body: some View {
        switch orientation {
        case .horizontal:
            Rectangle()
                .fill(dividerColor)
                .frame(height: 0.5)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, inset ? 16 : 0)
        case .vertical:
            Rectangle()
                .fill(dividerColor)
                .frame(width: 0.5)
                .frame(maxHeight: .infinity)
                .padding(.vertical, inset ? 16 : 0)
        }
    }
}

// MARK: - Divider Preview View
struct DividerPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Divider",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Full-width divider") {
                            VStack(spacing: 12) {
                                Text("Content above")
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))
                                FDSDivider()
                                Text("Content below")
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))
                            }
                        }

                        ButtonGroupCard(title: "Inset divider") {
                            VStack(spacing: 12) {
                                Text("Content above")
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))
                                FDSDivider(inset: true)
                                Text("Content below")
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))
                            }
                        }

                        ButtonGroupCard(title: "Between list items") {
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Item 1")
                                        .body3Typography()
                                        .foregroundStyle(Color("primaryText"))
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                FDSDivider(inset: true)
                                HStack {
                                    Text("Item 2")
                                        .body3Typography()
                                        .foregroundStyle(Color("primaryText"))
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                FDSDivider(inset: true)
                                HStack {
                                    Text("Item 3")
                                        .body3Typography()
                                        .foregroundStyle(Color("primaryText"))
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "On media", backgroundType: .media) {
                            VStack(spacing: 12) {
                                Text("Content above")
                                    .body3Typography()
                                    .foregroundStyle(Color("alwaysWhite"))
                                FDSDivider(surface: .media)
                                Text("Content below")
                                    .body3Typography()
                                    .foregroundStyle(Color("alwaysWhite"))
                            }
                        }

                        ButtonGroupCard(title: "On color", backgroundType: .purple) {
                            VStack(spacing: 12) {
                                Text("Content above")
                                    .body3Typography()
                                    .foregroundStyle(Color("alwaysWhite"))
                                FDSDivider(surface: .color)
                                Text("Content below")
                                    .body3Typography()
                                    .foregroundStyle(Color("alwaysWhite"))
                            }
                        }

                        ButtonGroupCard(title: "Vertical divider") {
                            HStack(spacing: 12) {
                                Text("Left")
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))
                                FDSDivider(orientation: .vertical)
                                    .frame(height: 24)
                                Text("Right")
                                    .body3Typography()
                                    .foregroundStyle(Color("primaryText"))
                            }
                            .frame(height: 40)
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
        DividerPreviewView()
    }
}
