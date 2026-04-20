import SwiftUI

// MARK: - FDSProfilePhoto

struct FDSProfilePhoto: View {
    var imageName: String
    var size: CGFloat = 40
    var layout: Layout = .circle
    var ringType: RingType = .none
    var addOn: AddOn?
    var action: (() -> Void)?

    enum Layout {
        case circle, square
    }

    enum RingType {
        case none, unread, read, live, closeFriend

        var color: Color {
            switch self {
            case .none: return .clear
            case .unread: return Color("accentColor")
            case .read: return Color("secondaryIcon")
            case .live: return Color("live")
            case .closeFriend: return Color("positive")
            }
        }
    }

    enum AddOn {
        case availability(isAvailable: Bool = true)
        case activity(iconName: String, backgroundColor: Color)
        case nonActorBadge(imageName: String)
    }

    private var cornerRadius: CGFloat {
        switch layout {
        case .circle: return size / 2
        case .square:
            if size <= 40 { return 6 }
            if size <= 72 { return 10 }
            return 14
        }
    }

    private var ringBorderWidth: CGFloat {
        size <= 72 ? 3 : 4
    }

    private var hasRing: Bool {
        ringType != .none
    }

    private var addOnSize: CGFloat {
        guard let addOn else { return 0 }
        switch addOn {
        case .availability:
            return size <= 40 ? 12 : 16
        case .activity:
            if size <= 32 { return 16 }
            if size <= 60 { return 20 }
            if size <= 96 { return 24 }
            return 28
        case .nonActorBadge:
            let sizeMap: [CGFloat: CGFloat] = [32: 20, 40: 24, 52: 28, 60: 32, 72: 36, 96: 60]
            return sizeMap[size] ?? 24
        }
    }

    var body: some View {
        let totalSize = hasRing ? size + (ringBorderWidth + ringBorderWidth) * 2 : size

        ZStack(alignment: .bottomTrailing) {
            // Ring + photo
            ZStack {
                if hasRing {
                    RoundedRectangle(cornerRadius: layout == .circle ? totalSize / 2 : cornerRadius + ringBorderWidth)
                        .stroke(ringType.color, lineWidth: ringBorderWidth)
                        .frame(width: totalSize, height: totalSize)
                }

                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }

            // Add-on badge
            if let addOn {
                addOnBadge(addOn)
                    .offset(x: 2, y: 2)
            }
        }
        .frame(width: totalSize, height: totalSize)
    }

    @ViewBuilder
    private func addOnBadge(_ addOn: AddOn) -> some View {
        let badgeSize = addOnSize

        switch addOn {
        case .availability(let isAvailable):
            Circle()
                .fill(isAvailable ? Color("positive") : Color("secondaryIcon"))
                .frame(width: badgeSize, height: badgeSize)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )

        case .activity(let iconName, let backgroundColor):
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: badgeSize, height: badgeSize)
                Image(iconName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.white)
                    .frame(width: badgeSize * 0.6, height: badgeSize * 0.6)
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )

        case .nonActorBadge(let badgeImageName):
            Image(badgeImageName)
                .resizable()
                .scaledToFill()
                .frame(width: badgeSize, height: badgeSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
        }
    }
}


// MARK: - Preview

struct ProfilePhotoPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(title: "Profile Photo", backAction: { dismiss() })

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    FDSUnitHeader(headlineText: "Sizes")
                    HStack(spacing: 16) {
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 24)
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 32)
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 40)
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 60)
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 72)
                    }
                    .padding(.horizontal, 16)

                    FDSUnitHeader(headlineText: "Square (non-actor)")
                    HStack(spacing: 16) {
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 40, layout: .square)
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, layout: .square)
                        FDSProfilePhoto(imageName: "sample-avatar-1", size: 72, layout: .square)
                    }
                    .padding(.horizontal, 16)

                    FDSUnitHeader(headlineText: "Ring types")
                    HStack(spacing: 16) {
                        VStack {
                            FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, ringType: .unread)
                            Text("Unread").font(.caption).foregroundStyle(.secondary)
                        }
                        VStack {
                            FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, ringType: .read)
                            Text("Read").font(.caption).foregroundStyle(.secondary)
                        }
                        VStack {
                            FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, ringType: .live)
                            Text("Live").font(.caption).foregroundStyle(.secondary)
                        }
                        VStack {
                            FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, ringType: .closeFriend)
                            Text("Close").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)

                    FDSUnitHeader(headlineText: "Add-ons")
                    HStack(spacing: 16) {
                        VStack {
                            FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, addOn: .availability())
                            Text("Available").font(.caption).foregroundStyle(.secondary)
                        }
                        VStack {
                            FDSProfilePhoto(imageName: "sample-avatar-1", size: 60, addOn: .availability(isAvailable: false))
                            Text("Away").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color("surfaceBackground"))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    ProfilePhotoPreviewView()
}
