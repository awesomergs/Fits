//
//  FeedModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class FeedModel {
    var deck: [Outfit] = []
    var isLoading = false

    func load() {
        isLoading = true
        deck = MockStore.shared.feed()
        isLoading = false
    }

    // Hydration helpers — read through the store so observation tracks correctly
    func items(for outfit: Outfit) -> [ClothingItem] {
        MockStore.shared.itemsByIds(outfit.itemIds)
    }

    func profile(for outfit: Outfit) -> Profile? {
        MockStore.shared.profile(for: outfit.ownerId)
    }

    // MARK: - Actions (UI triggers wired in Parts 2 & 3)

    func react(to outfit: Outfit, kind: ReactionKind) {
        deck.removeFirst()
        MockStore.shared.react(to: outfit.id, kind: kind)
    }

    func steal(_ outfit: Outfit) {
        MockStore.shared.steal(outfit)
    }
}
