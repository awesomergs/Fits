//
//  Outfit.swift
//  Fits
//

import Foundation

struct Outfit: Codable, Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let occasion: String
    let itemIds: [UUID]
    let caption: String?
    let published: Bool
    let createdAt: Date
    let hotness: Double

    enum CodingKeys: String, CodingKey {
        case id, occasion, caption, published, hotness
        case ownerId = "owner_id"
        case itemIds = "item_ids"
        case createdAt = "created_at"
    }

    init(
        id: UUID = UUID(),
        ownerId: UUID,
        occasion: String,
        itemIds: [UUID],
        caption: String? = nil,
        published: Bool = false,
        createdAt: Date = .now,
        hotness: Double = 0.5
    ) {
        self.id = id
        self.ownerId = ownerId
        self.occasion = occasion
        self.itemIds = itemIds
        self.caption = caption
        self.published = published
        self.createdAt = createdAt
        self.hotness = hotness
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(UUID.self,    forKey: .id)
        ownerId   = try c.decode(UUID.self,    forKey: .ownerId)
        occasion  = try c.decode(String.self,  forKey: .occasion)
        itemIds   = try c.decode([UUID].self,  forKey: .itemIds)
        caption   = try c.decodeIfPresent(String.self, forKey: .caption)
        published = try c.decode(Bool.self,    forKey: .published)
        createdAt = try c.decode(Date.self,    forKey: .createdAt)
        hotness   = try c.decodeIfPresent(Double.self, forKey: .hotness) ?? 0.5
    }
}
