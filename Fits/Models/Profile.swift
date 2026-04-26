//
//  Profile.swift
//  Fits
//

import Foundation

struct Profile: Codable, Identifiable, Hashable {
    let id: UUID
    let username: String
    let handle: String
    let avatarUrl: String?
    let bio: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, username, handle, bio
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }

    init(
        id: UUID,
        username: String,
        handle: String,
        avatarUrl: String? = nil,
        bio: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.username = username
        self.handle = handle
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.createdAt = createdAt
    }
}
