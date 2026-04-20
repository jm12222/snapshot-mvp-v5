import SwiftUI
import WebKit

// MARK: - WebView Navigator

class WebViewNavigator: ObservableObject {
    weak var webView: WKWebView?
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
}

// MARK: - IAB View (In-App Browser)

struct IABView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var historyStore = LinkHistoryStore.shared
    @State private var isTabBarVisible = true
    @State private var isNavBarCondensed = false
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var webViewNavigator: WebViewNavigator?
    @State private var showHistory = false
    @State private var isReaderModeEnabled = false
    @State private var loadingProgress: Double = 0.0
    @State private var isLoading = false
    @State private var currentPageTitle: String = ""
    @State private var currentURL: URL?
    @State private var showMoreOptions = false
    @State private var showBrowserSettings = false
    
    let url: URL
    let pageTitle: String
    
    init(url: URL, pageTitle: String = "Facebook") {
        self.url = url
        self.pageTitle = pageTitle
        self._currentPageTitle = State(initialValue: pageTitle)
        self._currentURL = State(initialValue: url)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
            
            // Progress Bar
            if isLoading {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color("accentColor"))
                        .frame(width: geometry.size.width * loadingProgress, height: 3)
                }
                .frame(height: 3)
                .animation(.linear(duration: MotionDuration.extraShortIn), value: loadingProgress)
            }
            
            WebView(
                url: url,
                isTabBarVisible: $isTabBarVisible,
                isNavBarCondensed: $isNavBarCondensed,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                webViewNavigator: $webViewNavigator,
                currentPageTitle: $currentPageTitle,
                currentURL: $currentURL,
                historyStore: historyStore,
                isReaderModeEnabled: $isReaderModeEnabled,
                loadingProgress: $loadingProgress,
                isLoading: $isLoading
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            bottomTabBar
        }
        .background(Color("surfaceBackground"))
        .edgesIgnoringSafeArea(.bottom)
        .hideFDSTabBar(true)
        .navigationDestination(isPresented: $showHistory) {
            LinkHistoryView { urlString in
                if let url = URL(string: urlString) {
                    showHistory = false
                    // Navigate to the selected URL
                    webViewNavigator?.webView?.load(URLRequest(url: url))
                }
            }
        }
        .navigationDestination(isPresented: $showBrowserSettings) {
            BrowserSettingsView()
        }
        .sheet(isPresented: $showMoreOptions) {
            MoreOptionsSheetView(
                onRefresh: {
                    webViewNavigator?.webView?.reload()
                },
                onShare: {
                    // Handle share action
                },
                onSave: {
                    // Handle save action
                },
                onViewSavedItems: {
                    // Handle view saved items action
                },
                onOpenInBrowser: {
                    if let url = currentURL {
                        UIApplication.shared.open(url)
                    }
                },
                onMarkAsSuspicious: {
                    // Handle mark as suspicious action
                },
                onGoToSettings: {
                    showBrowserSettings = true
                }
            )
        }
    }
    
    // MARK: - Navigation Bar
    
    private var navigationBar: some View {
        VStack(spacing: 0) {
            if isNavBarCondensed {
                // Condensed state - only URL
                HStack(spacing: 4) {
                    Image("privacy-filled")
                        .resizable()
                        .foregroundStyle(Color("secondaryIcon"))
                        .frame(width: 12, height: 12)
                    
                    Text(url.host ?? url.absoluteString)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryText"))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .padding(.horizontal, 12)
                .background(Color("surfaceBackground"))
            } else {
                // Default state - full navigation bar
                HStack(spacing: 16) {
                    // Back button
                    FDSIconButton(
                        icon: "chevron-left-outline",
                        size: .size24,
                        action: { dismiss() }
                    )
                    
                    // Title and URL - Centered
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            Image("privacy-filled")
                                .resizable()
                                .foregroundStyle(Color("secondaryIcon"))
                                .frame(width: 12, height: 12)
                            
                            
                            Text(url.host ?? url.absoluteString)
                                .headline4Typography()
                                .foregroundStyle(Color("primaryText"))
                                .lineLimit(1)
                        }
                        
                        Text(currentPageTitle)
                            .meta4Typography()
                            .foregroundStyle(Color("secondaryText"))
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    
                    // More button with menu
                    FDSIconButton(
                        icon: "dots-3-horizontal-filled",
                        action: {
                            showMoreOptions = true
                        }
                    )
                }
                .padding(.horizontal, 12)
                .frame(height: 52)
                .background(Color("surfaceBackground"))
            }
            
            // Divider
            Rectangle()
                .fill(Color("divider"))
                .frame(height: 0.5)
        }
        .animation(.swapShuffleOut(MotionDuration.shortOut), value: isNavBarCondensed)
    }
    
    // MARK: - Bottom Tab Bar
    
    private var bottomTabBar: some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color("divider"))
                .frame(height: 0.5)
            
            HStack(spacing: 8) {
                FDSIconButton(
                    icon: "arrow-left-outline",
                    action: {
                        webViewNavigator?.goBack()
                    }
                )
                .disabled(!canGoBack)
                .opacity(canGoBack ? 1.0 : 0.4)
                .frame(maxWidth: .infinity)
                
                FDSIconButton(
                    icon: "arrow-right-outline",
                    action: {
                        webViewNavigator?.goForward()
                    }
                )
                .disabled(!canGoForward)
                .opacity(canGoForward ? 1.0 : 0.4)
                .frame(maxWidth: .infinity)
                
                FDSIconButton(icon: "share-outline", action: {})
                    .frame(maxWidth: .infinity)
                
                FDSIconButton(icon: "on-this-day-outline", action: {
                    showHistory = true
                })
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            .frame(height: 48)
            .background(Color("surfaceBackground"))
        }
        .padding(.bottom, 24)
        .frame(height: isTabBarVisible ? bottomTabBarVisibleHeight : 0)
        .clipped()
        .animation(.swapShuffleOut(MotionDuration.shortOut), value: isTabBarVisible)
    }
    
    private var bottomTabBarVisibleHeight: CGFloat {
        48 + 0.5 + 24
    }
}

// MARK: - WebView

fileprivate struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var isTabBarVisible: Bool
    @Binding var isNavBarCondensed: Bool
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var webViewNavigator: WebViewNavigator?
    @Binding var currentPageTitle: String
    @Binding var currentURL: URL?
    let historyStore: LinkHistoryStore
    @Binding var isReaderModeEnabled: Bool
    @Binding var loadingProgress: Double
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.delegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        
        // Add KVO observer for loading progress
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        webView.load(URLRequest(url: url))
        
        // Set up navigator
        DispatchQueue.main.async {
            let navigator = WebViewNavigator()
            navigator.webView = webView
            self.webViewNavigator = navigator
            
            // Initial state check
            self.canGoBack = webView.canGoBack
            self.canGoForward = webView.canGoForward
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Toggle reader mode when state changes
        if context.coordinator.isReaderModeEnabled != isReaderModeEnabled {
            context.coordinator.isReaderModeEnabled = isReaderModeEnabled
            context.coordinator.toggleReaderMode(webView: webView, enabled: isReaderModeEnabled)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            isTabBarVisible: $isTabBarVisible,
            isNavBarCondensed: $isNavBarCondensed,
            canGoBack: $canGoBack,
            canGoForward: $canGoForward,
            currentPageTitle: $currentPageTitle,
            currentURL: $currentURL,
            historyStore: historyStore,
            isReaderModeEnabled: isReaderModeEnabled,
            loadingProgress: $loadingProgress,
            isLoading: $isLoading
        )
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate, WKNavigationDelegate {
        @Binding var isTabBarVisible: Bool
        @Binding var isNavBarCondensed: Bool
        @Binding var canGoBack: Bool
        @Binding var canGoForward: Bool
        @Binding var currentPageTitle: String
        @Binding var currentURL: URL?
        let historyStore: LinkHistoryStore
        var isReaderModeEnabled: Bool
        @Binding var loadingProgress: Double
        @Binding var isLoading: Bool
        private var lastContentOffset: CGFloat = 0
        private let threshold: CGFloat = 5.0
        
        init(
            isTabBarVisible: Binding<Bool>,
            isNavBarCondensed: Binding<Bool>,
            canGoBack: Binding<Bool>,
            canGoForward: Binding<Bool>,
            currentPageTitle: Binding<String>,
            currentURL: Binding<URL?>,
            historyStore: LinkHistoryStore,
            isReaderModeEnabled: Bool,
            loadingProgress: Binding<Double>,
            isLoading: Binding<Bool>
        ) {
            self._isTabBarVisible = isTabBarVisible
            self._isNavBarCondensed = isNavBarCondensed
            self._canGoBack = canGoBack
            self._canGoForward = canGoForward
            self._currentPageTitle = currentPageTitle
            self._currentURL = currentURL
            self.historyStore = historyStore
            self.isReaderModeEnabled = isReaderModeEnabled
            self._loadingProgress = loadingProgress
            self._isLoading = isLoading
        }
        
        // MARK: - UIScrollViewDelegate
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let currentOffset = scrollView.contentOffset.y
            let delta = currentOffset - lastContentOffset
            
            // Only respond to significant scroll changes
            guard abs(delta) > threshold else { return }
            
            // At the very top of the page - show everything in default state
            guard currentOffset > 50 else {
                withAnimation {
                    isTabBarVisible = true
                    isNavBarCondensed = false
                }
                lastContentOffset = currentOffset
                return
            }
            
            // Scrolling down - condense nav bar and hide tab bar
            if delta > 0 {
                withAnimation {
                    isNavBarCondensed = true
                    isTabBarVisible = false
                }
            }
            // Scrolling up - expand nav bar and show tab bar
            else if delta < 0 {
                withAnimation {
                    isNavBarCondensed = false
                    isTabBarVisible = true
                }
            }
            
            lastContentOffset = currentOffset
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // Check navigation state as soon as navigation starts
            updateNavigationState(webView)
            
            // Start loading
            DispatchQueue.main.async {
                self.isLoading = true
                self.loadingProgress = 0.0
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // Check navigation state when content starts to load
            updateNavigationState(webView)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Check navigation state when page finishes loading
            updateNavigationState(webView)
            
            // Complete loading
            DispatchQueue.main.async {
                self.loadingProgress = 1.0
                
                // Hide progress bar after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isLoading = false
                    self.loadingProgress = 0.0
                }
            }
            
            // Track page visit and update current page info
            if let url = webView.url {
                let title = webView.title ?? url.host ?? url.absoluteString
                
                DispatchQueue.main.async {
                    self.currentPageTitle = title
                    self.currentURL = url
                    self.historyStore.addItem(url: url.absoluteString, title: title)
                }
            }
        }
        
        // MARK: - KVO Observer
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if keyPath == #keyPath(WKWebView.estimatedProgress) {
                DispatchQueue.main.async {
                    if let webView = object as? WKWebView {
                        self.loadingProgress = webView.estimatedProgress
                    }
                }
            }
        }
        
        deinit {
            // Remove observer when coordinator is deallocated
            // Note: This should be handled by the webview cleanup
        }
        
        private func updateNavigationState(_ webView: WKWebView) {
            DispatchQueue.main.async {
                self.canGoBack = webView.canGoBack
                self.canGoForward = webView.canGoForward
            }
        }
        
        // MARK: - Reader Mode
        
        func toggleReaderMode(webView: WKWebView, enabled: Bool) {
            if enabled {
                // Enable reader mode by injecting CSS to simplify the page
                let readerModeScript = """
                (function() {
                    // Create reader mode styles
                    var style = document.createElement('style');
                    style.id = 'reader-mode-styles';
                    style.textContent = `
                        body * {
                            visibility: hidden !important;
                        }
                        article, article *, 
                        main, main *,
                        .article, .article *,
                        .post-content, .post-content *,
                        .entry-content, .entry-content *,
                        [role="main"], [role="main"] * {
                            visibility: visible !important;
                        }
                        body {
                            background: #FFFFFF !important;
                            padding: 20px !important;
                            max-width: 700px !important;
                            margin: 0 auto !important;
                        }
                        article, main, .article, .post-content, .entry-content, [role="main"] {
                            background: #FFFFFF !important;
                            color: #000000 !important;
                            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif !important;
                            font-size: 18px !important;
                            line-height: 1.6 !important;
                        }
                        img {
                            max-width: 100% !important;
                            height: auto !important;
                        }
                        a {
                            color: #0066CC !important;
                        }
                    `;
                    document.head.appendChild(style);
                })();
                """
                webView.evaluateJavaScript(readerModeScript)
            } else {
                // Disable reader mode by removing the injected styles
                let disableScript = """
                (function() {
                    var style = document.getElementById('reader-mode-styles');
                    if (style) {
                        style.remove();
                    }
                })();
                """
                webView.evaluateJavaScript(disableScript)
            }
        }
    }
}

// MARK: - Browser Settings View

struct BrowserSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("linkHistoryEnabled") private var linkHistory = true
    @State private var enhancedBrowsing = true
    @State private var autofillForms = true
    @State private var autofillPaymentForms = true
    @State private var safeBrowsing = true
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "Browser settings",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Browsing data section
                    VStack(spacing: 0) {
                        FDSUnitHeader(
                            headlineText: "Browsing data"
                        )
                        
                        FDSListCell(
                            headlineText: "Cookies and cache",
                            rightAddOn: .button(
                                type: .secondary,
                                label: "Clear",
                                size: .medium,
                                action: {}
                            )
                        )
                        
                        FDSListCell(
                            headlineText: "Enhanced browsing",
                            rightAddOn: .toggle(isOn: $enhancedBrowsing)
                        )
                        .onChange(of: enhancedBrowsing) { oldValue, newValue in
                            linkHistory = newValue
                        }
                        
                        Text("Show link history, shopping recommendations, and other helpful features by using info from websites you browse. Meta may also use information from these features to improve your ads. About enhanced browsing")
                            .body3Typography()
                            .foregroundStyle(Color("secondaryText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                    }
                    
                    // Autofill section
                    VStack(spacing: 0) {
                        FDSUnitHeader(
                            headlineText: "Autofill"
                        )
                        
                        FDSListCell(
                            headlineText: "Contact info",
                            rightAddOn: .chevron,
                            action: {
                                // Navigate to contact info
                            }
                        )
                        
                        FDSListCell(
                            headlineText: "Autofill forms",
                            rightAddOn: .toggle(isOn: $autofillForms)
                        )
                        
                        FDSListCell(
                            headlineText: "Autofill payment forms",
                            rightAddOn: .toggle(isOn: $autofillPaymentForms)
                        )
                        
                        Text("Contact info used to quickly complete forms. Your autofill activity is used to improve ads and other parts of your Facebook experience. Learn more")
                            .body3Typography()
                            .foregroundStyle(Color("secondaryText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                    }
                    
                    // Safety section
                    VStack(spacing: 0) {
                        FDSUnitHeader(
                            headlineText: "Safety"
                        )
                        
                        FDSListCell(
                            headlineText: "Safe browsing",
                            rightAddOn: .toggle(isOn: $safeBrowsing)
                        )
                    }
                }
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
        .onAppear {
            // Sync enhanced browsing with link history state
            enhancedBrowsing = linkHistory
        }
    }
}

// MARK: - More Options Sheet

struct MoreOptionsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    var onRefresh: (() -> Void)?
    var onShare: (() -> Void)?
    var onSave: (() -> Void)?
    var onViewSavedItems: (() -> Void)?
    var onOpenInBrowser: (() -> Void)?
    var onMarkAsSuspicious: (() -> Void)?
    var onGoToSettings: (() -> Void)?
    
    var body: some View {
        FDSBottomSheet(title: "More options", contentStyle: .card) {
            VStack(spacing: 0) {
                FDSListCell(
                    headlineText: "Refresh",
                    leftAddOn: .icon("refresh-left-outline", iconSize: 24),
                    action: { handleAction(onRefresh) }
                )
                
                FDSListCell(
                    headlineText: "Share",
                    leftAddOn: .icon("share-outline", iconSize: 24),
                    action: { handleAction(onShare) }
                )
                
                FDSListCell(
                    headlineText: "Save",
                    leftAddOn: .icon("bookmark-outline", iconSize: 24),
                    action: { handleAction(onSave) }
                )
                
                FDSListCell(
                    headlineText: "View saved items",
                    leftAddOn: .icon("bookmark-stack-outline", iconSize: 24),
                    action: { handleAction(onViewSavedItems) }
                )
                
                FDSListCell(
                    headlineText: "Open in browser",
                    leftAddOn: .icon("globe-americas-outline", iconSize: 24),
                    action: { handleAction(onOpenInBrowser) }
                )
                
                FDSListCell(
                    headlineText: "Mark as suspicious",
                    leftAddOn: .icon("caution-circle-outline", iconSize: 24),
                    action: { handleAction(onMarkAsSuspicious) }
                )
                
                FDSListCell(
                    headlineText: "Go to settings",
                    leftAddOn: .icon("settings-outline", iconSize: 24),
                    action: { handleAction(onGoToSettings, delayed: true) }
                )
            }
        }
    }
    
    // MARK: - Helper
    
    private func handleAction(_ action: (() -> Void)?, delayed: Bool = false) {
        dismiss()
        if delayed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                action?()
            }
        } else {
            action?()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        IABView(
            url: URL(string: "https://www.meta.com")!,
            pageTitle: "Facebook"
        )
    }
    .environmentObject(FDSTabBarHelper())
}

