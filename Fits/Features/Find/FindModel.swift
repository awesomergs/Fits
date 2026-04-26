//
//  FindModel.swift
//  Fits
//

import Foundation
import Observation

@MainActor
@Observable
final class FindModel {
    var query = ""
    var searchResults: [Profile] = []

    // ✅ FIX: store rails per category
    var railItems: [ItemCategory: [ClothingItem]] = [:]

    var wishlistItemIds: Set<UUID> = []
    var isSearching = false
    var error: String?

    private var debounceTask: Task<Void, Never>?
    private let supabase = SupabaseService.shared

    // MARK: - Search

    func search(_ newQuery: String) {
        query = newQuery
        debounceTask?.cancel()

        let trimmed = newQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        debounceTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            do {
                isSearching = true
                let profiles = try await supabase.searchProfiles(trimmed)

                guard let userId = supabase.currentUserId else { return }
                searchResults = profiles.filter { $0.id != userId }

                isSearching = false
            } catch {
                print("Profile search failed: \(error)")
                self.error = error.localizedDescription
                isSearching = false
            }
        }
    }

    // MARK: - Rails

    func loadRailItems(for category: ItemCategory) async {
        do {
            let items = try await supabase.myItems(wishlist: false)

            // ✅ FIX: store per category instead of overwriting
            railItems[category] = items.filter { $0.category == category }

        } catch {
            print("Failed to load rail items: \(error)")
            self.error = error.localizedDescription
        }
    }

    // ✅ FIX: function expected by the View
    func railItems(for category: ItemCategory) -> [ClothingItem] {
        railItems[category] ?? []
    }

    // MARK: - Wishlist

    func loadWishlist() async {
        do {
            let wishlisted = try await supabase.myItems(wishlist: true)
            wishlistItemIds = Set(wishlisted.compactMap { $0.sourceItemId })
        } catch {
            print("Failed to load wishlist: \(error)")
            self.error = error.localizedDescription
        }
    }

    func addToWishlist(_ item: ClothingItem) async {
        guard !wishlistItemIds.contains(item.id) else { return }

        let copy = ClothingItem(
            ownerId: item.ownerId,
            imageUrl: item.imageUrl,
            category: item.category,
            isWishlist: true,
            sourceItemId: item.id
        )

        do {
            try await supabase.createItem(copy)
            wishlistItemIds.insert(item.id)
        } catch {
            print("Failed to add to wishlist: \(error)")
            self.error = error.localizedDescription
        }
    }

    // ✅ FIX: function expected by the View
    func isInWishlist(_ item: ClothingItem) -> Bool {
        wishlistItemIds.contains(item.id)
    }
}
