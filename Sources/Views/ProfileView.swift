import SwiftUI
import MapKit

// MARK: - Profile Relationship Type

enum ProfileRelationship {
    case currentUser
    case friend
    case stranger
}

// MARK: - Supporting Data Models

struct WorkExperience: Hashable, Identifiable {
    let id: String
    let company: String
    let position: String?
    let location: String?
    let years: String?
    let image: String?
}

struct EducationExperience: Hashable, Identifiable {
    let id: String
    let school: String
    let degree: String?
    let years: String?
    let image: String?
}

struct HobbyItem: Hashable, Identifiable {
    let id: String
    let name: String
    let icon: String?
    let description: String?
}

struct MusicArtist: Hashable, Identifiable {
    let id: String
    let name: String
    let image: String?
}

struct TVShow: Hashable, Identifiable {
    let id: String
    let name: String
    let image: String?
}

struct Movie: Hashable, Identifiable {
    let id: String
    let name: String
    let image: String?
}

struct Game: Hashable, Identifiable {
    let id: String
    let name: String
    let image: String?
}

struct Sport: Hashable, Identifiable {
    let id: String
    let name: String
    let image: String?
}

struct TravelLocation: Hashable, Identifiable {
    let id: String
    let city: String
    let country: String
    let visitCount: Int
    let latitude: Double
    let longitude: Double
}

struct ContactInfo: Hashable {
    let mobile: String?
    let email: String?
    let messenger: String?
    let instagram: String?
    let otherContacts: [String]?
}

struct FriendPreview: Hashable, Identifiable {
    let id: String
    let name: String
    let lastName: String
    let profileImage: String
    let mutualFriendsCount: Int
}

struct Highlight: Hashable, Identifiable {
    let id: String
    let image: String
    let type: String // "photo" or "video"
    let label: String
}

// MARK: - Scroll Offset Tracking

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Profile Data Model

struct ProfileData: Hashable {
    let id: String
    let name: String
    let profileImage: String
    let coverImage: String
    let bio: String
    let friendCount: Int
    let postCount: Int
    
    // Professional Mode
    let isProfessionalMode: Bool
    let followersCount: Int?
    let followingCount: Int?

    // Personal Details
    let currentLocation: String?
    let from: String?
    let birthday: String?
    let gender: String?
    let languages: [String]?

    // Work & Education
    let work: [WorkExperience]?
    let education: [EducationExperience]?

    // Interests & Activities
    let hobbies: [HobbyItem]?
    let interests: [String]?
    let music: [MusicArtist]?
    let tvShows: [TVShow]?
    let movies: [Movie]?
    let games: [Game]?
    let sports: [Sport]?

    // Other
    let relationship: String?
    let instagram: String?
    let travel: [TravelLocation]?
    let contactInfo: ContactInfo?
    let friends: [FriendPreview]?
    let highlights: [Highlight]?

    let relationshipType: ProfileRelationship
    let isActiveNow: Bool

    static let currentUser = ProfileData(
        id: "profile1",
        name: "Daniela Giménez",
        profileImage: "profile1",
        coverImage: "ana-cover",
        bio: "Probably off wandering somewhere.",
        friendCount: 423,
        postCount: 287,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Lawrence, KS",
        from: "Shawnee, KS",
        birthday: "December 15",
        gender: "Female",
        languages: ["English", "Spanish"],
        work: [
            WorkExperience(id: "w1", company: "Walmart", position: "Designer", location: "San Francisco, CA", years: "2 years", image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "University of Kansas", degree: "Bachelor's Degree", years: "2015-2019", image: nil)
        ],
        hobbies: [
            HobbyItem(id: "h1", name: "Painting", icon: "more-shapes-outline", description: "Clears my mind and keeps me energized for college life"),
            HobbyItem(id: "h2", name: "Meditation", icon: "more-shapes-outline", description: "I've been meditating for about 10 years. It's my favorite way to clear my head and stay healthy"),
            HobbyItem(id: "h3", name: "Photography · Traveling · Hiking · Rock climbing · Running · Strength training", icon: nil, description: nil)
        ],
        interests: [],
        music: [
            MusicArtist(id: "m1", name: "Tame Impala", image: "tame-impala"),
            MusicArtist(id: "m2", name: "Ain't No Thang • Outkast", image: "outkast"),
            MusicArtist(id: "m3", name: "Jordana", image: "jordana")
        ],
        tvShows: [
            TVShow(id: "tv1", name: "Ninja Scroll", image: "ninja-scroll"),
            TVShow(id: "tv2", name: "One Piece", image: "one-piece"),
            TVShow(id: "tv3", name: "Fantasmas", image: "fantasmas")
        ],
        movies: [
            Movie(id: "mv1", name: "Spirited Away", image: "spirited-away"),
            Movie(id: "mv2", name: "The Life Aquatic", image: "the-life-aquatic"),
            Movie(id: "mv3", name: "The Substance", image: "the-substance"),
            Movie(id: "mv4", name: "Central Station", image: "central-station"),
            Movie(id: "mv5", name: "Alien", image: "alien")
        ],
        games: [
            Game(id: "g1", name: "Marvel Rivals", image: nil),
            Game(id: "g2", name: "Minecraft", image: "minecraft")
        ],
        sports: [
            Sport(id: "s1", name: "Kansas Jayhawks", image: "kansas-jayhawks"),
            Sport(id: "s2", name: "U.S. Women's National Soccer team", image: "us-womens-soccer"),
            Sport(id: "s3", name: "Usain Bolt", image: "usain-bolt")
        ],
        relationship: "In a relationship",
        instagram: "danielagimenez",
        travel: [
            TravelLocation(id: "t1", city: "Los Angeles", country: "CA", visitCount: 7, latitude: 34.0522, longitude: -118.2437),
            TravelLocation(id: "t2", city: "Paris", country: "France", visitCount: 3, latitude: 48.8566, longitude: 2.3522),
            TravelLocation(id: "t3", city: "Chicago", country: "IL", visitCount: 5, latitude: 41.8781, longitude: -87.6298),
            TravelLocation(id: "t4", city: "New York", country: "NY", visitCount: 12, latitude: 40.7128, longitude: -74.0060),
            TravelLocation(id: "t5", city: "Berlin", country: "Germany", visitCount: 2, latitude: 52.5200, longitude: 13.4050),
            TravelLocation(id: "t6", city: "Tokyo", country: "Japan", visitCount: 4, latitude: 35.6762, longitude: 139.6503),
            TravelLocation(id: "t7", city: "San Francisco", country: "CA", visitCount: 8, latitude: 37.7749, longitude: -122.4194)
        ],
        contactInfo: ContactInfo(
            mobile: "+1 (213) 456-7890",
            email: "danielagimenez@gmail.com",
            messenger: "Daniela Giménez",
            instagram: "danielagimenez",
            otherContacts: nil
        ),
        friends: [
            FriendPreview(id: "fp1", name: "Jessica", lastName: "Chen", profileImage: "profile3", mutualFriendsCount: 12),
            FriendPreview(id: "fp2", name: "Michael", lastName: "Rodriguez", profileImage: "profile5", mutualFriendsCount: 8),
            FriendPreview(id: "fp3", name: "Thomas", lastName: "Anderson", profileImage: "profile4", mutualFriendsCount: 25),
            FriendPreview(id: "fp4", name: "Sabrina", lastName: "Williams", profileImage: "profile6", mutualFriendsCount: 5)
        ],
        highlights: [
            Highlight(id: "hl0", image: "pnw", type: "photo", label: "PNW"),
            Highlight(id: "hl1", image: "cancun", type: "photo", label: "Cancun"),
            Highlight(id: "hl2", image: "greece", type: "photo", label: "Greece"),
            Highlight(id: "hl3", image: "photography", type: "photo", label: "Photography")
        ],
        relationshipType: .currentUser,
        isActiveNow: true
    )
}

// MARK: - Sample Profile Data

let profileDataMap: [String: ProfileData] = [
    "profile1": ProfileData.currentUser,
    "profile2": ProfileData(
        id: "profile2",
        name: "Bob Johnson",
        profileImage: "profile2",
        coverImage: "image4",
        bio: "Living life one adventure at a time.",
        friendCount: 189,
        postCount: 142,
        isProfessionalMode: true,
        followersCount: 12500,
        followingCount: 342,
        currentLocation: "Portland, OR",
        from: "Seattle, WA",
        birthday: nil,
        gender: "Male",
        languages: ["English"],
        work: [
            WorkExperience(id: "w1", company: "Freelance", position: "Photographer", location: nil, years: "5 years", image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Portland State University", degree: nil, years: nil, image: nil)
        ],
        hobbies: [
            HobbyItem(id: "h1", name: "Photography", icon: nil, description: nil),
            HobbyItem(id: "h2", name: "Hiking", icon: nil, description: nil)
        ],
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: nil,
        instagram: "bobjohnson",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .stranger,
        isActiveNow: false
    ),
    "profile3": ProfileData(
        id: "profile3",
        name: "Alice Smith",
        profileImage: "profile3",
        coverImage: "image1",
        bio: "Vintage clothing collector 🌼",
        friendCount: 567,
        postCount: 421,
        isProfessionalMode: true,
        followersCount: 8900,
        followingCount: 215,
        currentLocation: "Brooklyn, NY",
        from: nil,
        birthday: nil,
        gender: "Female",
        languages: ["English", "French"],
        work: [
            WorkExperience(id: "w1", company: "Vintage Boutique", position: "Shop Owner", location: "Brooklyn, NY", years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Parsons School of Design", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "Single",
        instagram: "alicesmith",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .stranger,
        isActiveNow: false
    ),
    "profile4": ProfileData(
        id: "profile4",
        name: "Diana Ross",
        profileImage: "profile4",
        coverImage: "image5",
        bio: "Skater • Artist • Explorer",
        friendCount: 312,
        postCount: 198,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Salt Lake City, UT",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "University of Utah", position: "Artist in Residence", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "University of Utah", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: nil,
        instagram: "dianaross",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: true
    ),
    "profile5": ProfileData(
        id: "profile5",
        name: "Alex Kim",
        profileImage: "profile5",
        coverImage: "image6",
        bio: "Baker & food content creator 🍰",
        friendCount: 891,
        postCount: 654,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Los Angeles, CA",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Sweet Dreams Bakery", position: "Head Baker", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Culinary Institute of America", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "Married",
        instagram: "alexkim",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: true
    ),
    "profile6": ProfileData(
        id: "profile6",
        name: "Tina Wright",
        profileImage: "profile6",
        coverImage: "image7",
        bio: "Tech enthusiast • Gamer • Cat dad",
        friendCount: 234,
        postCount: 167,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Seattle, WA",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Microsoft", position: "Software Engineer", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "University of Washington", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: nil,
        instagram: "marcuswong",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: false
    ),
    "profile7": ProfileData(
        id: "profile7",
        name: "Taina Thomsen",
        profileImage: "profile7",
        coverImage: "image8",
        bio: "Home chef • Recipe developer",
        friendCount: 445,
        postCount: 289,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Austin, TX",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Food Network", position: "Recipe Developer", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Texas Culinary Academy", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "Single",
        instagram: "tainathomsen",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: true
    ),
    "profile8": ProfileData(
        id: "profile8",
        name: "Jamie Lee",
        profileImage: "profile8",
        coverImage: "image1",
        bio: "Fitness coach • Wellness advocate",
        friendCount: 723,
        postCount: 512,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Miami, FL",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "FitLife Studio", position: "Personal Trainer", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Florida State University", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "Engaged",
        instagram: "jamielee",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: false
    ),
    "profile9": ProfileData(
        id: "profile9",
        name: "Fatih Tekin",
        profileImage: "profile9",
        coverImage: "image5",
        bio: "Dog lover 🐶 • Costume designer",
        friendCount: 378,
        postCount: 256,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Chicago, IL",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Chicago Theatre", position: "Costume Designer", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "School of the Art Institute of Chicago", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: nil,
        instagram: "fatihtekin",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: true
    ),
    "profile10": ProfileData(
        id: "profile10",
        name: "Ana Santos",
        profileImage: "profile12",
        coverImage: "image2",
        bio: "Probably off wandering somewhere.",
        friendCount: 245,
        postCount: 153,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Lawrence, KS",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Travel Blog", position: "Content Creator", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "University of Kansas", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "Single",
        instagram: "anasantos",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: false
    ),
    "profile11": ProfileData(
        id: "profile11",
        name: "Kelsey Fung",
        profileImage: "profile11",
        coverImage: "ana-cover",
        bio: "Music producer • DJ",
        friendCount: 667,
        postCount: 401,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Nashville, TN",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Independent", position: "Music Producer", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Berklee College of Music", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "In a relationship",
        instagram: "ryanmartinez",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: true
    ),
    "profile12": ProfileData(
        id: "profile10",
        name: "John Stockholm",
        profileImage: "profile12",
        coverImage: "image2",
        bio: "Nature photographer 📸",
        friendCount: 456,
        postCount: 334,
        isProfessionalMode: false,
        followersCount: nil,
        followingCount: nil,
        currentLocation: "Denver, CO",
        from: nil,
        birthday: nil,
        gender: nil,
        languages: nil,
        work: [
            WorkExperience(id: "w1", company: "Freelance", position: "Nature Photographer", location: nil, years: nil, image: nil)
        ],
        education: [
            EducationExperience(id: "e1", school: "Rocky Mountain College", degree: nil, years: nil, image: nil)
        ],
        hobbies: nil,
        interests: nil,
        music: nil,
        tvShows: nil,
        movies: nil,
        games: nil,
        sports: nil,
        relationship: "Single",
        instagram: "stockholmie",
        travel: nil,
        contactInfo: nil,
        friends: nil,
        highlights: nil,
        relationshipType: .friend,
        isActiveNow: false
    ),
]

// MARK: - Helper Functions

func formatCount(_ count: Int) -> String {
    if count >= 1000 {
        let thousands = Double(count) / 1000.0
        return String(format: "%.1fK", thousands)
    }
    return "\(count)"
}

// MARK: - Profile View

struct ProfileView: View {
    let profile: ProfileData
    var isTopLevelTab: Bool = false // true when used as Profile tab, false when pushed
    @State private var selectedIndex = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var isOnMedia = true
    @State private var showMessagingThread = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var drawerState: DrawerStateManager

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ZStack(alignment: .top) {
                    ScrollView {
                        VStack(spacing: 0) {
                            ProfileHeader(profile: profile, topSafeArea: geometry.safeAreaInsets.top, showMessagingThread: $showMessagingThread)
                                .background(
                                    GeometryReader { geo in
                                        let minY = geo.frame(in: .global).minY
                                        
                                        Color.clear.task(id: minY) {
                                            // Transition earlier - when scrolled down about 100pt
                                            let transitionPoint = geometry.safeAreaInsets.top - 100
                                            let newIsOnMedia = minY > transitionPoint
                                            
                                            if isOnMedia != newIsOnMedia {
                                                withAnimation(.easeInOut(duration: 0.1)) {
                                                    isOnMedia = newIsOnMedia
                                                }
                                            }
                                        }
                                    }
                                )

                            FDSSubNavigationBar(
                                items: [
                                    SubNavigationItem("All"),
                                    SubNavigationItem("Photos"),
                                    SubNavigationItem("Reels")
                                ],
                                selectedIndex: $selectedIndex
                            )
                            .background(Color("surfaceBackground"))
                            .padding(.top, 8)
                            .background(Color("surfaceBackground"))

                            // Profile Information Sections
                            VStack(spacing: 0) {
                                // Personal Details Section
                                if profile.currentLocation != nil || profile.from != nil || profile.gender != nil || profile.languages != nil {
                                    PersonalDetailsSection(profile: profile)
                                }

                                // Work Section
                                if let work = profile.work, !work.isEmpty {
                                    WorkSection(workExperiences: work, relationshipType: profile.relationshipType)
                                }

                                // Education Section
                                if let education = profile.education, !education.isEmpty {
                                    EducationSection(educationExperiences: education, relationshipType: profile.relationshipType)
                                }

                                // Hobbies Section
                                if let hobbies = profile.hobbies, !hobbies.isEmpty {
                                    HobbiesSection(hobbies: hobbies, relationshipType: profile.relationshipType)
                                }

                                // Interests Section (with nested Music, TV Shows, Movies, Games, Sports)
                                if (profile.music?.isEmpty == false) || 
                                   (profile.tvShows?.isEmpty == false) || 
                                   (profile.movies?.isEmpty == false) || 
                                   (profile.games?.isEmpty == false) || 
                                   (profile.sports?.isEmpty == false) {
                                    InterestsSection(
                                        music: profile.music ?? [],
                                        tvShows: profile.tvShows ?? [],
                                        movies: profile.movies ?? [],
                                        games: profile.games ?? [],
                                        sports: profile.sports ?? [],
                                        relationshipType: profile.relationshipType
                                    )
                                }

                                // Travel Section
                                if let travel = profile.travel, !travel.isEmpty {
                                    TravelSection(locations: travel, relationshipType: profile.relationshipType)
                                }

                                // Contact Info Section
                                if let contactInfo = profile.contactInfo,
                                   contactInfo.mobile != nil || contactInfo.email != nil || contactInfo.messenger != nil || contactInfo.instagram != nil || (contactInfo.otherContacts?.isEmpty == false) {
                                    ContactInfoSection(contactInfo: contactInfo, relationshipType: profile.relationshipType)
                                }

                                // Friends Section
                                if let friends = profile.friends, !friends.isEmpty {
                                    FriendsSection(friends: friends, totalCount: profile.friendCount)
                                }

                                // Highlights Section
                                if let highlights = profile.highlights, !highlights.isEmpty {
                                    HighlightsSection(highlights: highlights)
                                }

                                // Posts Section
                                FDSUnitHeader(
                                    headlineText: profile.relationshipType == .currentUser ? "Your posts" : "Posts",
                                    hierarchyLevel: .level3,
                                    rightAddOn: profile.relationshipType == .currentUser ? .actionText(label: "Filters", action: {}) : nil
                                )
                                .padding(.top, 0)

                                // Post composer (owner view only)
                                if profile.relationshipType == .currentUser {
                                    HStack(spacing: 12) {
                                        Image(profile.profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())

                                        Text("What's on your mind?")
                                            .body3Typography()
                                            .foregroundStyle(Color("secondaryText"))
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Image("photo-filled")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color("secondaryIcon"))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                    .onTapGesture {}

                                    // Reel and Live buttons
                                    HStack(spacing: 8) {
                                        FDSActionChip(
                                            size: .large,
                                            label: "Reel",
                                            leftAddOn: .icon("app-facebook-reels-filled"),
                                            isEmphasized: true,
                                            action: {}
                                        )

                                        FDSActionChip(
                                            size: .large,
                                            label: "Live",
                                            leftAddOn: .icon("camcorder-filled"),
                                            isEmphasized: true,
                                            action: {}
                                        )

                                        Spacer()
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color("backgroundDeemphasized"))

                                    // Manage posts button
                                    FDSButton(
                                        type: .secondary,
                                        label: "Manage posts",
                                        icon: "posts-filled",
                                        size: .medium,
                                        widthMode: .flexible,
                                        action: {}
                                    )
                                    .padding(.horizontal, 12)
                                    .padding(.top, 12)
                                }
                                
                                // Display posts
                                VStack(spacing: 4) {
                                    ForEach(postData.filter { post in
                                        // Show posts matching the profile owner's name
                                        return post.userName == profile.name
                                    }, id: \.id) { post in
                                        FeedPost(from: post, disableProfileNavigation: true)
                                    }
                                }
                                .background(Color("wash"))
                                .padding(.top, 8)
                            }
                            .background(Color("surfaceBackground"))
                        }
                        .background(Color("surfaceBackground"))
                    }
                    .ignoresSafeArea(edges: .top)
                    .hideTabBarOnScroll(threshold: 50)

                    // Sticky Navigation Bar
                    VStack(spacing: 0) {
                        // Custom Profile Navigation Bar
                        HStack(alignment: .center, spacing: 8) {
                            // Back button - uses drawer for top level tab, dismiss otherwise
                            FDSIconButton(
                                icon: isTopLevelTab ? "more-filled" : "chevron-left-filled",
                                onMedia: isOnMedia,
                                action: {
                                    if isTopLevelTab {
                                        drawerState.openDrawer()
                                    } else {
                                        dismiss()
                                    }
                                }
                            )

                            // Title - only show when not on media
                            if !isOnMedia {
                                Text(profile.name)
                                    .headline3EmphasizedTypography()
                                    .foregroundStyle(Color("primaryText"))
                                    .frame(height: 26, alignment: .leading)
                            }

                            Spacer()

                            // Right icons
                            HStack(spacing: 20) {
                                if profile.relationshipType == .currentUser {
                                    FDSIconButton(icon: "pencil-filled", onMedia: isOnMedia, action: {})
                                    FDSIconButton(icon: "magnifying-glass-filled", onMedia: isOnMedia, action: {})
                                    FDSIconButton(icon: "dots-3-horizontal-filled", onMedia: isOnMedia, action: {})
                                } else {
                                    FDSIconButton(icon: "magnifying-glass-filled", onMedia: isOnMedia, action: {})
                                    FDSIconButton(icon: "dots-3-horizontal-filled", onMedia: isOnMedia, action: {})
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 52)
                        .background(isOnMedia ? Color.clear : Color.white)
                        .overlay(alignment: .bottom) {
                            if !isOnMedia {
                                Rectangle()
                                    .fill(Color("borderUiEmphasis"))
                                    .frame(height: 1)
                            }
                        }
                        .padding(.bottom, 10)

                        Spacer()
                    }
                }
                .toolbar(.hidden, for: .tabBar)
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: PostData.self) { post in
                    PostPermalinkView(post: post)
                }
                .navigationDestination(for: String.self) { profileImageId in
                    if let profileData = profileDataMap[profileImageId] {
                        ProfileView(profile: profileData)
                    }
                }
                .navigationDestination(for: GroupNavigationValue.self) { groupNav in
                    if let groupData = groupDataMap[groupNav.groupImage] {
                        GroupView(group: groupData)
                    }
                }
            }
            .sheet(isPresented: $showMessagingThread) {
                MessagingLightweightThreadView(profile: profile)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
                    .presentationCornerRadius(16)
                    .presentationBackgroundInteraction(.enabled)
                    .presentationBackground(.clear)
                    .interactiveDismissDisabled(false)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).animation(.enterIn(MotionDuration.mediumIn)),
                        removal: .move(edge: .bottom).animation(.enterOut(MotionDuration.mediumOut))
                    ))
            }
        }
        .hideFDSTabBar(!isTopLevelTab)
    }
}

// MARK: - Profile Header

struct ProfileHeader: View {
    let profile: ProfileData
    let topSafeArea: CGFloat
    @Binding var showMessagingThread: Bool

    init(profile: ProfileData, topSafeArea: CGFloat = 0, showMessagingThread: Binding<Bool>) {
        self.profile = profile
        self.topSafeArea = topSafeArea
        self._showMessagingThread = showMessagingThread
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Cover Photo (stretchy effect disabled for performance)
                ZStack(alignment: .top) {
                    Image(profile.coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 160)
                        .clipped()

                    LinearGradient(
                        stops: [
                            .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                            .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                            .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                            .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                }
                
                // Profile Info Section
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20)
                            .fill(Color("surfaceBackground"))
                            .frame(height: 20)
                            .offset(y: -20)

                        HStack(alignment: .bottom, spacing: 8) {
                            Spacer()
                                .frame(width: 104)

                            VStack(alignment: .leading, spacing: 14) {
                                Text(profile.name)
                                    .headline2EmphasizedTypography()
                                    .foregroundStyle(Color("primaryText"))

                                WrappingHStack(spacing: 6) {
                                    if profile.isProfessionalMode {
                                        // Professional Mode: Show Followers, Following and Posts
                                        HStack(spacing: 4) {
                                            if let followersCount = profile.followersCount {
                                                HStack(spacing: 4) {
                                                    Text(formatCount(followersCount))
                                                        .meta3LinkTypography()
                                                        .foregroundStyle(Color("primaryText"))
                                                    Text("followers")
                                                        .meta3Typography()
                                                        .foregroundStyle(Color("primaryText"))
                                                }
                                            }
                                            
                                            if profile.followersCount != nil && profile.followingCount != nil {
                                                Text("·")
                                                    .meta3Typography()
                                                    .foregroundStyle(Color("primaryText"))
                                            }
                                            
                                            if let followingCount = profile.followingCount {
                                                HStack(spacing: 4) {
                                                    Text(formatCount(followingCount))
                                                        .meta3LinkTypography()
                                                        .foregroundStyle(Color("primaryText"))
                                                    Text("following")
                                                        .meta3Typography()
                                                        .foregroundStyle(Color("primaryText"))
                                                }
                                            }
                                            
                                            Text("·")
                                                .meta3Typography()
                                                .foregroundStyle(Color("primaryText"))
                                            
                                            Text(formatCount(profile.postCount))
                                                .meta3LinkTypography()
                                                .foregroundStyle(Color("primaryText"))
                                            Text("posts")
                                                .meta3Typography()
                                                .foregroundStyle(Color("primaryText"))
                                        }
                                        .fixedSize()
                                    } else {
                                        // Regular Mode: Show Friends and Posts
                                        HStack(spacing: 4) {
                                            Text(formatCount(profile.friendCount))
                                                .meta3LinkTypography()
                                                .foregroundStyle(Color("primaryText"))
                                            Text("friends")
                                                .meta3Typography()
                                                .foregroundStyle(Color("primaryText"))
                                            
                                            Text("·")
                                                .meta3Typography()
                                                .foregroundStyle(Color("primaryText"))
                                            
                                            Text(formatCount(profile.postCount))
                                                .meta3LinkTypography()
                                                .foregroundStyle(Color("primaryText"))
                                            Text("posts")
                                                .meta3Typography()
                                                .foregroundStyle(Color("primaryText"))
                                        }
                                        .fixedSize()
                                    }
                                }
                            }
                            .padding(.bottom, 16)
                            .offset(y: -5)
                            .frame(height: 52)

                            if profile.relationshipType == .currentUser {
                                Button(action: {}) {
                                    ZStack {
                                        Circle()
                                            .fill(Color("secondaryButtonBackground"))
                                            .frame(width: 32, height: 32)

                                        // Notification badge
                                        Circle()
                                            .fill(Color("decorativeIconRed"))
                                            .frame(width: 6, height: 6)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color("surfaceBackground"), lineWidth: 1)
                                            )
                                            .offset(x: 11, y: -11)

                                        Image("chevron-down-filled")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(Color("secondaryButtonIcon"))
                                    }
                                }
                                .offset(y: -30)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.bio)
                            .body3Typography()
                            .foregroundStyle(Color("primaryText"))
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        
                        // Pinned Details
                        if profile.relationshipType == .currentUser {
                            WrappingHStack(spacing: 6) {
                                // Location
                                if let location = profile.currentLocation {
                                    HStack(spacing: 4) {
                                        Image("pin-filled")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("primaryIcon"))
                                        Text(location)
                                            .body4LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                }
                                
                                // Separator after location
                                if profile.currentLocation != nil && (profile.work?.first != nil || profile.education?.first != nil || profile.relationship != nil || profile.instagram != nil) {
                                    Text("·")
                                        .body4Typography()
                                        .foregroundStyle(Color("primaryText"))
                                }
                                
                                // Latest Workplace
                                if let work = profile.work?.first {
                                    HStack(spacing: 4) {
                                        Image("briefcase-filled")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("primaryIcon"))
                                        Text(work.company)
                                            .body4LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                }
                                
                                // Separator after work
                                if profile.work?.first != nil && (profile.education?.first != nil || profile.relationship != nil || profile.instagram != nil) {
                                    Text("·")
                                        .body4Typography()
                                        .foregroundStyle(Color("primaryText"))
                                }
                                
                                // College
                                if let education = profile.education?.first {
                                    HStack(spacing: 4) {
                                        Image("mortar-board-filled")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("primaryIcon"))
                                        Text(education.school)
                                            .body4LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                }
                                
                                // Separator after education
                                if profile.education?.first != nil && (profile.relationship != nil || profile.instagram != nil) {
                                    Text("·")
                                        .body4Typography()
                                        .foregroundStyle(Color("primaryText"))
                                }
                                
                                // Relationship Status
                                if let relationship = profile.relationship {
                                    HStack(spacing: 4) {
                                        Image("heart-filled")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("primaryIcon"))
                                        Text(relationship)
                                            .body4LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                }
                                
                                // Separator after relationship
                                if profile.relationship != nil && profile.instagram != nil {
                                    Text("·")
                                        .body4Typography()
                                        .foregroundStyle(Color("primaryText"))
                                }
                                
                                // Instagram
                                if let instagram = profile.instagram {
                                    HStack(spacing: 4) {
                                        Image("app-instagram-filled")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                            .foregroundColor(Color("primaryIcon"))
                                        Text(instagram)
                                            .body4LinkTypography()
                                            .foregroundStyle(Color("primaryText"))
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                        }

                        ProfileActionButtons(relationshipType: profile.relationshipType, showMessagingThread: $showMessagingThread)
                            .padding(.horizontal, 12)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                    }
                    .background(Color("surfaceBackground"))
                }
                .background(Color("surfaceBackground"))
            }

            // Profile Photo - overlapping layer
            VStack {
                Spacer()
                    .frame(height: 122)
                HStack {
                    ZStack(alignment: .bottomTrailing) {
                        Image(profile.profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 96, height: 96)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color("surfaceBackground"), lineWidth: 4)
                            )

                        if profile.relationshipType == .currentUser {
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color("secondaryButtonBackground"))
                                        .frame(width: 32, height: 32)
                                    Circle()
                                        .stroke(Color("surfaceBackground"), lineWidth: 2)
                                        .frame(width: 32, height: 32)
                                    Image("camera-filled")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color("primaryIcon"))
                                }
                            }
                            .offset(x: 2, y: 2)
                        }
                    }
                    .padding(.leading, 14)

                    Spacer()
                }
                Spacer()
            }
        }
    }
}

// MARK: - Profile Action Buttons

struct ProfileActionButtons: View {
    let relationshipType: ProfileRelationship
    @Binding var showMessagingThread: Bool

    var body: some View {
        HStack(spacing: 8) {
            switch relationshipType {
            case .currentUser:
                FDSButton(
                    type: .primary,
                    label: "Add to story",
                    icon: "plus-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )

                FDSButton(
                    type: .secondary,
                    label: "Edit profile",
                    icon: "pencil-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )

                FDSButton(
                    type: .secondary,
                    icon: "dots-3-horizontal-filled",
                    size: .medium,
                    widthMode: .constrained,
                    action: {}
                )

            case .friend:
                FDSButton(
                    type: .secondary,
                    label: "Friends",
                    icon: "friend-confirm-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )

                FDSButton(
                    type: .primary,
                    label: "Message",
                    icon: "app-messenger-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: { showMessagingThread = true }
                )

                FDSButton(
                    type: .secondary,
                    icon: "poke-filled",
                    size: .medium,
                    widthMode: .constrained,
                    action: {}
                )

            case .stranger:
                FDSButton(
                    type: .primary,
                    label: "Follow",
                    icon: "follow-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: {}
                )

                FDSButton(
                    type: .secondary,
                    label: "Message",
                    icon: "app-messenger-filled",
                    size: .medium,
                    widthMode: .flexible,
                    action: { showMessagingThread = true }
                )
            }
        }
    }
}

// MARK: - Personal Details Section

struct PersonalDetailsSection: View {
    let profile: ProfileData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Personal details", hierarchyLevel: .level3, rightAddOn: profile.relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 8)

            VStack(spacing: 0) {
                if let currentLocation = profile.currentLocation {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: "Lives in \(currentLocation)",
                        bodyTextColor: .primary,
                        leftAddOn: .icon("pin-outline"),
                        addOnAlignment: .center,
                        showHairline: false,
                        action: {}
                    )
                }

                if let from = profile.from {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: "From \(from)",
                        bodyTextColor: .primary,
                        leftAddOn: .icon("house-outline"),
                        addOnAlignment: .center,
                        showHairline: false,
                        action: {}
                    )
                }

                if let birthday = profile.birthday {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: birthday,
                        bodyTextColor: .primary,
                        leftAddOn: .icon("cake-outline"),
                        addOnAlignment: .center,
                        showHairline: false,
                        action: {}
                    )
                }

                if let relationship = profile.relationship {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: relationship,
                        bodyTextColor: .primary,
                        leftAddOn: .icon("relationship-outline"),
                        addOnAlignment: .center,
                        showHairline: false,
                        action: {}
                    )
                }

                if let gender = profile.gender {
                    HStack(alignment: .center, spacing: 12) {
                        Image("venn-diagram-2-outline")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color("primaryIcon"))
                            .frame(width: 20, height: 20)
                            .frame(width: 20, height: 20, alignment: .center)

                        Text(gender)
                            .body3Typography()
                            .foregroundStyle(Color("primaryText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Tap action
                    }
                }

                if let languages = profile.languages, !languages.isEmpty {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: languages.joined(separator: " · "),
                        bodyTextColor: .primary,
                        leftAddOn: .icon("language-outline"),
                        addOnAlignment: .center,
                        showHairline: false,
                        action: {}
                    )
                }
            }
            .padding(.vertical, profile.relationshipType == .currentUser ? 0 : 8)
        }
    }
}

// MARK: - Work Section

struct WorkSection: View {
    let workExperiences: [WorkExperience]
    let relationshipType: ProfileRelationship

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Work", hierarchyLevel: .level3, rightAddOn: relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 0)

            VStack(spacing: 0) {
                ForEach(workExperiences) { work in
                    let metaTextValue: String? = {
                        if let position = work.position, let years = work.years {
                            return "\(position) · \(years)"
                        } else if let position = work.position {
                            return position
                        } else if let years = work.years {
                            return years
                        }
                        return nil
                    }()
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: work.company,
                        bodyTextColor: .primary,
                        metaText: metaTextValue,
                        leftAddOn: work.image != nil ? .profilePhoto(work.image!, type: .actor, size: .size40) : .containedIcon("briefcase-filled"),
                        addOnAlignment: metaTextValue != nil ? .top : .center,
                        showHairline: false,
                        action: {}
                    )
                }
            }
            .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
        }
    }
}

// MARK: - Education Section

struct EducationSection: View {
    let educationExperiences: [EducationExperience]
    let relationshipType: ProfileRelationship

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Education", hierarchyLevel: .level3, rightAddOn: relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 0)

            VStack(spacing: 0) {
                ForEach(educationExperiences) { education in
                    let metaTextValue = education.years
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: education.school,
                        bodyTextColor: .primary,
                        metaText: metaTextValue,
                        leftAddOn: education.image != nil ? .profilePhoto(education.image!, type: .actor, size: .size40) : .containedIcon("mortar-board-filled"),
                        addOnAlignment: metaTextValue != nil ? .top : .center,
                        showHairline: false,
                        action: {}
                    )
                }
            }
            .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
        }
    }
}

// MARK: - Hobbies Section

struct HobbiesSection: View {
    let hobbies: [HobbyItem]
    let relationshipType: ProfileRelationship

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Hobbies", hierarchyLevel: .level3, rightAddOn: relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 0)

            VStack(spacing: 0) {
                // Group hobbies without descriptions into one line
                let hobbiesWithoutDesc = hobbies.filter { $0.description == nil }
                let hobbiesWithDesc = hobbies.filter { $0.description != nil }
                
                // Show hobbies with descriptions FIRST
                ForEach(Array(hobbiesWithDesc.enumerated()), id: \.element.id) { index, hobby in
                    if let description = hobby.description {
                        if index == 0 {
                            // First hobby with description - use icon
                            FDSListCell(
                                hierarchyLevel: .level3,
                                bodyText: hobby.name,
                                bodyTextColor: .primary,
                                metaText: description,
                                leftAddOn: .icon(hobby.icon ?? "more-shapes-outline"),
                                addOnAlignment: .top,
                                showHairline: false,
                                action: {}
                            )
                        } else {
                            // Subsequent hobbies with description - text pairing with left padding
                            HStack(spacing: 0) {
                                Spacer()
                                    .frame(width: 42)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(hobby.name)
                                        .body3LinkTypography()
                                        .foregroundStyle(Color("primaryText"))

                                    Text(description)
                                        .body4Typography()
                                        .foregroundStyle(Color("primaryText"))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 16)
                                .padding(.trailing, 12)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Tap action
                            }
                        }
                    }
                }
                
                // Show combined hobbies without descriptions LAST
                if !hobbiesWithoutDesc.isEmpty {
                    let combinedNames = hobbiesWithoutDesc.map { $0.name }.joined(separator: " · ")
                    
                    if hobbiesWithDesc.isEmpty {
                        // If no hobbies with descriptions, use icon
                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: combinedNames,
                            bodyTextColor: .primary,
                            leftAddOn: .icon("more-shapes-outline"),
                            showHairline: false,
                            action: {}
                        )
                    } else {
                        // If there are hobbies with descriptions above, use left padding
                        HStack(spacing: 0) {
                            Spacer()
                                .frame(width: 42)
                            Text(combinedNames)
                                .body3LinkTypography()
                                .foregroundStyle(Color("primaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 16)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Tap action
                        }
                    }
                }
            }
            .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
        }
    }
}

// MARK: - Interests Section

struct InterestsSection: View {
    let music: [MusicArtist]
    let tvShows: [TVShow]
    let movies: [Movie]
    let games: [Game]
    let sports: [Sport]
    let relationshipType: ProfileRelationship

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Interests", hierarchyLevel: .level3, rightAddOn: relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 0)

            musicSubsection
            tvShowsSubsection
            moviesSubsection
            gamesSubsection
            sportsSubsection
        }
    }

    @ViewBuilder
    private var musicSubsection: some View {
        if !music.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Music")
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(music) { artist in
                        let metaText: String? = {
                            if artist.name == "Tame Impala" {
                                return "So good"
                            } else if artist.name == "Ain't No Thang • Outkast" {
                                return "Old is gold and this one always takes me back"
                            } else {
                                return nil
                            }
                        }()

                        let leftAddOn: FDSListCellLeftAddOn = {
                            if let image = artist.image {
                                let photoType: FDSListCellProfilePhotoType = artist.name == "Tame Impala" ? .actor : .nonActor
                                return .profilePhoto(image, type: photoType, size: .size40)
                            } else {
                                return .containedIcon("music-filled")
                            }
                        }()

                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: artist.name,
                            bodyTextColor: .primary,
                            metaText: metaText,
                            leftAddOn: leftAddOn,
                            showHairline: false,
                            action: {}
                        )
                    }
                }
                .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
            }
        }
    }

    @ViewBuilder
    private var tvShowsSubsection: some View {
        if !tvShows.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("TV shows")
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(tvShows) { show in
                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: show.name,
                            bodyTextColor: .primary,
                            leftAddOn: show.image != nil ? .profilePhoto(show.image!, type: .nonActor, size: .size40) : .containedIcon("video-filled"),
                            showHairline: false,
                            action: {}
                        )
                    }
                }
                .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
            }
        }
    }

    @ViewBuilder
    private var sportsSubsection: some View {
        if !sports.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Sports teams and athletes")
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(sports) { sport in
                        let leftAddOn: FDSListCellLeftAddOn = {
                            if let image = sport.image {
                                let isActor = sport.name == "U.S. Women's National Soccer team" || sport.name == "Usain Bolt"
                                let photoType: FDSListCellProfilePhotoType = isActor ? .actor : .nonActor
                                return .profilePhoto(image, type: photoType, size: .size40)
                            } else {
                                return .icon("sports-outline")
                            }
                        }()

                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: sport.name,
                            bodyTextColor: .primary,
                            leftAddOn: leftAddOn,
                            showHairline: false,
                            action: {}
                        )
                    }
                }
                .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
            }
        }
    }

    @ViewBuilder
    private var moviesSubsection: some View {
        if !movies.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Movies")
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(movies) { movie in
                        let leftAddOn: FDSListCellLeftAddOn = {
                            if let image = movie.image {
                                return .profilePhoto(image, type: .nonActor, size: .size40)
                            } else {
                                return .containedIcon("film-projector-filled")
                            }
                        }()

                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: movie.name,
                            bodyTextColor: .primary,
                            leftAddOn: leftAddOn,
                            showHairline: false,
                            action: {}
                        )
                    }
                }
                .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
            }
        }
    }

    @ViewBuilder
    private var gamesSubsection: some View {
        if !games.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Games")
                    .headline4DeemphasizedTypography()
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                VStack(spacing: 0) {
                    ForEach(games) { game in
                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: game.name,
                            bodyTextColor: .primary,
                            leftAddOn: game.image != nil ? .profilePhoto(game.image!, type: .nonActor, size: .size40) : .containedIcon("game-controller-filled"),
                            showHairline: false,
                            action: {}
                        )
                    }
                }
                .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
            }
        }
    }
}

// MARK: - Travel Section

struct TravelSection: View {
    let locations: [TravelLocation]
    let relationshipType: ProfileRelationship

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Travel", hierarchyLevel: .level3, rightAddOn: relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 0)

            VStack(spacing: 0) {
                // Show map with travel location pins
                TravelMapView(locations: locations)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)

                if let mostRecent = locations.last {
                    HStack(spacing: 12) {
                        Image("pin-outline")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color("primaryIcon"))

                        HStack(spacing: 0) {
                            Text("Visited \(mostRecent.city), \(mostRecent.country) ")
                                .body3LinkTypography()
                                .foregroundStyle(Color("primaryText"))
                            Text("+ \(locations.count - 1)")
                                .body3Typography()
                                .foregroundStyle(Color("primaryText"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .contentShape(Rectangle())
                    .onTapGesture {}
                }
            }
            .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
        }
    }
}

// MARK: - Travel Map View

struct TravelMapView: View {
    let locations: [TravelLocation]
    
    private var cameraPosition: MapCameraPosition {
        guard !locations.isEmpty else {
            return .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 20.0, longitude: 0.0),
                span: MKCoordinateSpan(latitudeDelta: 80.0, longitudeDelta: 80.0)
            ))
        }
        
        // Calculate bounding box for all locations
        let latitudes = locations.map { $0.latitude }
        let longitudes = locations.map { $0.longitude }
        
        let minLat = latitudes.min() ?? 0
        let maxLat = latitudes.max() ?? 0
        let minLon = longitudes.min() ?? 0
        let maxLon = longitudes.max() ?? 0
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        // Add padding to the span (40% extra on each side)
        let latDelta = max((maxLat - minLat) * 1.4, 10.0)
        let lonDelta = max((maxLon - minLon) * 1.4, 10.0)
        
        return .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        ))
    }

    var body: some View {
        Map(initialPosition: cameraPosition, interactionModes: []) {
            ForEach(locations) { location in
                Annotation("", coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                    ZStack {
                        // White background
                        Image("pin-filled")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)

                        // White circle to fill the center hole
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                            .offset(y: -2)

                        // Blue pin
                        Image("pin-filled")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Contact Info Section

struct ContactInfoSection: View {
    let contactInfo: ContactInfo
    let relationshipType: ProfileRelationship

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Contact info", hierarchyLevel: .level3, rightAddOn: relationshipType == .currentUser ? .iconButton(icon: "pencil-outline", action: {}) : nil)
                .padding(.top, 0)

            VStack(spacing: 0) {
                if let mobile = contactInfo.mobile {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: mobile,
                        bodyTextColor: .primary,
                        leftAddOn: .icon("phone-outline"),
                        showHairline: false,
                        action: {}
                    )
                }

                if let email = contactInfo.email {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: email,
                        bodyTextColor: .primary,
                        leftAddOn: .icon("envelope-outline"),
                        showHairline: false,
                        action: {}
                    )
                }

                if let messenger = contactInfo.messenger {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: messenger,
                        bodyTextColor: .primary,
                        leftAddOn: .icon("app-messenger-outline"),
                        showHairline: false,
                        action: {}
                    )
                }

                if let instagram = contactInfo.instagram {
                    FDSListCell(
                        hierarchyLevel: .level3,
                        bodyText: instagram,
                        bodyTextColor: .primary,
                        leftAddOn: .icon("app-instagram-outline"),
                        showHairline: false,
                        action: {}
                    )
                }

                if let otherContacts = contactInfo.otherContacts, !otherContacts.isEmpty {
                    ForEach(otherContacts, id: \.self) { contact in
                        FDSListCell(
                            hierarchyLevel: .level3,
                            bodyText: contact,
                            bodyTextColor: .primary,
                            leftAddOn: .icon("person-outline"),
                            showHairline: false,
                            action: {}
                        )
                    }
                }
            }
            .padding(.vertical, relationshipType == .currentUser ? 0 : 8)
        }
    }
}

// MARK: - Friends Section

struct FriendsSection: View {
    let friends: [FriendPreview]
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Friends", hierarchyLevel: .level3, rightAddOn: .actionText(label: "See all", action: {}))
                .padding(.top, 0)

            VStack(alignment: .leading, spacing: 0) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6),
                    GridItem(.flexible(), spacing: 6)
                ], spacing: 6) {
                    ForEach(friends) { friend in
                        VStack(spacing: 12) {
                            Image(friend.profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())

                            VStack(alignment: .center, spacing: 10) {
                                Text("\(friend.name) \(friend.lastName)")
                                    .headline4Typography()
                                    .foregroundStyle(Color("primaryText"))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)

                                Text("\(friend.mutualFriendsCount) mutuals")
                                    .meta4Typography()
                                    .foregroundStyle(Color("secondaryText"))
                                    .lineLimit(1)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
        }
    }
}

// MARK: - Highlights Section

struct HighlightsSection: View {
    let highlights: [Highlight]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FDSUnitHeader(headlineText: "Highlights", hierarchyLevel: .level3)
                .padding(.top, 0)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // New highlight entry point
                    Button(action: {}) {
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("cardBackgroundFlat"))
                                .frame(width: 114, height: 203)
                            
                            VStack {
                                Spacer()
                                Image("app-facebook-highlights-filled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(Color("primaryIcon"))
                                Spacer()
                            }
                            .frame(width: 114, height: 203)
                            
                            Text("New\nhighlight")
                                .body4LinkTypography()
                                .foregroundColor(Color("primaryText"))
                                .multilineTextAlignment(.leading)
                                .padding(8)
                        }
                        .frame(width: 114, height: 203)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("mediaInnerBorder"), lineWidth: 1)
                        )
                    }
                    .buttonStyle(FDSPressedState(cornerRadius: 12, scale: .medium))
                    
                    ForEach(highlights) { highlight in
                        ZStack(alignment: .bottomLeading) {
                            Image(highlight.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 114, height: 203)
                                .clipped()
                            
                            VStack {
                                Spacer()
                                ZStack(alignment: .bottomLeading) {
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color("overlayOnMediaLight").opacity(1.0), location: 0.0),
                                            .init(color: Color("overlayOnMediaLight").opacity(0.8), location: 0.3),
                                            .init(color: Color("overlayOnMediaLight").opacity(0.4), location: 0.7),
                                            .init(color: Color("overlayOnMediaLight").opacity(0.0), location: 1.0)
                                        ],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    .frame(height: 60)
                                    
                                    Text(highlight.label)
                                        .body4LinkTypography()
                                        .foregroundColor(Color("primaryTextOnMedia"))
                                        .textOnMediaShadow()
                                        .padding(8)
                                }
                            }
                        }
                        .frame(width: 114, height: 203)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("mediaInnerBorder"), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
        }
    }
}

// MARK: - Wrapping HStack Layout

struct WrappingHStack: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var lineHeight: CGFloat = 0
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView(profile: .currentUser)
    }
    .environmentObject(FDSTabBarHelper())
    .environmentObject(DrawerStateManager())
}
