//
//  ClothingItem.swift
//  Fits
//

import Foundation

enum ItemCategory: String, Codable, CaseIterable, Hashable {
    case top, bottom, outerwear, shoes, accessory
    case fullBody = "full_body"

    var displayName: String {
        switch self {
        case .top:       "Tops"
        case .bottom:    "Bottoms"
        case .outerwear: "Outerwear"
        case .shoes:     "Shoes"
        case .accessory: "Accessories"
        case .fullBody:  "Full Body"
        }
    }
}

struct ClothingItem: Codable, Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let imageUrl: String
    let category: ItemCategory
    let occasionTags: [String]
    let isWishlist: Bool
    let sourceItemId: UUID?
    let sourceShop: String?
    let sourceUrl: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, category
        case ownerId = "owner_id"
        case imageUrl = "image_url"
        case occasionTags = "occasion_tags"
        case isWishlist = "is_wishlist"
        case sourceItemId = "source_item_id"
        case sourceShop = "source_shop"
        case sourceUrl = "source_url"
        case createdAt = "created_at"
    }

    init(
        id: UUID = UUID(),
        ownerId: UUID,
        imageUrl: String,
        category: ItemCategory,
        occasionTags: [String] = [],
        isWishlist: Bool = false,
        sourceItemId: UUID? = nil,
        sourceShop: String? = nil,
        sourceUrl: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.ownerId = ownerId
        self.imageUrl = imageUrl
        self.category = category
        self.occasionTags = occasionTags
        self.isWishlist = isWishlist
        self.sourceItemId = sourceItemId
        self.sourceShop = sourceShop
        self.sourceUrl = sourceUrl
        self.createdAt = createdAt
    }
}
