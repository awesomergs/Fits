//
//  ClosetModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class ClosetModel {
    private let mockStore = MockStore.shared

    var allItems: [ClothingItem] {
        mockStore.myItems(wishlist: false)
    }

    var populatedCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    func items(for category: ItemCategory) -> [ClothingItem] {
        allItems.filter { $0.category == category }
    }

    var isEmpty: Bool {
        allItems.isEmpty
    }

    func publishOutfit(
        occasion: String,
        itemIds: [UUID],
        caption: String? = nil
    ) {
        let outfit = Outfit(
            ownerId: mockStore.currentUser.id,
            occasion: occasion,
            itemIds: itemIds,
            caption: caption,
            published: true
        )
        mockStore.publishOutfit(outfit)
    }
}
