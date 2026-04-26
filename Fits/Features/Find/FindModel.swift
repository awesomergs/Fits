//
//  FindModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class FindModel {
    var query = ""
    var searchResults: [Profile] = []
    var isSearching = false

    private var debounceTask: Task<Void, Never>?

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
            isSearching = true
            searchResults = MockStore.shared.searchProfiles(trimmed)
                .filter { $0.id != MockStore.shared.currentUser.id }
            isSearching = false
        }
    }

    // MARK: - Category rails

    func railItems(for category: ItemCategory) -> [ClothingItem] {
        MockStore.shared.items.filter { $0.category == category }
    }

    // MARK: - Wishlist

    func isInWishlist(_ item: ClothingItem) -> Bool {
        MockStore.shared.myItems(wishlist: true)
            .contains { $0.sourceItemId == item.id }
    }

    func addToWishlist(_ item: ClothingItem) {
        guard !isInWishlist(item) else { return }
        let copy = ClothingItem(
            ownerId: MockStore.shared.currentUser.id,
            imageUrl: item.imageUrl,
            category: item.category,
            isWishlist: true,
            sourceItemId: item.id
        )
        MockStore.shared.addItem(copy, image: MockStore.shared.imageCache[item.id])
    }
}
