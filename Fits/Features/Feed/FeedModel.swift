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

    private let supabase = SupabaseService.shared

    func load() async {
        isLoading = true
        error = nil

        do {
            let outfits = try await supabase.feed(limit: 20)
            self.deck = outfits

            for outfit in outfits {
                let items = try await supabase.itemsByIds(outfit.itemIds)
                itemsByOutfit[outfit.id] = items

                if profilesByUser[outfit.ownerId] == nil {
                    let profile = try await supabase.profile(for: outfit.ownerId)
                    profilesByUser[outfit.ownerId] = profile
                }
            }

            isLoading = false
        } catch {
            print("Feed load failed: \(error)")
            self.error = error.localizedDescription
            isLoading = false
        }
    }

    func items(for outfit: Outfit) -> [ClothingItem] {
        itemsByOutfit[outfit.id] ?? []
    }

    func profile(for outfit: Outfit) -> Profile? {
        profilesByUser[outfit.ownerId]
    }

    func react(to outfit: Outfit, kind: ReactionKind) async {
        deck.removeAll { $0.id == outfit.id }
        do {
            try await supabase.react(targetType: "outfit", targetId: outfit.id, kind: kind)
        } catch {
            print("React failed: \(error)")
            self.error = error.localizedDescription
            deck.insert(outfit, at: 0)
        }
    }

    func steal(_ outfit: Outfit) async {
        do {
            let sourceItems = items(for: outfit)
            try await supabase.stealOutfit(outfit, sourceItems: sourceItems)
        } catch {
            print("Steal failed: \(error)")
            self.error = error.localizedDescription
        }
    }

    func hasReacted(to outfit: Outfit) -> Bool {
        reactedOutfitIds.contains(outfit.id)
    }

    var reactedOutfitIds: Set<UUID> = []
}
