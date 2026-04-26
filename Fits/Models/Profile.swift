//
//  Profile.swift
//  Fits
//

import Foundation

struct Profile: Identifiable, Hashable {
    let id: UUID
    let username: String
    let handle: String
    let avatarUrl: String?
    let bio: String?
    let followerCount: Int
    let followingCount: Int
    let createdAt: Date

    init(
        id: UUID,
        username: String,
        handle: String,
        avatarUrl: String? = nil,
        bio: String? = nil,
        followerCount: Int = 0,
        followingCount: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.username = username
        self.handle = handle
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.createdAt = createdAt
    }
}
