//
//  ClothingItem.swift
//  Fits
//

import Foundation

enum ItemCategory: String, CaseIterable, Hashable {
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

struct ClothingItem: Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    let imageUrl: String
    let category: ItemCategory
    let isWishlist: Bool
    let sourceItemId: UUID?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        ownerId: UUID,
        imageUrl: String,
        category: ItemCategory,
        isWishlist: Bool = false,
        sourceItemId: UUID? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.ownerId = ownerId
        self.imageUrl = imageUrl
        self.category = category
        self.isWishlist = isWishlist
        self.sourceItemId = sourceItemId
        self.createdAt = createdAt
    }
}
