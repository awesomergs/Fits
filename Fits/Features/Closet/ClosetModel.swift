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
        let owned = mockStore.myItems(wishlist: false)
        let wishlist = mockStore.myItems(wishlist: true)

        var seen = Set<String>()
        return (owned + wishlist)
            .filter { seen.insert($0.imageUrl).inserted }
    }

    var myOutfits: [Outfit] {
        mockStore.outfitsByUser(mockStore.currentUser.id)
    }

    var itemsByOutfitId: [UUID: [ClothingItem]] {
        Dictionary(uniqueKeysWithValues: myOutfits.map { ($0.id, mockStore.itemsByIds($0.itemIds)) })
    }

    var populatedCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    func items(for category: ItemCategory) -> [ClothingItem] {
        allItems.filter { $0.category == category }
    }

    func items(for outfit: Outfit) -> [ClothingItem] {
        itemsByOutfitId[outfit.id] ?? mockStore.itemsByIds(outfit.itemIds)
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
