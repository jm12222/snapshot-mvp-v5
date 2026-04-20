import UIKit
import SwiftUI

// MARK: - Status Bar Double-Tap Detection
// Places an invisible tap target over the status bar area (top 44pt of screen).
// Double-tap triggers the Demo Mode picker from any screen.

class StatusBarTapWindow: UIWindow {
    private var lastTapTime: TimeInterval = 0
    private let doubleTapInterval: TimeInterval = 0.4

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)

        // Position over status bar area only
        let statusBarHeight: CGFloat = 44
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: statusBarHeight)
        self.windowLevel = .statusBar + 1
        self.backgroundColor = .clear
        self.isHidden = false
        self.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTap() {
        let now = CACurrentMediaTime()
        if now - lastTapTime < doubleTapInterval {
            // Double tap detected
            lastTapTime = 0
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            NotificationCenter.default.post(name: .statusBarDoubleTapped, object: nil)
        } else {
            lastTapTime = now
        }
    }

    // Pass through all touches so the status bar still works normally for scroll-to-top
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Only intercept taps, let everything else pass through
        return self
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
}

extension Notification.Name {
    static let statusBarDoubleTapped = Notification.Name("statusBarDoubleTapped")
}

// MARK: - Setup

class StatusBarTapSetup {
    static let shared = StatusBarTapSetup()
    private var tapWindow: StatusBarTapWindow?
    private var hasSetup = false

    private init() {}

    func setup() {
        guard !hasSetup else { return }
        hasSetup = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            self.tapWindow = StatusBarTapWindow(windowScene: scene)
        }
    }
}

// MARK: - SwiftUI Modifier

struct StatusBarDoubleTapModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .statusBarDoubleTapped)) { _ in
                action()
            }
    }
}

extension View {
    func onStatusBarDoubleTap(perform action: @escaping () -> Void) -> some View {
        modifier(StatusBarDoubleTapModifier(action: action))
    }
}
