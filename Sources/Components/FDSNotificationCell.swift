import SwiftUI

// MARK: - FDSNotificationCell

struct FDSNotificationCell: View {
    var headlineText: String
    var metaText: String?
    var state: CellState = .read
    var profileImage: String? // asset name
    var profileSize: CGFloat = 60
    var showMoreButton: Bool = true
    var showBlueDot: Bool = false
    var bottomAddOn: BottomAddOn?
    var action: () -> Void = {}

    enum CellState {
        case unread, read

        var backgroundColor: Color {
            switch self {
            case .unread: return Color("accentColor").opacity(0.05)
            case .read: return .white
            }
        }
    }

    enum BottomAddOn {
        case buttonGroup(
            button1Label: String, button1Action: () -> Void,
            button2Label: String, button2Action: () -> Void
        )
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Main row
                HStack(alignment: .top, spacing: 12) {
                    // Profile photo
                    if let profileImage {
                        Image(profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: profileSize, height: profileSize)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
                            )
                    } else {
                        Circle()
                            .fill(Color("secondaryButtonBackground"))
                            .frame(width: profileSize, height: profileSize)
                    }

                    // Text content
                    VStack(alignment: .leading, spacing: 2) {
                        Text(headlineText)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("primaryText"))
                            .multilineTextAlignment(.leading)

                        if let metaText {
                            HStack(spacing: 4) {
                                if showBlueDot {
                                    Circle()
                                        .fill(Color("accentColor"))
                                        .frame(width: 8, height: 8)
                                }
                                Text(metaText)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color("secondaryText"))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right add-on (more button)
                    if showMoreButton {
                        Image("dots-3-horizontal-outline")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color("secondaryIcon"))
                    }
                }

                // Bottom add-on (aligned with text, not profile photo)
                if let bottomAddOn {
                    HStack(spacing: 12) {
                        Color.clear
                            .frame(width: profileSize, height: 0)

                        bottomAddOnView(bottomAddOn)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(state.backgroundColor)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func bottomAddOnView(_ addOn: BottomAddOn) -> some View {
        switch addOn {
        case .buttonGroup(let b1Label, let b1Action, let b2Label, let b2Action):
            HStack(spacing: 8) {
                Button(action: b1Action) {
                    Text(b1Label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color("primaryButtonBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                Button(action: b2Action) {
                    Text(b2Label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color("primaryText"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color("secondaryButtonBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
    }
}

// MARK: - Preview

struct NotificationCellPreviewView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(title: "Notification Cell", backAction: { dismiss() })

            ScrollView {
                VStack(spacing: 0) {

                    FDSUnitHeader(headlineText: "Unread")

                    FDSNotificationCell(
                        headlineText: "Jenna Lopez commented on your post.",
                        metaText: "3h · \"that's too bad.\"",
                        state: .unread,
                        showBlueDot: true
                    )

                    FDSNotificationCell(
                        headlineText: "Sara Khosravi mentioned you in a comment: \"I completely agree. Well said!\"",
                        metaText: "5h · 12 reactions · 5 comments",
                        state: .unread,
                        showBlueDot: true
                    )

                    FDSUnitHeader(headlineText: "Read")

                    FDSNotificationCell(
                        headlineText: "Alex Walker and Karla Jones posted in Seattle Moms.",
                        metaText: "1d"
                    )

                    FDSNotificationCell(
                        headlineText: "Taina Thomsen shared a link.",
                        metaText: "3d"
                    )

                    FDSUnitHeader(headlineText: "With button group")

                    FDSNotificationCell(
                        headlineText: "Nikos De Jager sent you a friend request.",
                        metaText: "12 mutual friends",
                        state: .unread,
                        showBlueDot: true,
                        bottomAddOn: .buttonGroup(
                            button1Label: "Add friend", button1Action: {},
                            button2Label: "Remove", button2Action: {}
                        )
                    )

                    FDSUnitHeader(headlineText: "Sponsored")

                    FDSNotificationCell(
                        headlineText: "You might be interested in Wind & Wool: \"Shop Our Fall Sale!\"",
                        metaText: "Sponsored",
                        state: .read,
                        showMoreButton: true
                    )
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color("surfaceBackground"))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NotificationCellPreviewView()
}
