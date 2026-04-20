import SwiftUI

// MARK: - Badge Type
enum FDSBadgeType {
    case numbered(Int)     // Shows count (e.g., "3", "99+")
    case dot               // Simple dot indicator
}

// MARK: - Badge Surface
enum FDSBadgeSurface {
    case surface
    case onMedia
    case onColor
}

// MARK: - FDSBadge Component
struct FDSBadge: View {
    let type: FDSBadgeType
    let surface: FDSBadgeSurface

    init(
        type: FDSBadgeType = .dot,
        surface: FDSBadgeSurface = .surface
    ) {
        self.type = type
        self.surface = surface
    }

    private var backgroundColor: Color {
        switch surface {
        case .surface: return Color("negative")
        case .onMedia: return Color("negative")
        case .onColor: return Color("alwaysWhite")
        }
    }

    private var textColor: Color {
        switch surface {
        case .surface, .onMedia: return Color("alwaysWhite")
        case .onColor: return Color("negative")
        }
    }

    private var borderColor: Color {
        switch surface {
        case .surface: return Color("cardBackground")
        case .onMedia: return Color.clear
        case .onColor: return Color.clear
        }
    }

    var body: some View {
        switch type {
        case .numbered(let count):
            let displayText = count > 99 ? "99+" : "\(count)"
            Text(displayText)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 5)
                .frame(minWidth: 18, minHeight: 18)
                .background(backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: 2)
                )
        case .dot:
            Circle()
                .fill(backgroundColor)
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(borderColor, lineWidth: 2)
                )
        }
    }
}

// MARK: - Badge Modifier (overlay on any view)
struct FDSBadgeModifier: ViewModifier {
    let type: FDSBadgeType
    let surface: FDSBadgeSurface

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                FDSBadge(type: type, surface: surface)
                    .offset(x: 6, y: -6)
            }
    }
}

extension View {
    func fdsBadge(_ type: FDSBadgeType, surface: FDSBadgeSurface = .surface) -> some View {
        modifier(FDSBadgeModifier(type: type, surface: surface))
    }
}

// MARK: - Badge Preview View
struct BadgePreviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Badge",
                backAction: { dismiss() }
            )

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Selects")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "Dot badge") {
                            HStack(spacing: 24) {
                                VStack(spacing: 8) {
                                    Image("bell-filled")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(Color("primaryIcon"))
                                        .fdsBadge(.dot)
                                    Text("Icon")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }

                                VStack(spacing: 8) {
                                    Image("profile1")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .fdsBadge(.dot)
                                    Text("Profile")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        ButtonGroupCard(title: "Numbered badge") {
                            HStack(spacing: 24) {
                                VStack(spacing: 8) {
                                    Image("bell-filled")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(Color("primaryIcon"))
                                        .fdsBadge(.numbered(3))
                                    Text("3")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }

                                VStack(spacing: 8) {
                                    Image("bell-filled")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(Color("primaryIcon"))
                                        .fdsBadge(.numbered(42))
                                    Text("42")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }

                                VStack(spacing: 8) {
                                    Image("bell-filled")
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundStyle(Color("primaryIcon"))
                                        .fdsBadge(.numbered(150))
                                    Text("99+")
                                        .meta3Typography()
                                        .foregroundStyle(Color("secondaryText"))
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }

                        ButtonGroupCard(title: "Standalone badges") {
                            HStack(spacing: 16) {
                                FDSBadge(type: .dot)
                                FDSBadge(type: .numbered(1))
                                FDSBadge(type: .numbered(5))
                                FDSBadge(type: .numbered(99))
                                FDSBadge(type: .numbered(100))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                    FDSUnitHeader(headlineText: "Appendix")

                    VStack(spacing: 12) {
                        ButtonGroupCard(title: "On media", backgroundType: .media) {
                            HStack(spacing: 24) {
                                Image("bell-filled")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color("alwaysWhite"))
                                    .fdsBadge(.dot, surface: .onMedia)

                                Image("bell-filled")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color("alwaysWhite"))
                                    .fdsBadge(.numbered(7), surface: .onMedia)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        ButtonGroupCard(title: "On color", backgroundType: .purple) {
                            HStack(spacing: 24) {
                                Image("bell-filled")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color("alwaysWhite"))
                                    .fdsBadge(.dot, surface: .onColor)

                                Image("bell-filled")
                                    .resizable()
                                    .renderingMode(.template)
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color("alwaysWhite"))
                                    .fdsBadge(.numbered(12), surface: .onColor)
                            }
                            .frame(maxWidth: .infinity)
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
        BadgePreviewView()
    }
}
