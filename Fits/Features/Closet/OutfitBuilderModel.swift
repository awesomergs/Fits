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

    private let supabase = SupabaseService.shared

    var availableCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    var canPublish: Bool { !picks.isEmpty && !isPublishing }

    func load() async {
        do {
            allItems = try await supabase.myItems(wishlist: false)
        } catch {
            print("OutfitBuilder load failed: \(error)")
            self.error = error.localizedDescription
        }
    }

    func items(for category: ItemCategory) -> [ClothingItem] {
        allItems.filter { $0.category == category }
    }

    func publish() async {
        guard canPublish, let userId = supabase.currentUserId else { return }
        isPublishing = true
        error = nil

        let outfit = Outfit(
            ownerId: userId,
            occasion: selectedOccasion,
            itemIds: picks.values.map(\.id),
            published: true
        )

        do {
            try await supabase.publishOutfit(outfit)
            isPublishing = false
            showSuccessToast = true
            try? await Task.sleep(for: .seconds(1.5))
            showSuccessToast = false
        } catch {
            print("Publish failed: \(error)")
            self.error = error.localizedDescription
            isPublishing = false
        }
    }
}
