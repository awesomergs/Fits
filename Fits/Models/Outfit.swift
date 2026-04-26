//
//  Outfit.swift
//  Fits
//

import Foundation

struct Outfit: Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let occasion: String
    let itemIds: [UUID]
    let caption: String?
    let published: Bool
    let createdAt: Date

    init(
        id: UUID = UUID(),
        ownerId: UUID,
        occasion: String,
        itemIds: [UUID],
        caption: String? = nil,
        published: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.ownerId = ownerId
        self.occasion = occasion
        self.itemIds = itemIds
        self.caption = caption
        self.published = published
        self.createdAt = createdAt
    }
}
