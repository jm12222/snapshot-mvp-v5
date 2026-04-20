import SwiftUI

// MARK: - Glimmer Modifier

struct Glimmer: ViewModifier {
    @State private var step: Int = 0
    @State private var direction: Int = 1 // 1 for forward, -1 for backward
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect() // 1000ms / 10 steps = 100ms per step
    
    var opacity: Double {
        // Map step (0-10) to opacity (0.25-1.0)
        let progress = Double(step) / 10.0
        return 0.4 + (progress * 0.75)
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onReceive(timer) { _ in
                step += direction
                
                // Alternate direction when reaching bounds
                if step >= 10 {
                    step = 10
                    direction = -1
                } else if step <= 0 {
                    step = 0
                    direction = 1
                }
            }
    }
}

extension View {
    func glimmer() -> some View {
        modifier(Glimmer())
    }
}

// MARK: - Story Tile Glimmer

struct StoryTileGlimmer: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                // Story image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack(alignment: .leading) {
                    // Profile photo placeholder
                    Circle()
                        .fill(Color("glimmerIndex1"))
                        .frame(width: 32, height: 32)
                        .padding(8)
                    
                    Spacer()
                }
            }
        }
        .glimmer()
    }
}

// MARK: - Post Composer Glimmer

struct PostComposerGlimmer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Profile photo placeholder
            Circle()
                .fill(Color("glimmerIndex1"))
                .frame(width: 40, height: 40)
            
            // Input text placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("glimmerIndex1"))
                .frame(height: 40)
            
            // Photo button placeholder
            Circle()
                .fill(Color("glimmerIndex1"))
                .frame(width: 20, height: 20)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 4)
        .background(Color("surfaceBackground"))
        .glimmer()
    }
}

// MARK: - Feed Post Glimmer

struct FeedPostGlimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .center, spacing: 12) {
                // Profile photo placeholder
                Circle()
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Username placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("glimmerIndex1"))
                        .frame(width: 120, height: 14)
                    
                    // Timestamp placeholder
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("glimmerIndex1"))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            

            // Image placeholder
            RoundedRectangle(cornerRadius: 0)
                .fill(Color("surfaceBackground"))
                .frame(height: 250)
                .aspectRatio(1, contentMode: .fit)
            
            // Action bar placeholder
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 42, height: 16)
                    .frame(maxWidth: .infinity)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 68, height: 16)
                    .frame(maxWidth: .infinity)
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 48, height: 16)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
        }
        .background(Color("surfaceBackground"))
        .glimmer()
    }
}

// MARK: - Notification List Cell Glimmer

struct NotificationListCellGlimmer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Profile photo with badge placeholder
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 60, height: 60)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Notification text placeholder (2 lines)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("glimmerIndex1"))
                        .frame(height: 14)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("glimmerIndex1"))
                        .frame(width: 200, height: 14)
                }
                
                // Timestamp placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 60, height: 12)
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("surfaceBackground"))
        .glimmer()
    }
}

// MARK: - List Cell Glimmer

struct ListCellGlimmer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Profile photo with badge placeholder
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 40, height: 40)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 84, height: 12)
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color("surfaceBackground"))
        .glimmer()
    }
}

// MARK: - Comment Glimmer

struct CommentGlimmer: View {
    let type: FDSCommentType
    
    init(type: FDSCommentType = .topLevel) {
        self.type = type
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile photo
            Circle()
                .fill(Color("glimmerIndex1"))
                .frame(width: type.profilePhotoSize, height: type.profilePhotoSize)
            
            VStack(alignment: .leading, spacing: 0) {
                // Header: actor name + timestamp
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 120, height: 12)
                    .padding(.top, 4)
                    .padding(.bottom, 10)
                
                // Comment text (2 lines)
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("glimmerIndex1"))
                        .frame(height: 14)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("glimmerIndex1"))
                        .frame(width: 180, height: 14)
                }
                
                // Footer: Reply button placeholder
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("glimmerIndex1"))
                    .frame(width: 40, height: 12)
                    .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.leading, type.leadingInset + 12)
        .padding(.trailing, 12)
        .padding(.vertical, 8)
        .glimmer()
    }
}

// MARK: - Glimmer Group Card Component

struct GlimmerGroupCard<Content: View>: View {
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

// MARK: - Glimmer Preview View

struct GlimmerPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: "FDSGlimmer",
                backAction: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    GlimmerGroupCard(title: "Story tile glimmer") {
                        StoryTileGlimmer()
                            .frame(width: 114, height: 203)
                    }
                    
                    GlimmerGroupCard(title: "Post composer glimmer") {
                        PostComposerGlimmer()
                    }
                    
                    GlimmerGroupCard(title: "Feed post glimmer") {
                        FeedPostGlimmer()
                    }
                    
                    GlimmerGroupCard(title: "Notification list cell glimmer") {
                        VStack(spacing: 0) {
                            NotificationListCellGlimmer()
                            NotificationListCellGlimmer()
                            NotificationListCellGlimmer()
                        }
                    }
                    
                    GlimmerGroupCard(title: "List cell glimmer") {
                        VStack(spacing: 0) {
                            ListCellGlimmer()
                            ListCellGlimmer()
                            ListCellGlimmer()
                        }
                    }
                    
                    GlimmerGroupCard(title: "Comment glimmer") {
                        VStack(spacing: 0) {
                            CommentGlimmer(type: .topLevel)
                            CommentGlimmer(type: .topLevel)
                            CommentGlimmer(type: .reply)
                            CommentGlimmer(type: .reply)
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
    GlimmerPreviewView()
}