import SwiftUI

// MARK: - Notifications Tab

struct NotificationsTab: View {
    var bottomPadding: CGFloat = 0
    var isSelected: Bool = false
    @State private var showSearch = false
    @State private var showSnapshot = false
    @State private var notifications: [NotificationItemData] = generateSampleNotifications()
    @AppStorage("snapshotDemoMode") private var currentDemoMode: String = SnapshotDemoMode.mvpV1.rawValue
    @EnvironmentObject private var drawerState: DrawerStateManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    FDSNavigationBar(
                        title: "Notifications",
                        titleAction: { drawerState.showDemoModePicker = true },
                        menuAction: { drawerState.openDrawer() },
                        icon0: {
                            FDSIconButton(icon: "more-outline", action: { drawerState.openDrawer() })
                        },
                        icon1: {
                            FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                        },
                        icon2: {
                            FDSIconButton(icon: "magnifying-glass-outline", action: { showSearch = true })
                        },
                        icon3: {
                            FDSIconButton(icon: "app-messenger-outline", action: {})
                        }
                    )

                    TodaysSnapshotBanner(isSelected: isSelected) {
                        showSnapshot = true
                    }

                    let groupedNotifications = groupNotificationsByDate(notifications)

                    FDSUnitHeader(headlineText: "New", hierarchyLevel: .level3)

                    let todayNotifications = groupedNotifications["Today"] ?? []
                    ForEach(todayNotifications) { notification in
                        NotificationItem(
                            data: notification,
                            onConfirm: {
                                handleConfirmFriendRequest(notification)
                            },
                            onDelete: {
                                handleDeleteNotification(notification)
                            }
                        )
                    }

                    FDSUnitHeader(headlineText: "Earlier", hierarchyLevel: .level3)

                    let earlierNotifications = groupedNotifications["Earlier"] ?? []
                    ForEach(earlierNotifications) { notification in
                        NotificationItem(
                            data: notification,
                            onConfirm: {
                                handleConfirmFriendRequest(notification)
                            },
                            onDelete: {
                                handleDeleteNotification(notification)
                            }
                        )
                    }

                    FDSButton(
                        type: .secondary,
                        label: "See previous notifications",
                        size: .medium,
                        action: {
                            print("See previous notifications tapped")
                        }
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 16)
                }
                .padding(.bottom, bottomPadding)
            }
            .background(Color("surfaceBackground"))
            .navigationDestination(isPresented: $showSnapshot) {
                if currentDemoMode == SnapshotDemoMode.v6.rawValue {
                    TodaysSnapshotLandingV6(onBack: { showSnapshot = false })
                } else if currentDemoMode == SnapshotDemoMode.v6UXR.rawValue {
                    TodaysSnapshotLandingV6UXR(onBack: { showSnapshot = false })
                } else if currentDemoMode == SnapshotDemoMode.v5.rawValue {
                    TodaysSnapshotLandingV5(onBack: { showSnapshot = false })
                } else {
                    TodaysSnapshotLandingMVPv1(onBack: { showSnapshot = false })
                }
            }
        }
    }


    private func groupNotificationsByDate(_ notifications: [NotificationItemData]) -> [String: [NotificationItemData]] {
        var grouped: [String: [NotificationItemData]] = [:]
        let calendar = Calendar.current
        let now = Date()

        for notification in notifications {
            let daysDiff = calendar.dateComponents([.day], from: notification.date, to: now).day ?? 0

            let dateKey: String
            if daysDiff == 0 {
                dateKey = "Today"
            } else {
                dateKey = "Earlier"
            }

            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]?.append(notification)
        }

        return grouped
    }

    private func handleConfirmFriendRequest(_ notification: NotificationItemData) {
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
        print("Confirmed friend request from \(notification.userName)")
    }

    private func handleDeleteNotification(_ notification: NotificationItemData) {
        withAnimation {
            notifications.removeAll { $0.id == notification.id }
        }
        print("Deleted notification from \(notification.userName)")
    }

    static func generateSampleNotifications() -> [NotificationItemData] {
        // Use the same profile mapping from ProfileView
        let profilePairs: [(name: String, image: String)] = [
            ("Bob Johnson", "profile2"),
            ("Alice Smith", "profile3"),
            ("Diana Ross", "profile4"),
            ("Alex Kim", "profile5"),
            ("Tina Wright", "profile6"),
            ("Taina Thomsen", "profile7"),
            ("Jamie Lee", "profile8"),
            ("Fatih Tekin", "profile9"),
            ("John Stockholm", "profile12"),
            ("Kelsey Fung", "profile11")
        ]

        let mutualFriendNames: [String] = [
            "John Smith", "Emily Davis", "Chris Johnson", "Alex Martinez",
            "Sam Wilson", "Jordan Lee", "Taylor Brown"
        ]

        let types: [NotificationType] = [
            .comment, .post, .friendRequest, .reel, .question, .share, .like
        ]

        var notificationsList: [NotificationItemData] = []
        let now = Date()

        for i in 0..<7 {
            let type = types[i % types.count]
            let hoursAgo: Int
            if i < 4 {
                hoursAgo = [1, 2, 3, 5].randomElement() ?? 2
            } else {
                hoursAgo = [48, 72].randomElement() ?? 48
            }
            let date = Calendar.current.date(byAdding: .hour, value: -hoursAgo, to: now) ?? now

            let mutualName = type == .friendRequest ? mutualFriendNames[i % mutualFriendNames.count] : nil
            let mutualCount = type == .friendRequest ? [2, 3, 5, 8].randomElement() : nil

            let profilePair = profilePairs[i % profilePairs.count]

            notificationsList.append(NotificationItemData(
                id: "\(i + 1)",
                userName: profilePair.name,
                profileImage: profilePair.image,
                type: type,
                date: date,
                isUnread: i < 3,
                mutualFriendName: mutualName,
                mutualFriendCount: mutualCount
            ))
        }

        return notificationsList.sorted { $0.date > $1.date }
    }
}

// MARK: - Today's Snapshot Jewel (Bolt Icon + Banner)

private struct BoltShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: w * 0.55, y: 0))
        path.addLine(to: CGPoint(x: w * 0.18, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.45, y: h * 0.52))
        path.addLine(to: CGPoint(x: w * 0.38, y: h))
        path.addLine(to: CGPoint(x: w * 0.82, y: h * 0.40))
        path.addLine(to: CGPoint(x: w * 0.55, y: h * 0.40))
        path.closeSubpath()
        return path
    }
}

private struct ShimmerBoltIcon: View {
    var isSelected: Bool
    @State private var waveOffset: CGFloat = 30
    @State private var overlayOpacity: Double = 0
    @State private var pulseTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            Image("bolt-jewel-green")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(Circle())

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .white.opacity(0.15), location: 0.2),
                    .init(color: .white.opacity(0.6), location: 0.45),
                    .init(color: .white.opacity(0.6), location: 0.55),
                    .init(color: .white.opacity(0.15), location: 0.8),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(width: 20, height: 50)
            .offset(y: waveOffset)
            .mask(BoltShape().frame(width: 20, height: 28))
            .opacity(overlayOpacity)
        }
        .onChange(of: isSelected) { _, newValue in
            pulseTask?.cancel()
            if newValue {
                pulseTask = Task { @MainActor in
                    waveOffset = 30
                    overlayOpacity = 0

                    try? await Task.sleep(nanoseconds: 350_000_000)
                    guard !Task.isCancelled else { return }

                    overlayOpacity = 1
                    withAnimation(.easeInOut(duration: 0.55)) {
                        waveOffset = -30
                    }

                    try? await Task.sleep(nanoseconds: 650_000_000)
                    guard !Task.isCancelled else { return }

                    waveOffset = 30
                    withAnimation(.easeInOut(duration: 0.55)) {
                        waveOffset = -30
                    }

                    try? await Task.sleep(nanoseconds: 600_000_000)
                    guard !Task.isCancelled else { return }

                    withAnimation(.easeInOut(duration: 0.3)) {
                        overlayOpacity = 0
                    }
                }
            } else {
                overlayOpacity = 0
                waveOffset = 30
            }
        }
    }
}

private struct TodaysSnapshotBanner: View {
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Today's snapshot")
                .headline2EmphasizedTypography()
                .foregroundStyle(Color("primaryText"))
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Button(action: { onTap?() }) {
                HStack(alignment: .top, spacing: 12) {
                    ShimmerBoltIcon(isSelected: isSelected)

                    VStack(alignment: .leading, spacing: 8) {
                        (Text("Snow hits Colorado").fontWeight(.bold)
                            + Text(", Nothing headphones, Brooklyn photo spots, upcoming birthdays.."))
                            .headline4Typography()
                            .foregroundStyle(Color("primaryText"))
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)

                        Text("Just now")
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image("snow-colorado")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                        )

                    Image("chevron-right-filled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color("secondaryIcon"))
                }
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 16)
                .background(Color("accentDeemphasized"))
            }
            .buttonStyle(FDSPressedState(cornerRadius: 0))
        }
    }
}

// MARK: - Notification Item Data

struct NotificationItemData: Identifiable {
    let id: String
    let userName: String
    let profileImage: String
    let type: NotificationType
    let date: Date
    var isUnread: Bool
    var mutualFriendName: String?
    var mutualFriendCount: Int?

    var actionText: String {
        switch type {
        case .comment:
            return "commented on your post."
        case .post:
            return "posted on your timeline."
        case .friendRequest:
            return "sent you a friend request."
        case .reel:
            return "shared a reel."
        case .question:
            return "asked a question in a group you're in."
        case .share:
            return "shared your post."
        case .like:
            return "liked your post."
        }
    }

    var timeAgoText: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: date, to: now)

        if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }

    var iconBadge: String? {
        switch type {
        case .friendRequest:
            return "friends-filled"
        case .comment:
            return "comment-filled"
        case .post:
            return "posts-filled"
        case .question:
            return "group-filled"
        case .reel:
            return "app-facebook-reels-filled"
        case .share:
            return "share-filled"
        case .like:
            return nil // Handled separately with large image
        }
    }

    var reactionBadgeImage: String? {
        switch type {
        case .like:
            return "like-large"
        default:
            return nil
        }
    }

    var badgeColor: Color {
        switch type {
        case .comment:
            return Color("notificationCircleGreen")
        case .reel:
            return Color("notificationCircleRed")
        case .post, .question, .share, .like, .friendRequest:
            return Color("notificationCircleBlue")
        }
    }
}

enum NotificationType {
    case comment
    case post
    case friendRequest
    case reel
    case question
    case share
    case like
}

// MARK: - Notification Item

struct NotificationItem: View {
    let data: NotificationItemData
    let onConfirm: (() -> Void)?
    let onDelete: () -> Void

    var body: some View {
        Button(action: {
            print("Notification tapped: \(data.userName)")
        }) {
            cellContent
        }
        .buttonStyle(FDSPressedState(cornerRadius: 0))
    }

    private var cellContent: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile photo with badge
            ZStack(alignment: .bottomTrailing) {
                Image(data.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color("mediaInnerBorder"), lineWidth: 0.5)
                    )

                // Reaction badge (like-large, haha-large, wow-large)
                if let reactionImage = data.reactionBadgeImage {
                    ZStack {
                        Circle()
                            .fill(data.isUnread ? Color("accentDeemphasized") : Color("surfaceBackground"))
                            .frame(width: 28, height: 28)

                        Image(reactionImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    }
                    .offset(x: 4, y: 4)
                }
                // Standard icon badge
                else if let iconName = data.iconBadge {
                    ZStack {
                        Circle()
                            .fill(data.isUnread ? Color("accentDeemphasized") : Color("surfaceBackground"))
                            .frame(width: 28, height: 28)

                        Circle()
                            .fill(data.badgeColor)
                            .frame(width: 24, height: 24)

                        Image(iconName)
                            .resizable()
                            .renderingMode(.template)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundColor(.white)
                    }
                    .offset(x: 4, y: 4)
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 10) {
                        (Text(data.userName).fontWeight(.semibold) + Text(" \(data.actionText)").fontWeight(.regular))
                            .headline4Typography()
                            .foregroundStyle(Color("primaryText"))

                        if data.type == .friendRequest {
                            if let mutualName = data.mutualFriendName, let count = data.mutualFriendCount {
                                Text("\(mutualName) and \(count) other mutual friends")
                                    .body4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                            }
                        } else {
                            Text(data.timeAgoText)
                                .body4Typography()
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .center)

                    Menu {
                        Button(action: { onDelete() }) {
                            Label("Delete this notification", image: "hide-outline")
                        }
                        Button(action: {}) {
                            Label("Turn off notifications from \(data.userName)", image: "notifications-cross-outline")
                        }
                    } label: {
                        FDSIconButton(icon: "dots-3-horizontal-outline", action: {})
                    }
                }

                if data.type == .friendRequest, let confirmAction = onConfirm {
                    HStack(spacing: 8) {
                        FDSButton(
                            type: .primary,
                            label: "Confirm",
                            size: .medium,
                            widthMode: .flexible,
                            action: confirmAction
                        )

                        FDSButton(
                            type: .secondary,
                            label: "Delete",
                            size: .medium,
                            widthMode: .flexible,
                            action: onDelete
                        )
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(minHeight: 72)
        .background(data.isUnread ? Color("accentDeemphasized") : Color("surfaceBackground"))
    }
}

#Preview {
    NotificationsTab()
        .environmentObject(FDSTabBarHelper())
        .environmentObject(DrawerStateManager())
}
