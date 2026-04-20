import SwiftUI


// MARK: - FDSAssetLockup


/// A container component that pairs a specific asset with a label below.
///
/// Supports multiple asset types:
/// - Profile photo (single user)
/// - Dual profile photo (group chats)
/// - Contained icon (icon on colored background)
/// - Expressive icon (PNG image that fills the container)
///
/// Available in two sizes: Medium (40pt) and Large (60pt)
struct FDSAssetLockup: View {
    
    // MARK: - Properties
    
    let size: Size
    let label: String
    let asset: Asset
    let action: () -> Void
    
    // MARK: - Computed Properties
    
    private var assetSize: CGFloat {
        switch size {
        case .medium: return 40
        case .large: return 60
        }
    }
    
    private var containerWidth: CGFloat {
        switch size {
        case .medium: return 40
        case .large: return 60
        }
    }
    
    private var textWidth: CGFloat {
        switch size {
        case .medium: return 48
        case .large: return 68
        }
    }
    
    private var labelLineLimit: Int {
        switch size {
        case .medium: return 1
        case .large: return 3
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 8) {
                assetView
                
                Text(label)
                    .body4Typography()
                    .foregroundStyle(Color("primaryText"))
                    .multilineTextAlignment(.center)
                    .lineLimit(labelLineLimit)
                    .frame(width: textWidth)
            }
            .frame(width: containerWidth)
        }
        .buttonStyle(FDSPressedState(
            cornerRadius: 8,
            scale: .small,
            padding: EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        ))
    }
    
    // MARK: - Asset View
    
    @ViewBuilder
    private var assetView: some View {
        switch asset {
        case .profilePhoto(let url, let type):
            profilePhotoView(url: url, type: type)
                .frame(width: assetSize, height: assetSize)
            
        case .dualProfilePhoto(let foreground, let background, let photoType):
            dualProfilePhotoView(
                foreground: foreground,
                background: background,
                type: photoType
            )
            .frame(width: assetSize, height: assetSize)
            
        case .containedIcon(let icon, let backgroundColor, let iconColor):
            containedIconView(
                icon: icon,
                backgroundColor: backgroundColor,
                iconColor: iconColor
            )
            .frame(width: assetSize, height: assetSize)
            
        case .expressiveIcon(let imageName):
            expressiveIconView(imageName: imageName)
                .frame(width: assetSize, height: assetSize)
        }
    }
    
    // MARK: - Profile Photo View
    
    private func profilePhotoView(url: String, type: ProfilePhotoType) -> some View {
        Image(url)
            .resizable()
            .scaledToFill()
            .frame(width: assetSize, height: assetSize)
            .clipShape(Circle())
    }
    
    // MARK: - Dual Profile Photo View
    
    private func dualProfilePhotoView(
        foreground: ProfileImage,
        background: ProfileImage,
        type: DualProfilePhotoType
    ) -> some View {
        let individualSize = assetSize * 0.667 // ~67% of full size for each circle
        
        return ZStack {
            // Background image (top right)
            Image(background.imageUri)
                .resizable()
                .scaledToFill()
                .frame(width: individualSize, height: individualSize)
                .clipShape(Circle())
                .offset(x: assetSize * 0.167, y: -assetSize * 0.167)
            
            // Foreground image (bottom left)
            Image(foreground.imageUri)
                .resizable()
                .scaledToFill()
                .frame(width: individualSize, height: individualSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color("surfaceBackground"), lineWidth: 2)
                )
                .offset(x: -assetSize * 0.167, y: assetSize * 0.167)
        }
    }
    
    // MARK: - Contained Icon View
    
    private func containedIconView(
        icon: String,
        backgroundColor: Color,
        iconColor: Color
    ) -> some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
            
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: assetSize * 0.4, height: assetSize * 0.4)
                .foregroundStyle(iconColor)
        }
    }
    
    // MARK: - Expressive Icon View
    
    private func expressiveIconView(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: assetSize, height: assetSize)
            .clipShape(Circle())
    }
}


// MARK: - Size


extension FDSAssetLockup {
    enum Size {
        case medium // 40pt
        case large  // 60pt
    }
}


// MARK: - Asset Types


extension FDSAssetLockup {
    enum Asset {
        case profilePhoto(url: String, type: ProfilePhotoType = .nonActor)
        case dualProfilePhoto(
            foreground: ProfileImage,
            background: ProfileImage,
            type: DualProfilePhotoType
        )
        case containedIcon(
            icon: String,
            backgroundColor: Color,
            iconColor: Color
        )
        case expressiveIcon(imageName: String)
    }
    
    enum ProfilePhotoType {
        case actor
        case nonActor
    }
    
    enum DualProfilePhotoType {
        case dualProfile
        case chat
    }
    
    struct ProfileImage {
        let imageUri: String
        let placeholder: String
        
        init(imageUri: String, placeholder: String = "") {
            self.imageUri = imageUri
            self.placeholder = placeholder
        }
    }
}


// MARK: - Asset Lockup Preview View


struct AssetLockupPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSAssetLockup",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Photos
                    VStack(spacing: 12) {
                        FDSUnitHeader(headlineText: "Profile photos")
                        
                        VStack(spacing: 12) {
                            Text("Large (60pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Tina\nWright",
                                        asset: .profilePhoto(url: "profile6"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Shira\nThomsen",
                                        asset: .profilePhoto(url: "profile7"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Airi\nAnderson",
                                        asset: .profilePhoto(url: "profile5"),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                            
                            Text("Medium (40pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Tina Wright",
                                        asset: .profilePhoto(url: "profile6"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Shira Thomsen",
                                        asset: .profilePhoto(url: "profile7"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Airi Anderson",
                                        asset: .profilePhoto(url: "profile5"),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    
                    // Dual Profile Photos
                    VStack(spacing: 12) {
                        FDSUnitHeader(headlineText: "Dual profile photos")
                        
                        VStack(spacing: 12) {
                            Text("Large (60pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "The\ngirlies",
                                        asset: .dualProfilePhoto(
                                            foreground: .init(imageUri: "profile4"),
                                            background: .init(imageUri: "profile3"),
                                            type: .chat
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Lina and\nNastya",
                                        asset: .dualProfilePhoto(
                                            foreground: .init(imageUri: "profile11"),
                                            background: .init(imageUri: "profile10"),
                                            type: .chat
                                        ),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                            
                            Text("Medium (40pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "The girlies",
                                        asset: .dualProfilePhoto(
                                            foreground: .init(imageUri: "profile4"),
                                            background: .init(imageUri: "profile3"),
                                            type: .chat
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Lina and Nastya",
                                        asset: .dualProfilePhoto(
                                            foreground: .init(imageUri: "profile11"),
                                            background: .init(imageUri: "profile10"),
                                            type: .chat
                                        ),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    
                    // Contained Icons
                    VStack(spacing: 12) {
                        FDSUnitHeader(headlineText: "Contained icons")
                        
                        VStack(spacing: 12) {
                            Text("Large (60pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Copy link",
                                        asset: .containedIcon(
                                            icon: "link-outline",
                                            backgroundColor: Color("secondaryButtonBackground"),
                                            iconColor: Color("primaryIcon")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "WhatsApp",
                                        asset: .containedIcon(
                                            icon: "app-whatsapp-filled",
                                            backgroundColor: Color("decorativeIconGreen"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Messenger",
                                        asset: .containedIcon(
                                            icon: "app-messenger-filled",
                                            backgroundColor: Color("accentColor"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Instagram",
                                        asset: .containedIcon(
                                            icon: "app-instagram-filled",
                                            backgroundColor: Color("decorativeIconPink"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Threads",
                                        asset: .containedIcon(
                                            icon: "app-threads-filled",
                                            backgroundColor: Color("alwaysBlack"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                            
                            Text("Medium (40pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Copy link",
                                        asset: .containedIcon(
                                            icon: "link-outline",
                                            backgroundColor: Color("secondaryButtonBackground"),
                                            iconColor: Color("primaryIcon")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "WhatsApp",
                                        asset: .containedIcon(
                                            icon: "app-whatsapp-filled",
                                            backgroundColor: Color("decorativeIconGreen"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Messenger",
                                        asset: .containedIcon(
                                            icon: "app-messenger-filled",
                                            backgroundColor: Color("accentColor"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Instagram",
                                        asset: .containedIcon(
                                            icon: "app-instagram-filled",
                                            backgroundColor: Color("decorativeIconPink"),
                                            iconColor: Color("alwaysWhite")
                                        ),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    
                    // Expressive Icons
                    VStack(spacing: 12) {
                        FDSUnitHeader(headlineText: "Expressive icons")
                        
                        VStack(spacing: 12) {
                            Text("Large (60pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Haha",
                                        asset: .expressiveIcon(imageName: "haha-large"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Love",
                                        asset: .expressiveIcon(imageName: "love-large"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .large,
                                        label: "Wow",
                                        asset: .expressiveIcon(imageName: "wow-large"),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                            
                            Text("Medium (40pt)")
                                .body2Typography()
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Haha",
                                        asset: .expressiveIcon(imageName: "haha-large"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Love",
                                        asset: .expressiveIcon(imageName: "love-large"),
                                        action: {}
                                    )
                                    
                                    FDSAssetLockup(
                                        size: .medium,
                                        label: "Wow",
                                        asset: .expressiveIcon(imageName: "wow-large"),
                                        action: {}
                                    )
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(Color("surfaceBackground"))
        }
        .hideFDSTabBar(true)
    }
}


// MARK: - Preview


#Preview {
    AssetLockupPreviewView()
        .environmentObject(FDSTabBarHelper())
}

