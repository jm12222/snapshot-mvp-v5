//
//  FriendRequestData.swift
//  facebook
//
//  Created by Dan Lebowitz on 2/2/26.
//


import SwiftUI

// MARK: - Friend Request Data Model

struct FriendRequestData: Identifiable, Hashable {
    let id = UUID()
    let profileImage: String
    let name: String
    let mutualFriends: Int
    let timeAgo: String
    let mutualFriendImages: [String]
}

// MARK: - Sample Friend Request Data

let sampleFriendRequests = [
    FriendRequestData(
        profileImage: "profile2",
        name: "Bob Johnson",
        mutualFriends: 2,
        timeAgo: "30m",
        mutualFriendImages: ["profile3", "profile4"]
    ),
    FriendRequestData(
        profileImage: "profile3",
        name: "Alice Smith",
        mutualFriends: 86,
        timeAgo: "3h",
        mutualFriendImages: ["profile5", "profile6"]
    )
]

let samplePeopleYouMayKnow = [
    FriendRequestData(
        profileImage: "profile8",
        name: "Jamie Lee",
        mutualFriends: 14,
        timeAgo: "",
        mutualFriendImages: ["profile4", "profile7"]
    ),
    FriendRequestData(
        profileImage: "profile9",
        name: "Fatih Tekin",
        mutualFriends: 8,
        timeAgo: "",
        mutualFriendImages: ["profile5", "profile6"]
    ),
    FriendRequestData(
        profileImage: "profile11",
        name: "Kelsey Fung",
        mutualFriends: 23,
        timeAgo: "",
        mutualFriendImages: ["profile2", "profile3"]
    ),
    FriendRequestData(
        profileImage: "profile5",
        name: "Alex Kim",
        mutualFriends: 19,
        timeAgo: "",
        mutualFriendImages: ["profile3", "profile10"]
    ),
    FriendRequestData(
        profileImage: "profile6",
        name: "Tina Wright",
        mutualFriends: 34,
        timeAgo: "",
        mutualFriendImages: ["profile4", "profile11"]
    ),
    FriendRequestData(
        profileImage: "profile7",
        name: "Marcus Rivera",
        mutualFriends: 5,
        timeAgo: "",
        mutualFriendImages: ["profile2", "profile8"]
    ),
    FriendRequestData(
        profileImage: "profile10",
        name: "Emily Zhang",
        mutualFriends: 41,
        timeAgo: "",
        mutualFriendImages: ["profile5", "profile9"]
    ),
    FriendRequestData(
        profileImage: "profile12",
        name: "Chris Anderson",
        mutualFriends: 17,
        timeAgo: "",
        mutualFriendImages: ["profile3", "profile6"]
    )
]

// MARK: - Friend Request Row Component

struct FriendRequestRow: View {
    let request: FriendRequestData
    let isRequest: Bool // true for friend requests, false for PYMK
    var onDelete: (() -> Void)? = nil
    @State private var isConfirmed = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile Photo
            Image(request.profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 92)
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Name and time
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 0) {
                        Text(request.name)
                            .headline3Typography()
                            .foregroundStyle(Color("primaryText"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                        
                        if !request.timeAgo.isEmpty {
                            Text(request.timeAgo)
                                .body4Typography()
                                .foregroundStyle(Color("secondaryText"))
                        }
                    }
                    
                    // Mutual friends facepile
                    FDSFacepile(
                        profiles: request.mutualFriendImages,
                        size: .small,
                        maxFacepiles: 2,
                        bodyText: AttributedString("\(request.mutualFriends) mutual friends")
                    )
                }
                
                // Action buttons
                HStack(spacing: 8) {
                    FDSButton(
                        type: .primary,
                        label: isRequest ? "Confirm" : "Add friend",
                        size: .medium,
                        widthMode: .flexible,
                        action: {
                            withAnimation(.easeOut(duration: 0.15)) {
                                isConfirmed = true
                            }
                        }
                    )
                    
                    FDSButton(
                        type: .secondary,
                        label: isRequest ? "Delete" : "Remove",
                        size: .medium,
                        widthMode: .flexible,
                        action: {
                            withAnimation(.easeOut(duration: 0.15)) {
                                onDelete?()
                            }
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

// MARK: - Friend Requests View

struct FriendRequestsView: View {
    var bottomPadding: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    @State private var friendRequests: [FriendRequestData] = sampleFriendRequests
    @State private var peopleYouMayKnow: [FriendRequestData] = samplePeopleYouMayKnow
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            FDSNavigationBarCentered(
                title: "Requests",
                backAction: { dismiss() },
                icon3: {
                    FDSIconButton(icon: "magnifying-glass-outline", action: {})
                }
            )
            
            ScrollView {
                VStack(spacing: 0) {
                    // Friend requests section
                    if !friendRequests.isEmpty {
                        VStack(spacing: 0) {
                            FDSUnitHeader(
                                headlineText: "Friend requests",
                                hierarchyLevel: .level2,
                                rightAddOn: .actionText(label: "See all", action: {})
                            )
                            
                            VStack(spacing: 16) {
                                ForEach(friendRequests) { request in
                                    FriendRequestRow(request: request, isRequest: true) {
                                        friendRequests.removeAll { $0.id == request.id }
                                    }
                                    .transition(.opacity)
                                }
                            }
                            .padding(.top, 16)
                        }
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // People you may know section
                    if !peopleYouMayKnow.isEmpty {
                        VStack(spacing: 0) {
                            FDSUnitHeader(
                                headlineText: "People you may know",
                                hierarchyLevel: .level2
                            )
                            
                            VStack(spacing: 16) {
                                ForEach(peopleYouMayKnow) { person in
                                    FriendRequestRow(request: person, isRequest: false) {
                                        peopleYouMayKnow.removeAll { $0.id == person.id }
                                    }
                                    .transition(.opacity)
                                }
                            }
                            .padding(.top, 16)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, bottomPadding)
            }
            .background(Color("surfaceBackground"))
        }
        .background(Color("surfaceBackground"))
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FriendRequestsView()
    }
}
