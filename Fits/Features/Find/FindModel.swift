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
    var railItems: [ItemCategory: [ClothingItem]] = [:]
    var wishlistItemIds: Set<UUID> = []
    var isSearching = false
    var error: String?

    private let mockStore = MockStore.shared

    // MARK: - Search

    func search(_ newQuery: String) {
        query = newQuery

        let trimmed = newQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        let profiles = mockStore.searchProfiles(trimmed)
        searchResults = profiles.filter { $0.id != mockStore.currentUser.id }
        isSearching = false
    }

    // MARK: - Rails

    func loadRailItems(for category: ItemCategory) {
        railItems[category] = mockStore.items.filter { $0.category == category && !$0.isWishlist }
    }

    func railItems(for category: ItemCategory) -> [ClothingItem] {
        railItems[category] ?? []
    }

    // MARK: - Wishlist

    func loadWishlist() {
        let wishlisted = mockStore.myItems(wishlist: true)
        wishlistItemIds = Set(wishlisted.compactMap { $0.sourceItemId })
    }

    func addToWishlist(_ item: ClothingItem) {
        guard !wishlistItemIds.contains(item.id) else { return }

        let copy = ClothingItem(
            ownerId: mockStore.currentUser.id,
            imageUrl: item.imageUrl,
            category: item.category,
            isWishlist: true,
            sourceItemId: item.id
        )

        mockStore.addItem(copy)
        wishlistItemIds.insert(item.id)
    }

    func isInWishlist(_ item: ClothingItem) -> Bool {
        wishlistItemIds.contains(item.id)
    }
}
