import SwiftUI

// MARK: - FDSBottomSheet Component

enum FDSBottomSheetContentStyle {
    case plain
    case card
}

struct FDSBottomSheet<Content: View, LeftAddOn: View, RightAddOn: View>: View {
    let title: String?
    let leftAddOn: LeftAddOn
    let rightAddOn: RightAddOn
    let content: Content
    let fitContent: Bool
    let contentStyle: FDSBottomSheetContentStyle
    
    @State private var contentHeight: CGFloat = 0
    
    init(
        title: String? = nil,
        fitContent: Bool = true,
        contentStyle: FDSBottomSheetContentStyle = .plain,
        @ViewBuilder leftAddOn: () -> LeftAddOn = { EmptyView() },
        @ViewBuilder rightAddOn: () -> RightAddOn = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.fitContent = fitContent
        self.contentStyle = contentStyle
        self.leftAddOn = leftAddOn()
        self.rightAddOn = rightAddOn()
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color("bottomSheetHandle"))
                .frame(width: 40, height: 4)
                .padding(.top, 8)
            
            // Optional header
            if let title = title {
                HStack(spacing: 16) {
                    leftAddOn
                        .frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    Text(title)
                        .headline3EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Spacer()
                    
                    rightAddOn
                        .frame(width: 44, height: 44)
                }
                .frame(height: 56)
                .padding(.horizontal, 12)
                .background(Color("bottomSheetBackgroundDeemphasized"))
            }
            
            // Content
            styledContent
            
            // Add spacer only when not fitting content
            if !fitContent {
                Spacer(minLength: 0)
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        if fitContent {
                            contentHeight = geometry.size.height
                        }
                    }
                    .onChange(of: geometry.size.height) { _, newHeight in
                        if fitContent {
                            contentHeight = newHeight
                        }
                    }
            }
        )
        .background(Color("bottomSheetBackgroundDeemphasized"))
        .presentationBackground(Color("bottomSheetBackgroundDeemphasized"))
        .presentationDragIndicator(.hidden)
        .presentationDetents(fitContent && contentHeight > 0 ? [.height(contentHeight)] : [])
    }
    
    @ViewBuilder
    private var styledContent: some View {
        switch contentStyle {
        case .plain:
            content
        case .card:
            content
                .padding(.vertical, 8)
                .background(Color("cardBackground"))
                .cornerRadius(12)
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
        }
    }
}

// MARK: - Extension for no add-ons

extension FDSBottomSheet where LeftAddOn == EmptyView, RightAddOn == EmptyView {
    init(
        title: String? = nil,
        fitContent: Bool = true,
        contentStyle: FDSBottomSheetContentStyle = .plain,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.fitContent = fitContent
        self.contentStyle = contentStyle
        self.leftAddOn = EmptyView()
        self.rightAddOn = EmptyView()
        self.content = content()
    }
}

// MARK: - Bottom Sheet Preview View

struct BottomSheetPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showBasicSheet = false
    @State private var showWithAddOnsSheet = false
    @State private var showCustomContentSheet = false
    @State private var showCustomHeightSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // AGENT RULES (not shown in UI):
            // - Bottom sheet is an interruptive overlay surface, NOT a feed unit
            // - Appears over a 50% dim backdrop covering the content underneath
            // - Has a drag handle at top, optional centered header with close/confirm buttons
            // - Content inside uses deemphasized background (#F2F3F5)
            // - Card style: inset content with 8dp corner radius, no hairlines
            // - Sizes: auto-height (fitContent: true) or custom detents
            // - Use .sheet() presentation — never embed inline in a view hierarchy

            FDSNavigationBarCentered(
                title: "Bottom Sheet",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    BottomSheetCard(title: "Card style sheet") {
                        FDSButton(
                            type: .primary,
                            label: "Show card style sheet",
                            action: {
                                showBasicSheet = true
                            }
                        )
                    }
                    
                    BottomSheetCard(title: "Sheet with header add-ons") {
                        FDSButton(
                            type: .primary,
                            label: "Show sheet with add-ons",
                            action: {
                                showWithAddOnsSheet = true
                            }
                        )
                    }
                    
                    BottomSheetCard(title: "Custom content (auto-sized)") {
                        FDSButton(
                            type: .primary,
                            label: "Show custom content",
                            action: {
                                showCustomContentSheet = true
                            }
                        )
                    }
                    
                    BottomSheetCard(title: "Custom height with fitContent: false") {
                        FDSButton(
                            type: .primary,
                            label: "Show custom height",
                            action: {
                                showCustomHeightSheet = true
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
        .sheet(isPresented: $showBasicSheet) {
            // Card style automatically adds padding, background, and corner radius
            FDSBottomSheet(title: "More options", contentStyle: .card) {
                VStack(spacing: 0) {
                    FDSListCell(
                        headlineText: "Refresh",
                        leftAddOn: .icon("refresh-left-outline", iconSize: 24),
                        action: {}
                    )
                    FDSListCell(
                        headlineText: "Share",
                        leftAddOn: .icon("share-outline", iconSize: 24),
                        action: {}
                    )
                    FDSListCell(
                        headlineText: "Save",
                        leftAddOn: .icon("bookmark-outline", iconSize: 24),
                        action: {}
                    )
                    FDSListCell(
                        headlineText: "Open in browser",
                        leftAddOn: .icon("globe-americas-outline", iconSize: 24),
                        action: {}
                    )
                }
            }
        }
        .sheet(isPresented: $showWithAddOnsSheet) {
            FDSBottomSheet(
                title: "Edit options",
                leftAddOn: {
                    FDSIconButton(icon: "cross-outline", action: { showWithAddOnsSheet = false })
                },
                rightAddOn: {
                    FDSIconButton(icon: "checkmark-outline", action: { showWithAddOnsSheet = false })
                }
            ) {
                VStack(spacing: 0) {
                    FDSListCell(
                        headlineText: "Cut",
                        leftAddOn: .icon("scissors-outline", iconSize: 24),
                        action: {}
                    )
                    FDSListCell(
                        headlineText: "Copy",
                        leftAddOn: .icon("copy-outline", iconSize: 24),
                        action: {}
                    )
                    FDSListCell(
                        headlineText: "Paste",
                        leftAddOn: .icon("copy-filled", iconSize: 24),
                        action: {}
                    )
                }
                .padding(.vertical, 8)
                .background(Color("cardBackground"))
                .cornerRadius(12)
                .padding(.bottom, 12)
                .padding(.horizontal, 12)
            }
        }
        .sheet(isPresented: $showCustomContentSheet) {
            FDSBottomSheet(title: "Custom content") {
                VStack(spacing: 16) {
                    Text("This is custom content")
                        .headline3Typography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Text("You can put any SwiftUI view here, not just FDSListCells. The sheet automatically sizes to fit!")
                        .body2Typography()
                        .foregroundStyle(Color("secondaryText"))
                        .multilineTextAlignment(.center)
                    
                    FDSButton(
                        type: .primary,
                        label: "Got it",
                        action: {
                            showCustomContentSheet = false
                        }
                    )
                }
                .padding(12)
            }
        }
        .sheet(isPresented: $showCustomHeightSheet) {
            // Set fitContent: false to use custom presentationDetents
            FDSBottomSheet(fitContent: false) {
                VStack(spacing: 16) {
                    Spacer()
                    Text("Custom heights")
                        .headline2EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                    
                    Text("This sheet uses fitContent: false and manually sets .presentationDetents([.medium, .large])")
                        .body2Typography()
                        .foregroundStyle(Color("secondaryText"))
                        .multilineTextAlignment(.center)
                    
                    FDSButton(
                        type: .secondary,
                        label: "Close",
                        action: {
                            showCustomHeightSheet = false
                        }
                    )
                    Spacer()
                }
                .padding(12)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

// MARK: - Bottom Sheet Card Component

fileprivate struct BottomSheetCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .meta4LinkTypography()
                .foregroundStyle(Color("primaryText"))
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color("cardBackground"))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("borderUiEmphasis"), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    BottomSheetPreviewView()
}

