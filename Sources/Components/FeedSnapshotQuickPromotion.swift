import SwiftUI

// MARK: - Feed Snapshot Quick Promotion
//
// Quick promotion (QP) entry point that lives in the main Home feed and
// re-opens the "Today's snapshot" landing. Spec mirrors the Figma frame
// "QP - Simple" (file dPCTtNCUVZX7Vh21x8iRDB, node 284:32537):
//   • Header (40h, 12pt horizontal): app-facebook-circle on the left,
//     dots-3-horizontal + cross on the right (gap 16)
//   • Centered keyart media (~109h tall, fixed-aspect "feed-qp-snapshot-keyart")
//   • Center-aligned text pairing: H3 emphasized headline + body3 secondary
//     (gap 10, 4/12/4/12 padding)
//   • Full-width primary "Open snapshot" CTA (FDSButton primary, large)
// Whole card uses `surfaceBackground` and a Separator above to match the
// surrounding Feed post rhythm.
struct FeedSnapshotQuickPromotion: View {
    @EnvironmentObject private var drawerState: DrawerStateManager
    @State private var dismissed: Bool = false

    var body: some View {
        if !dismissed {
            VStack(spacing: 0) {
                Separator()
                qpBody
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }

    private var qpBody: some View {
        VStack(spacing: 0) {
            promotionHeader

            // Media (keyart). The Figma frame fixes height at ~109pt; the
            // attached keyart is wider than tall, so we cap height and let
            // it scale-to-fit horizontally on a transparent background.
            keyartMedia
                .padding(.bottom, 4)

            VStack(spacing: 10) {
                Text("Your snapshot is ready")
                    .headline3EmphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .multilineTextAlignment(.center)

                Text("Get a daily update about the things care about, all in one place.")
                    .body3Typography()
                    .foregroundStyle(Color("secondaryText"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 12)

            FDSButton(
                type: .primary,
                label: "Open snapshot",
                size: .large,
                widthMode: .flexible,
                action: { drawerState.showSnapshot() }
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
        .contentShape(Rectangle())
        .onTapGesture {
            drawerState.showSnapshot()
        }
    }

    // MARK: - Subviews

    private var promotionHeader: some View {
        HStack(spacing: 8) {
            Image("app-facebook-circle-filled")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 24, height: 24)

            Spacer()

            FDSIconButton(icon: "dots-3-horizontal", size: .size20, color: .secondary, action: {})
            FDSIconButton(icon: "nav-cross", size: .size20, color: .secondary, action: {
                withAnimation(.swapShuffleOut(MotionDuration.shortOut)) {
                    dismissed = true
                }
            })
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
    }

    private var keyartMedia: some View {
        // Keyart is provided as a single PNG of three tilted snapshot cards
        // on a transparent background. We center it inside a fixed-height
        // band so the QP stays a predictable size regardless of device width.
        Image("feed-qp-snapshot-keyart")
            .resizable()
            .scaledToFit()
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
    }
}

#Preview {
    VStack(spacing: 0) {
        FeedSnapshotQuickPromotion()
            .environmentObject(DrawerStateManager())
        Spacer()
    }
    .background(Color("wash"))
}
