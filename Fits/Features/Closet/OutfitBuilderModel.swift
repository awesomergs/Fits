//
//  OutfitBuilderModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class OutfitBuilderModel {
    var picks: [ItemCategory: ClothingItem] = [:]
    var selectedOccasion = "Casual"
    var allItems: [ClothingItem] = []
    var isPublishing = false
    var showSuccessToast = false
    var error: String?

    let occasions = ["Casual", "Streetwear", "Work", "Date Night", "Gala"]

    private let mockStore = MockStore.shared

    var availableCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    var canPublish: Bool { !picks.isEmpty && !isPublishing }

    func load() {
        allItems = mockStore.myItems(wishlist: false)
    }

    func items(for category: ItemCategory) -> [ClothingItem] {
        allItems.filter { $0.category == category }
    }

    func publish() {
        guard canPublish else { return }
        isPublishing = true
        error = nil

        let outfit = Outfit(
            ownerId: mockStore.currentUser.id,
            occasion: selectedOccasion,
            itemIds: picks.values.map { $0.id },
            published: true
        )

        mockStore.publishOutfit(outfit)
        isPublishing = false
        showSuccessToast = true
    }
}
