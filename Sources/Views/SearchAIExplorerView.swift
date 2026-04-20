import SwiftUI

// MARK: - AI Explorer Result

struct AIExplorerResult: Identifiable {
    let id = UUID()
    let authorName: String
    let profileImage: String
    let timeAgo: String
    let contentImage: String
    let likes: String?
}

// MARK: - AI Explorer Query

struct AIExplorerQuery {
    let title: String
    let summary: String
    let results: [AIExplorerResult]
}

// MARK: - Sample Queries

let aiExplorerSampleQueries: [String: AIExplorerQuery] = [
    "Nikola Jokic": AIExplorerQuery(
        title: "Nikola Jokic",
        summary: "Nikola Jokic is widely regarded as one of the most complete players in NBA history. The Denver Nuggets center has redefined the position with his elite passing, scoring efficiency, and basketball IQ, earning three MVP awards and leading Denver to its first championship in 2023. Despite his unassuming demeanor, Jokic dominates games through court vision and playmaking rarely seen from a big man. His triple-double pace and per-game efficiency continue to set him apart from every other contender in the league. Off the court, Jokic is known for his low-key lifestyle and love of horses on his family's ranch in Sombor, Serbia.",
        results: [
            AIExplorerResult(authorName: "Nuggets Nation", profileImage: "nba_1", timeAgo: "2d", contentImage: "nba_1", likes: "8.3K"),
            AIExplorerResult(authorName: "Mile High Sports", profileImage: "nba_2", timeAgo: "1w", contentImage: "nba_2", likes: "4.1K"),
            AIExplorerResult(authorName: "NBA Central", profileImage: "nba_3", timeAgo: "3d", contentImage: "nba_3", likes: "5.7K"),
            AIExplorerResult(authorName: "Hoop Digest", profileImage: "nba_4", timeAgo: "5d", contentImage: "nba_4", likes: "2.9K")
        ]
    ),
    "Damian Lillard Career": AIExplorerQuery(
        title: "Damian Lillard Career",
        summary: "Damian Lillard is renowned for his dynamic playmaking and clutch performances in the NBA. As the star point guard for the Portland Trail Blazers, Lillard has consistently demonstrated exceptional leadership, guiding his team through high-pressure moments and earning multiple All-Star selections. Known for his deep three-point shooting and fearless drives to the basket, he has become a fan favorite and a respected figure among his peers. Off the court, Lillard is also recognized for his community involvement and his passion for music, performing under the stage name \"Dame D.O.L.L.A.\"",
        results: [
            AIExplorerResult(authorName: "Anna Soe", profileImage: "nba_1", timeAgo: "2w", contentImage: "nba_1", likes: "6.5K"),
            AIExplorerResult(authorName: "Anna Soe", profileImage: "nba_2", timeAgo: "5w", contentImage: "nba_2", likes: "1.2K"),
            AIExplorerResult(authorName: "Sports Daily", profileImage: "nba_3", timeAgo: "1w", contentImage: "nba_3", likes: "3.8K"),
            AIExplorerResult(authorName: "Hoop Central", profileImage: "nba_4", timeAgo: "3d", contentImage: "nba_4", likes: "2.1K")
        ]
    ),
    "Pantone Color of the Year": AIExplorerQuery(
        title: "Pantone Color of the Year",
        summary: "Pantone named Cloud Dancer its 2026 Color of the Year, a warm off-white that signals a collective desire for calm, simplicity, and a softer visual language across design, fashion, and interiors. The selection reflects broader cultural shifts toward muted palettes and natural tones. Fashion houses have already begun incorporating Cloud Dancer into their spring collections, while interior designers praise it as Pantone's most versatile and understated pick in over a decade.",
        results: [
            AIExplorerResult(authorName: "Design Weekly", profileImage: "pantone_new_1", timeAgo: "1w", contentImage: "pantone_new_1", likes: "4.2K"),
            AIExplorerResult(authorName: "Color Trends", profileImage: "pantone_new_2", timeAgo: "3d", contentImage: "pantone_new_2", likes: "1.8K"),
            AIExplorerResult(authorName: "Studio Palette", profileImage: "pantone-2", timeAgo: "5d", contentImage: "pantone-2", likes: "2.5K"),
            AIExplorerResult(authorName: "Creative Space", profileImage: "pantone-3", timeAgo: "2w", contentImage: "pantone-3", likes: "890")
        ]
    )
]

// MARK: - Search AI Explorer View

struct SearchAIExplorerView: View {
    let queryTitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTabIndex = 0
    @State private var followUpText = ""

    private var query: AIExplorerQuery {
        if let match = aiExplorerSampleQueries[queryTitle] {
            return match
        }
        let fallback = aiExplorerSampleQueries.values.first!
        return AIExplorerQuery(title: queryTitle, summary: fallback.summary, results: fallback.results)
    }

    private let tabs = [
        SubNavigationItem("Meta AI"),
        SubNavigationItem("All"),
        SubNavigationItem("Posts"),
        SubNavigationItem("People"),
        SubNavigationItem("Videos")
    ]

    var body: some View {
        VStack(spacing: 0) {
            FDSNavigationBarCentered(
                title: query.title,
                backAction: { dismiss() },
                icon1: { FDSIconButton(icon: "filter-sliders-outline", action: {}) }
            )

            FDSSubNavigationBar(
                items: tabs,
                selectedIndex: $selectedTabIndex
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // AI summary
                    Text(query.summary)
                        .body3Typography()
                        .foregroundStyle(Color("primaryText"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 16)

                    // Media grid
                    aiMediaGrid
                }
            }
            .background(Color("surfaceBackground"))

            followUpBar
        }
        .hideFDSTabBar(true)
    }

    // MARK: - Media Grid

    @ViewBuilder
    private var aiMediaGrid: some View {
        let results = query.results
        let rows = stride(from: 0, to: results.count, by: 2).map {
            Array(results[$0..<min($0 + 2, results.count)])
        }

        VStack(spacing: 4) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) {
                    ForEach(row) { result in
                        aiMediaTile(result: result)
                            .frame(maxWidth: .infinity)
                    }
                    if row.count == 1 {
                        Color.clear.frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func aiMediaTile(result: AIExplorerResult) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Image(result.contentImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                // Top gradient
                VStack {
                    LinearGradient(
                        stops: [
                            .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.0),
                            .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.5),
                            .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 80)
                    Spacer()
                }

                // Bottom gradient
                VStack {
                    Spacer()
                    LinearGradient(
                        stops: [
                            .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 0.0),
                            .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.5),
                            .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                }

                // Author info
                VStack(alignment: .leading) {
                    HStack(spacing: 6) {
                        Image(result.profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())

                        Text(result.authorName)
                            .body4LinkTypography()
                            .foregroundStyle(Color("primaryTextOnMedia"))
                            .textOnMediaShadow()
                            .lineLimit(1)
                    }

                    Text(result.timeAgo)
                        .meta4Typography()
                        .foregroundStyle(Color("secondaryTextOnMedia"))
                        .textOnMediaShadow()
                        .padding(.leading, 26)

                    Spacer()

                    // Likes
                    if let likes = result.likes {
                        HStack(spacing: 4) {
                            Image("like-outline")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                                .foregroundStyle(Color("primaryIconOnMedia"))
                                .iconOnMediaShadow()

                            Text(likes)
                                .meta4Typography()
                                .foregroundStyle(Color("primaryTextOnMedia"))
                                .textOnMediaShadow()
                        }
                    }
                }
                .padding(12)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(9.0/16.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Follow-up Bar

    private var followUpBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color("borderUiEmphasis"))
                .frame(height: 0.5)

            HStack(spacing: 12) {
                Image("magnifying-glass-outline")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color("secondaryIcon"))

                TextField("Ask a follow-up...", text: $followUpText)
                    .body2Typography()
                    .foregroundStyle(Color("primaryText"))

                Spacer()

                Image("microphone-outline")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color("secondaryIcon"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color("surfaceBackground"))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SearchAIExplorerView(queryTitle: "Damian Lillard Career")
    }
}
