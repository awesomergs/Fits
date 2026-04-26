//
//  MockStore.swift
//  Fits
//

import Foundation
import Observation
import UIKit

// Replaces SupabaseService during the mock phase.
// All state is in-memory; mutations are immediate.
// When wiring Supabase, replace each method body — callers stay the same.

@Observable
final class MockStore {
    static let shared = MockStore()

    private(set) var profiles: [Profile] = []
    private(set) var items: [ClothingItem] = []
    private(set) var outfits: [Outfit] = []
    private(set) var followedIds: Set<UUID> = []
    private(set) var reactedOutfitIds: Set<UUID> = []   // liked or disliked
    private(set) var stolenOutfitIds: Set<UUID> = []
    // Keyed by ClothingItem.id — holds locally tagged images that have no network URL yet
    private(set) var imageCache: [UUID: UIImage] = [:]

    private(set) var currentUser: Profile

    private init() {
        // ── Profiles ──────────────────────────────────────────────────────────
        let me = Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            username: "You",
            handle: "you",
            avatarUrl: "https://i.pravatar.cc/150?img=1",
            followerCount: 3,
            followingCount: 3
        )
        let aria = Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            username: "Aria Chen",
            handle: "aria",
            avatarUrl: "https://i.pravatar.cc/150?img=47",
            bio: "streetwear always",
            followerCount: 2841,
            followingCount: 312,
            createdAt: .distantPast
        )
        let kai = Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            username: "Kai Rivera",
            handle: "kai",
            avatarUrl: "https://i.pravatar.cc/150?img=68",
            bio: "minimal · clean · quiet",
            followerCount: 1504,
            followingCount: 88,
            createdAt: .distantPast
        )
        let jules = Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            username: "Jules Moreau",
            handle: "jules",
            avatarUrl: "https://i.pravatar.cc/150?img=25",
            bio: "bold or nothing",
            followerCount: 3217,
            followingCount: 501,
            createdAt: .distantPast
        )

        currentUser = me
        profiles = [me, aria, kai, jules]

        // ── Aria's items (streetwear) ─────────────────────────────────────────
        let ariaTop = ClothingItem(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000001")!,
            ownerId: aria.id,
            imageUrl: "https://picsum.photos/seed/aria-top/300/400",
            category: .top
        )
        let ariaBottom = ClothingItem(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000002")!,
            ownerId: aria.id,
            imageUrl: "https://picsum.photos/seed/aria-bottom/300/400",
            category: .bottom
        )
        let ariaOuter = ClothingItem(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000003")!,
            ownerId: aria.id,
            imageUrl: "https://picsum.photos/seed/aria-outer/300/400",
            category: .outerwear
        )
        let ariaShoes = ClothingItem(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000004")!,
            ownerId: aria.id,
            imageUrl: "https://picsum.photos/seed/aria-shoes/300/400",
            category: .shoes
        )
        let ariaAcc = ClothingItem(
            id: UUID(uuidString: "A1000000-0000-0000-0000-000000000005")!,
            ownerId: aria.id,
            imageUrl: "https://picsum.photos/seed/aria-acc/300/400",
            category: .accessory,
            isWishlist: true
        )

        // ── Kai's items (minimal) ─────────────────────────────────────────────
        let kaiTop = ClothingItem(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000001")!,
            ownerId: kai.id,
            imageUrl: "https://picsum.photos/seed/kai-top/300/400",
            category: .top
        )
        let kaiBottom = ClothingItem(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000002")!,
            ownerId: kai.id,
            imageUrl: "https://picsum.photos/seed/kai-bottom/300/400",
            category: .bottom
        )
        let kaiOuter = ClothingItem(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000003")!,
            ownerId: kai.id,
            imageUrl: "https://picsum.photos/seed/kai-outer/300/400",
            category: .outerwear,
            isWishlist: true
        )
        let kaiShoes = ClothingItem(
            id: UUID(uuidString: "B1000000-0000-0000-0000-000000000004")!,
            ownerId: kai.id,
            imageUrl: "https://picsum.photos/seed/kai-shoes/300/400",
            category: .shoes
        )

        // ── Jules's items (statement) ─────────────────────────────────────────
        let julesTop = ClothingItem(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000001")!,
            ownerId: jules.id,
            imageUrl: "https://picsum.photos/seed/jules-top/300/400",
            category: .top
        )
        let julesBottom = ClothingItem(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000002")!,
            ownerId: jules.id,
            imageUrl: "https://picsum.photos/seed/jules-bottom/300/400",
            category: .bottom
        )
        let julesShoes = ClothingItem(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000003")!,
            ownerId: jules.id,
            imageUrl: "https://picsum.photos/seed/jules-shoes/300/400",
            category: .shoes
        )
        let julesOuter = ClothingItem(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000004")!,
            ownerId: jules.id,
            imageUrl: "https://picsum.photos/seed/jules-outer/300/400",
            category: .outerwear
        )
        let julesAcc = ClothingItem(
            id: UUID(uuidString: "C1000000-0000-0000-0000-000000000005")!,
            ownerId: jules.id,
            imageUrl: "https://picsum.photos/seed/jules-acc/300/400",
            category: .accessory
        )

        items = [
            ariaTop, ariaBottom, ariaOuter, ariaShoes, ariaAcc,
            kaiTop, kaiBottom, kaiOuter, kaiShoes,
            julesTop, julesBottom, julesShoes, julesOuter, julesAcc
        ]

        // ── Seeded outfits ────────────────────────────────────────────────────
        // outfit1 is the curated "Steal this fit" target on the Feed
        let outfit1 = Outfit(
            id: UUID(uuidString: "F0000000-0000-0000-0000-000000000001")!,
            ownerId: aria.id,
            occasion: "Streetwear",
            itemIds: [ariaTop.id, ariaBottom.id, ariaShoes.id, ariaOuter.id],
            caption: "weekend fit 🖤",
            published: true,
            createdAt: Date(timeIntervalSinceNow: -3600)
        )
        let outfit2 = Outfit(
            id: UUID(uuidString: "F0000000-0000-0000-0000-000000000002")!,
            ownerId: kai.id,
            occasion: "Work",
            itemIds: [kaiTop.id, kaiBottom.id, kaiShoes.id],
            caption: "office ready",
            published: true,
            createdAt: Date(timeIntervalSinceNow: -7200)
        )
        let outfit3 = Outfit(
            id: UUID(uuidString: "F0000000-0000-0000-0000-000000000003")!,
            ownerId: jules.id,
            occasion: "Date Night",
            itemIds: [julesTop.id, julesBottom.id, julesShoes.id, julesAcc.id],
            caption: "going out going out",
            published: true,
            createdAt: Date(timeIntervalSinceNow: -10800)
        )

        outfits = [outfit1, outfit2, outfit3]

        // ── Follows: current user follows all 3 demo accounts ────────────────
        followedIds = [aria.id, kai.id, jules.id]
    }

    // MARK: - Items

    func myItems(wishlist: Bool? = nil) -> [ClothingItem] {
        let mine = items.filter { $0.ownerId == currentUser.id }
        guard let wishlist else { return mine }
        return mine.filter { $0.isWishlist == wishlist }
    }

    func itemsForUser(_ userId: UUID) -> [ClothingItem] {
        items.filter { $0.ownerId == userId }
    }

    func itemsByIds(_ ids: [UUID]) -> [ClothingItem] {
        let set = Set(ids)
        return items.filter { set.contains($0.id) }
    }

    func addItem(_ item: ClothingItem, image: UIImage? = nil) {
        items.append(item)
        if let image { imageCache[item.id] = image }
    }

    func batchAddItems(_ newItems: [ClothingItem]) {
        items.append(contentsOf: newItems)
    }

    // MARK: - Outfits

    /// Published outfits from followed users, newest first.
    func feed(limit: Int = 20) -> [Outfit] {
        outfits
            .filter { $0.published && followedIds.contains($0.ownerId) }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func outfitsByUser(_ userId: UUID) -> [Outfit] {
        outfits.filter { $0.ownerId == userId && $0.published }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func publishOutfit(_ outfit: Outfit) {
        outfits.append(outfit)
    }

    // MARK: - Reactions

    func hasReacted(to outfitId: UUID) -> Bool {
        reactedOutfitIds.contains(outfitId)
    }

    func react(to outfitId: UUID, kind: ReactionKind) {
        reactedOutfitIds.insert(outfitId)
    }

    func hasStolen(_ outfitId: UUID) -> Bool {
        stolenOutfitIds.contains(outfitId)
    }

    func steal(_ outfit: Outfit) {
        guard !stolenOutfitIds.contains(outfit.id) else { return }
        let newItems = itemsByIds(outfit.itemIds).map { source in
            ClothingItem(
                ownerId: currentUser.id,
                imageUrl: source.imageUrl,
                category: source.category,
                isWishlist: true,
                sourceItemId: source.id
            )
        }
        batchAddItems(newItems)
        stolenOutfitIds.insert(outfit.id)
    }

    // MARK: - Profiles

    func profile(for userId: UUID) -> Profile? {
        profiles.first { $0.id == userId }
    }

    func searchProfiles(_ query: String) -> [Profile] {
        let q = query.lowercased()
        return profiles.filter {
            $0.handle.localizedCaseInsensitiveContains(q) ||
            $0.username.localizedCaseInsensitiveContains(q)
        }
    }

    // MARK: - Follows

    func isFollowing(_ userId: UUID) -> Bool {
        followedIds.contains(userId)
    }

    func follow(_ userId: UUID) {
        followedIds.insert(userId)
    }

    func unfollow(_ userId: UUID) {
        followedIds.remove(userId)
    }
}
