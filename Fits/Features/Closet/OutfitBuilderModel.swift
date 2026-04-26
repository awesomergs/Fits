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
    var isPublishing = false
    var showSuccessToast = false

    let occasions = ["Casual", "Streetwear", "Work", "Date Night", "Gala"]

    // Categories that have at least one owned item to pick from
    var availableCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    var canPublish: Bool { !picks.isEmpty && !isPublishing }

    func items(for category: ItemCategory) -> [ClothingItem] {
        MockStore.shared.myItems().filter { $0.category == category }
    }

    func publish() async {
        guard canPublish else { return }
        isPublishing = true

        let outfit = Outfit(
            ownerId: MockStore.shared.currentUser.id,
            occasion: selectedOccasion,
            itemIds: picks.values.map(\.id),
            published: true
        )
        MockStore.shared.publishOutfit(outfit)

        isPublishing = false
        showSuccessToast = true
        try? await Task.sleep(for: .seconds(1.5))
        showSuccessToast = false
    }
}
