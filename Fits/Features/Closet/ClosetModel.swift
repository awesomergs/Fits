//
//  ClosetModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class ClosetModel {
    var allItems: [ClothingItem] = []
    var isLoading = false
    var error: String?

    private let supabase = SupabaseService.shared

    var populatedCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    func items(for category: ItemCategory) -> [ClothingItem] {
        allItems.filter { $0.category == category }
    }

    var isEmpty: Bool {
        allItems.isEmpty
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            allItems = try await supabase.myItems(wishlist: false)
            isLoading = false
        } catch {
            print("Failed to load closet: \(error)")
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func loadWishlist() async {
        do {
            allItems = try await supabase.myItems(wishlist: true)
        } catch {
            print("Failed to load wishlist: \(error)")
            self.error = error.localizedDescription
        }
    }

    func publishOutfit(
        occasion: String,
        itemIds: [UUID],
        caption: String? = nil
    ) async {
        guard let userId = supabase.currentUserId else {
            error = "Not authenticated"
            return
        }

        let outfit = Outfit(
            ownerId: userId,
            occasion: occasion,
            itemIds: itemIds,
            caption: caption,
            published: true
        )

        do {
            try await supabase.publishOutfit(outfit)
        } catch {
            print("Failed to publish outfit: \(error)")
            self.error = error.localizedDescription
        }
    }
}
