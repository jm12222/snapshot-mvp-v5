import SwiftUI

// MARK: - Messaging Lightweight Thread View

struct MessagingLightweightThreadView: View {
    let profile: ProfileData
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private var firstName: String {
        profile.name.components(separatedBy: " ").first ?? profile.name
    }
    
    private var suggestedMessages: [String] {
        [
            "Hello, \(firstName)!",
            "Hi, \(firstName)!",
            "Hey 👋",
            "Hey, how are you",
            "What's up?",
            "How's it going?"
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag handle - Fixed at top
            DragHandle()
            
            // Navigation bar - Fixed at top
            FDSNavigationBarMessaging(
                profileImage: profile.profileImage,
                name: profile.name,
                isActiveNow: profile.isActiveNow,
                closeAction: {
                    dismiss()
                },
                phoneAction: {},
                videoAction: {}
            )
            
            // Scrollable content area
            ScrollView {
                VStack(spacing: 0) {
                    // Entity header
                    EntityHeader(profile: profile, dismissAction: {
                        dismiss()
                    })
                    
                    // Spacer for empty thread
                    Spacer()
                        .frame(height: 400)
                }
            }
            
            // Suggested messages - Fixed at bottom
            SuggestedMessagesSection(messages: suggestedMessages)
            
            // Composer - Fixed at bottom
            MessagingComposer(messageText: $messageText, isTextFieldFocused: _isTextFieldFocused)
                .padding(.bottom, 32)
        }
        .background(Color("surfaceBackground"))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .ignoresSafeArea()
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Drag Handle

struct DragHandle: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 8)
            
            Capsule()
                .fill(Color("bottomSheetHandle"))
                .frame(width: 40, height: 4)
            
            Spacer()
                .frame(height: 0)
        }
        .frame(height: 12)
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Entity Header

struct EntityHeader: View {
    let profile: ProfileData
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Profile photo with story ring
            ZStack {
                // Story ring
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color("accentColor"), Color("accentColor").opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 100, height: 100)
                
                // Profile photo
                ZStack(alignment: .bottomTrailing) {
                    Image(profile.profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 88, height: 88)
                        .clipShape(Circle())
                    
                    // Active badge - only show if isActiveNow is true
                    if profile.isActiveNow {
                        Circle()
                            .fill(Color("positive"))
                            .frame(width: 23, height: 23)
                            .overlay(
                                Circle()
                                    .stroke(Color("surfaceBackground"), lineWidth: 3)
                            )
                            .offset(x: 1, y: 2)
                    }
                }
            }
            .padding(.top, 8)
            
            // Attribution
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text(profile.name)
                        .headline2EmphasizedTypography()
                        .foregroundStyle(Color("primaryText"))
                        .multilineTextAlignment(.center)
                    
                    Text("You're friends on Facebook")
                        .body4Typography()
                        .foregroundStyle(Color("primaryText"))
                        .multilineTextAlignment(.center)
                    
                    if let location = profile.currentLocation {
                        Text("Lives in \(location)")
                            .body4Typography()
                            .foregroundStyle(Color("secondaryText"))
                            .multilineTextAlignment(.center)
                    }
                }
                
                // View profile button using FDSButton
                FDSButton(
                    type: .secondary,
                    label: "View profile",
                    size: .small,
                    widthMode: .constrained,
                    action: dismissAction
                )
            }
            .padding(.top, 12)
            
            // Encryption message
            ViewThatFits {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image("privacy-filled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(Color("secondaryIcon"))
                    
                    (
                        Text("Messages and calls are secured with end-to-end encryption. Only people in this chat can read, listen to, or share them. ")
                        +
                        Text("Learn more")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("blueLink"))
                    )
                    .meta4Typography()
                    .foregroundStyle(Color("secondaryText"))
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 32)
            .padding(.top, 20)
            .onTapGesture {
                // Handle learn more action
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Suggested Messages Section

struct SuggestedMessagesSection: View {
    let messages: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            // Instructions
            Text("Tap a message to send it.")
                .meta3Typography()
                .foregroundStyle(Color("secondaryText"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            
            // Horizontal scroll of suggestions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(messages, id: \.self) { message in
                        Button(action: {}) {
                            Text(message)
                                .body3Typography()
                                .foregroundStyle(Color("primaryText"))
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .frame(height: 35)
                                .background(Color("cardBackground"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color("borderUiEmphasis"), lineWidth: 1)
                                )
                                .cornerRadius(18)
                        }
                        .buttonStyle(FDSPressedState(cornerRadius: 18, scale: .small))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
        }
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Messaging Composer

struct MessagingComposer: View {
    @Binding var messageText: String
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Left addons using FDSIconButton
            HStack(spacing: 12) {
                FDSIconButton(
                    icon: "camera-filled",
                    size: .size24,
                    color: .accent,
                    action: {}
                )
                
                // Photo icon with forced sizing
                Button(action: {}) {
                    Image("photo-square-filled")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipped()
                        .foregroundStyle(Color("accentColor"))
                }
                .buttonStyle(FDSPressedState(
                    circle: true,
                    padding: EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                ))
                
                FDSIconButton(
                    icon: "microphone-filled",
                    size: .size24,
                    color: .accent,
                    action: {}
                )
            }
            
            // Input field
            HStack(spacing: 12) {
                TextField(
                    "",
                    text: $messageText,
                    prompt: Text("Aa").foregroundStyle(Color("placeholderTextDefault"))
                )
                .body3Typography()
                .foregroundStyle(Color("primaryText"))
                .focused($isTextFieldFocused)
                .frame(maxWidth: .infinity)
                
                FDSIconButton(
                    icon: "emoji-filled",
                    size: .size20,
                    color: .accent,
                    action: {}
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(minHeight: 40)
            .background(Color("textInputBarBackground"))
            .cornerRadius(24)
            
            // Right addon - like button using FDSIconButton
            FDSIconButton(
                icon: "like-filled",
                size: .size24,
                color: .accent,
                action: {}
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Preview

#Preview {
    MessagingLightweightThreadView(profile: profileDataMap["profile4"]!)
}
