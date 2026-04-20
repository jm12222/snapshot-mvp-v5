import SwiftUI

// MARK: - Constants

private let INPUT_FIELD_PADDING: CGFloat = 12
private let LABEL_INPUT_GAP: CGFloat = 0 // Gap between pinned label and text input

// MARK: - FDSTextInput Right Add-On Types

enum FDSTextInputRightAddOn {
    case icon(name: String, accessibilityLabel: String? = nil)
    case iconButton(name: String, action: () -> Void, accessibilityLabel: String)
    case custom(content: AnyView)
}

enum FDSTextInputValidationState {
    case `default`
    case error
    case success
}

// MARK: - FDSTextInput

struct FDSTextInput: View {
    // Required
    let label: String
    
    // Optional
    let hintText: String?
    let placeholderText: String?
    let rightAddOn: FDSTextInputRightAddOn?
    let validationState: FDSTextInputValidationState
    let isDisabled: Bool
    let isSecure: Bool
    let minLines: Int?
    let maxLines: Int?
    
    // Binding
    @Binding var text: String
    
    // Internal state
    @FocusState private var isFocused: Bool
    
    init(
        label: String,
        text: Binding<String>,
        hintText: String? = nil,
        initialText: String? = nil,
        placeholderText: String? = nil,
        rightAddOn: FDSTextInputRightAddOn? = nil,
        validationState: FDSTextInputValidationState = .default,
        isDisabled: Bool = false,
        isSecure: Bool = false,
        minLines: Int? = nil,
        maxLines: Int? = nil
    ) {
        self.label = label
        self._text = text
        self.hintText = hintText
        self.placeholderText = placeholderText
        self.rightAddOn = rightAddOn
        self.validationState = validationState
        self.isDisabled = isDisabled
        self.isSecure = isSecure
        self.minLines = minLines
        self.maxLines = maxLines
        
        // Set initial text if provided
        if let initialText = initialText, text.wrappedValue.isEmpty {
            self._text = text
            DispatchQueue.main.async {
                text.wrappedValue = initialText
            }
        }
    }
    
    private var isLabelPinned: Bool {
        isFocused || !text.isEmpty
    }
    
    private var isMultiLine: Bool {
        // Use TextEditor only when explicitly requesting multiple lines
        (minLines ?? 1) > 1 || (maxLines ?? 1) > 1
    }
    
    private var borderColor: Color {
        if isDisabled {
            return Color("divider") // Visible border for disabled state
        }
        
        switch validationState {
        case .error:
            return Color("negative") // Always full red for error state
        case .success, .default:
            return isFocused ? Color("accentColor") : Color("divider")
        }
    }
    
    private var outlineColor: Color {
        if isDisabled {
            return Color.clear
        }
        
        switch validationState {
        case .error:
            return isFocused ? Color("negativeDeemphasized") : Color.clear
        case .success, .default:
            return isFocused ? Color("accentDeemphasized") : Color.clear
        }
    }
    
    private var labelColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        
        switch validationState {
        case .error:
            return Color("negative")
        case .success, .default:
            return isFocused ? Color("accentColor") : Color("secondaryText")
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return Color("disabledText")
        }
        return Color("primaryText")
    }
    
    private var validationIcon: String? {
        switch validationState {
        case .error:
            return "caution-circle-filled"
        case .success:
            return "checkmark-circle-filled"
        case .default:
            return nil
        }
    }
    
    private var validationIconColor: Color {
        switch validationState {
        case .error:
            return Color("negative")
        case .success:
            return Color("positive")
        case .default:
            return Color.clear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Input field container
            ZStack(alignment: .topLeading) {
                // Outer border layer (lighter color)
                RoundedRectangle(cornerRadius: 14)
                    .fill(outlineColor)
                    .padding(-2)
                
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color("cardBackgroundFlat") : Color("surfaceBackground"))
                
                // Inner border (darker color)
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(borderColor, lineWidth: 1)
                
                // Content
                HStack(alignment: .center, spacing: 8) {
                    // Label and text input
                    ZStack(alignment: .topLeading) {
                        // Text input container - always present to maintain height
                        VStack(alignment: .leading, spacing: 0) {
                            if isLabelPinned || isMultiLine {
                                Spacer()
                                    .frame(height: 16 + LABEL_INPUT_GAP)
                            }
                            
                            // Text input area
                            ZStack(alignment: .topLeading) {
                                if isFocused, let placeholder = placeholderText {
                                    Text(placeholder)
                                        .body2Typography()
                                        .foregroundStyle(Color("placeholderTextDefault"))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.top, isMultiLine ? 8 : 0) // Match TextField's internal vertical centering
                                        .opacity(text.isEmpty ? 1 : 0)
                                        .allowsHitTesting(false)
                                }
                                
                                // Use TextField for single-line, TextEditor for multi-line
                                if isMultiLine {
                                    TextEditor(text: $text)
                                        .body2Typography()
                                        .foregroundStyle(textColor)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .frame(minHeight: calculateMinHeight(), maxHeight: calculateMaxHeight())
                                        .scrollDisabled(shouldDisableScroll())
                                        .focused($isFocused)
                                        .disabled(isDisabled)
                                        .padding(.horizontal, -5)
                                } else if isSecure {
                                    SecureField("", text: $text)
                                        .body2Typography()
                                        .foregroundStyle(textColor)
                                        .focused($isFocused)
                                        .disabled(isDisabled)
                                } else {
                                    TextField("", text: $text)
                                        .body2Typography()
                                        .foregroundStyle(textColor)
                                        .focused($isFocused)
                                        .disabled(isDisabled)
                                }
                            }
                         }
                         .frame(minHeight: 40)
                         
                         floatingLabel
                             .offset(y: isLabelPinned ? 4 : (isMultiLine ? 4 : 14))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Right side add-ons
                    HStack(spacing: 8) {
                        // Validation icon
                        if let iconName = validationIcon {
                            Image(iconName)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(validationIconColor)
                        }
                        
                        // Right add-on
                        if let addOn = rightAddOn {
                            switch addOn {
                            case .icon(let name, _):
                                Image(name)
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(isDisabled ? Color("disabledIcon") : Color("secondaryIcon"))
                                    
                            case .iconButton(let name, let action, _):
                                FDSIconButton(
                                    icon: name,
                                    size: .size20,
                                    color: .secondary,
                                    action: action
                                )
                                .disabled(isDisabled)
                                    
                            case .custom(let content):
                                content
                            }
                        }
                    }
                }
                .padding(INPUT_FIELD_PADDING)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !isDisabled {
                    isFocused = true
                }
            }
            
            // Hint text
            if let hint = hintText {
                Text(hint)
                    .meta3Typography()
                    .foregroundStyle(isDisabled ? Color("disabledText") : Color("secondaryText"))
            }
        }
        .frame(minWidth: 172)
    }
    
    // MARK: - Floating Label View
    
    @ViewBuilder
    private var floatingLabel: some View {
        // Single text view that scales smoothly
        // Body2 = 15pt, Meta3 = 12pt, scale factor = 12/15 = 0.8
        Text(label)
            .body2Typography()
            .foregroundStyle(labelColor)
            .fixedSize(horizontal: false, vertical: true)
            .scaleEffect(isLabelPinned ? 0.8 : 1.0, anchor: .topLeading) // Transform origin: Top, Left
            .background(
                // Add background when pinned to prevent text showing through during scroll
                isLabelPinned ? (isDisabled ? Color("cardBackgroundFlat") : Color("surfaceBackground")) : Color.clear
            )
            // Position/scale animation: moveIn when pinning, moveOut when unpinning
            .animation(
                isLabelPinned
                    ? .moveIn(MotionDuration.extraExtraShortIn)    // Entering focus: 100ms
                    : .moveOut(MotionDuration.extraExtraShortOut), // Leaving focus without value: 100ms
                value: isLabelPinned
            )
            // Color animation: fadeIn when label is pinned (stays in place), otherwise match position animation
            .animation(
                isLabelPinned
                    ? .fadeIn(MotionDuration.extraExtraShortIn)    // Leaving focus with value: 100ms (color only)
                    : .moveOut(MotionDuration.extraExtraShortOut), // Leaving focus without value: 100ms
                value: labelColor
            )
    }
    
    // MARK: - Helper Methods
    
    private func calculateMinHeight() -> CGFloat {
        let lineHeight: CGFloat = 20 // Body2 line height
        
        if let minLines = minLines {
            return CGFloat(minLines) * lineHeight
        }
        
        return lineHeight
    }
    
    private func calculateMaxHeight() -> CGFloat? {
        guard let maxLines = maxLines else {
            return nil
        }
        
        let lineHeight: CGFloat = 20 // Body2 line height
        return CGFloat(maxLines) * lineHeight
    }
    
    private func shouldDisableScroll() -> Bool {
        // Disable scrolling when there's no maxLines constraint
        return maxLines == nil
    }
}

// MARK: - Text Input Group Card Component
struct TextInputGroupCard<Content: View>: View {
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

// MARK: - Text Inputs Preview View
struct TextInputsPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Basic
    @State private var basicEmail = ""
    @State private var basicName = "Jane Smith"
    
    // Placeholder
    @State private var searchText = ""
    
    // Hint text
    @State private var hintPassword = ""
    @State private var hintUsername = "johndoe"
    
    // Validation
    @State private var validationEmail = "invalid-email"
    @State private var validationUsername = "johndoe"
    
    // Right add-ons
    @State private var searchWithIcon = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var emailWithClear = "test@example.com"
    
    // Disabled
    @State private var disabledEmail = ""
    @State private var disabledName = "Jane Smith"
    @State private var disabledUsername = "johndoe"
    
    // Min/max lines
    @State private var minLinesComment = ""
    @State private var maxLinesBio = "This is a very long bio that contains multiple lines of text. It should scroll when it exceeds the maximum number of lines that we've set for this input field."
    @State private var minMaxDescription = "Short text"
    
    // Interactive
    @State private var email = ""
    @State private var comment = ""
    
    var emailValidation: FDSTextInputValidationState {
        if email.isEmpty {
            return .default
        }
        return email.contains("@") ? .success : .error
    }
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSTextInput",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    TextInputGroupCard(title: "Basic") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Email",
                                text: $basicEmail
                            )
                            
                            FDSTextInput(
                                label: "Name",
                                text: $basicName
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "With placeholder text") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Search",
                                text: $searchText,
                                placeholderText: "Type to search..."
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "With hint text") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Password",
                                text: $hintPassword,
                                hintText: "Must be at least 8 characters",
                                isSecure: true
                            )
                            
                            FDSTextInput(
                                label: "Username",
                                text: $hintUsername,
                                hintText: "This will be visible to everyone"
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "Validation states") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Email",
                                text: $validationEmail,
                                hintText: "Please enter a valid email address",
                                validationState: .error
                            )
                            
                            FDSTextInput(
                                label: "Username",
                                text: $validationUsername,
                                hintText: "Username is available",
                                validationState: .success
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "Right add-ons") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Search",
                                text: $searchWithIcon,
                                rightAddOn: .icon(name: "magnifying-glass-outline", accessibilityLabel: "Search")
                            )
                            
                            FDSTextInput(
                                label: "Password",
                                text: $password,
                                rightAddOn: .iconButton(
                                    name: showPassword ? "eye-cross-outline" : "eye-outline",
                                    action: { showPassword.toggle() },
                                    accessibilityLabel: showPassword ? "Hide password" : "Show password"
                                ),
                                isSecure: !showPassword
                            )
                            
                            FDSTextInput(
                                label: "Email",
                                text: $emailWithClear,
                                rightAddOn: .iconButton(
                                    name: "cross-outline",
                                    action: { emailWithClear = "" },
                                    accessibilityLabel: "Clear"
                                ),
                                validationState: .success
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "Disabled state") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Email",
                                text: $disabledEmail,
                                isDisabled: true
                            )
                            
                            FDSTextInput(
                                label: "Name",
                                text: $disabledName,
                                hintText: "This field cannot be edited",
                                isDisabled: true
                            )
                            
                            FDSTextInput(
                                label: "Username",
                                text: $disabledUsername,
                                rightAddOn: .iconButton(
                                    name: "cross-outline",
                                    action: {},
                                    accessibilityLabel: "Clear"
                                ),
                                validationState: .error,
                                isDisabled: true
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "Min/max lines") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Comment",
                                text: $minLinesComment,
                                placeholderText: "Write your comment here...",
                                minLines: 3
                            )
                            
                            FDSTextInput(
                                label: "Bio",
                                text: $maxLinesBio,
                                maxLines: 2
                            )
                            
                            FDSTextInput(
                                label: "Description",
                                text: $minMaxDescription,
                                hintText: "This field has a minimum of 4 lines",
                                minLines: 4,
                                maxLines: 6
                            )
                        }
                    }
                    
                    TextInputGroupCard(title: "Interactive demo") {
                        VStack(spacing: 12) {
                            FDSTextInput(
                                label: "Email",
                                text: $email,
                                hintText: email.isEmpty ? nil : (emailValidation == .error ? "Please enter a valid email" : "Email is valid"),
                                placeholderText: "Enter your email",
                                validationState: emailValidation
                            )
                            
                            FDSTextInput(
                                label: "Comment",
                                text: $comment,
                                placeholderText: "What's on your mind?",
                                minLines: 3,
                                maxLines: 5
                            )
                        }
                    }
                }
                .padding()
            }
            .background(Color("surfaceBackground"))
        }
    }
}

// MARK: - Preview
#Preview {
    TextInputsPreviewView()
}

