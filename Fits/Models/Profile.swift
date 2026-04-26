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
    let createdAt: Date
}
