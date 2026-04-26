//
//  FeedModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class FeedModel {
    var deck: [Outfit] = []
    var itemsByOutfit: [UUID: [ClothingItem]] = [:]
    var profilesByUser: [UUID: Profile] = [:]
    var isLoading = false
    var error: String?

    private let mockStore = MockStore.shared

    func load() {
        isLoading = true
        error = nil

        let outfits = mockStore.feed(limit: 20)
        self.deck = outfits

        for outfit in outfits {
            let items = mockStore.itemsByIds(outfit.itemIds)
            itemsByOutfit[outfit.id] = items

            if profilesByUser[outfit.ownerId] == nil {
                let profile = mockStore.profile(for: outfit.ownerId)
                profilesByUser[outfit.ownerId] = profile
            }
        }

        isLoading = false
    }

    func items(for outfit: Outfit) -> [ClothingItem] {
        itemsByOutfit[outfit.id] ?? []
    }

    func profile(for outfit: Outfit) -> Profile? {
        profilesByUser[outfit.ownerId]
    }

    func react(to outfit: Outfit, kind: ReactionKind) {
        mockStore.react(to: outfit.id, kind: kind)
    }

    func steal(_ outfit: Outfit) {
        mockStore.steal(outfit)
    }

    func hasReacted(to outfit: Outfit) -> Bool {
        mockStore.hasReacted(to: outfit.id)
    }

    var reactedOutfitIds: Set<UUID> {
        mockStore.reactedOutfitIds
    }
}
