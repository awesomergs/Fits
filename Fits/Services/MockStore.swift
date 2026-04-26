//
//  MockStore.swift
//  Fits
//

import Foundation
import Observation
import UIKit

@Observable
final class MockStore {
    static let shared = MockStore()

    private(set) var profiles: [Profile] = []
    private(set) var items: [ClothingItem] = []
    private(set) var outfits: [Outfit] = []
    private(set) var followedIds: Set<UUID> = []
    private(set) var reactedOutfitIds: Set<UUID> = []
    private(set) var stolenOutfitIds: Set<UUID> = []
    private(set) var imageCache: [UUID: UIImage] = [:]

    private(set) var currentUser: Profile

    private init() {

        // MARK: - Profiles

        let me = Profile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            username: "You",
            handle: "you",
            avatarUrl: "https://i.pravatar.cc/150?img=1"
        )

        let aria = Profile(id: UUID(), username: "Aria Chen", handle: "aria", avatarUrl: "https://i.pravatar.cc/150?img=47", bio: "streetwear always")
        let kai = Profile(id: UUID(), username: "Kai Rivera", handle: "kai", avatarUrl: "https://i.pravatar.cc/150?img=68", bio: "minimal · clean")
        let jules = Profile(id: UUID(), username: "Jules Moreau", handle: "jules", avatarUrl: "https://i.pravatar.cc/150?img=25", bio: "bold or nothing")
        let lena = Profile(id: UUID(), username: "Lena Park", handle: "lena", avatarUrl: "https://i.pravatar.cc/150?img=12", bio: "soft neutrals")
        let marcus = Profile(id: UUID(), username: "Marcus Lee", handle: "marcus", avatarUrl: "https://i.pravatar.cc/150?img=33", bio: "techwear")
        let ivy = Profile(id: UUID(), username: "Ivy Stone", handle: "ivy", avatarUrl: "https://i.pravatar.cc/150?img=15", bio: "thrift queen")

        currentUser = me
        profiles = [me, aria, kai, jules, lena, marcus, ivy]

        // MARK: - Item helper

        func makeItem(owner: Profile, category: ItemCategory, seed: String, wishlist: Bool = false) -> ClothingItem {
            ClothingItem(
                id: UUID(),
                ownerId: owner.id,
                imageUrl: "https://picsum.photos/seed/\(seed)/300/400",
                category: category,
                isWishlist: wishlist
            )
        }

        // MARK: - Items

        let allItems: [ClothingItem] = [

            // Me
            makeItem(owner: me, category: .top, seed: "me1"),
            makeItem(owner: me, category: .bottom, seed: "me2"),
            makeItem(owner: me, category: .outerwear, seed: "me3"),
            makeItem(owner: me, category: .shoes, seed: "me4"),
            makeItem(owner: me, category: .accessory, seed: "me5"),

            // Aria
            makeItem(owner: aria, category: .top, seed: "aria1"),
            makeItem(owner: aria, category: .bottom, seed: "aria2"),
            makeItem(owner: aria, category: .outerwear, seed: "aria3"),
            makeItem(owner: aria, category: .shoes, seed: "aria4"),
            makeItem(owner: aria, category: .accessory, seed: "aria5", wishlist: true),

            // Kai
            makeItem(owner: kai, category: .top, seed: "kai1"),
            makeItem(owner: kai, category: .bottom, seed: "kai2"),
            makeItem(owner: kai, category: .outerwear, seed: "kai3"),
            makeItem(owner: kai, category: .shoes, seed: "kai4"),

            // Jules
            makeItem(owner: jules, category: .top, seed: "jules1"),
            makeItem(owner: jules, category: .bottom, seed: "jules2"),
            makeItem(owner: jules, category: .shoes, seed: "jules3"),
            makeItem(owner: jules, category: .outerwear, seed: "jules4"),
            makeItem(owner: jules, category: .accessory, seed: "jules5"),

            // Lena
            makeItem(owner: lena, category: .top, seed: "lena1"),
            makeItem(owner: lena, category: .bottom, seed: "lena2"),
            makeItem(owner: lena, category: .shoes, seed: "lena3"),

            // Marcus
            makeItem(owner: marcus, category: .top, seed: "marcus1"),
            makeItem(owner: marcus, category: .bottom, seed: "marcus2"),
            makeItem(owner: marcus, category: .outerwear, seed: "marcus3"),
            makeItem(owner: marcus, category: .shoes, seed: "marcus4"),

            // Ivy
            makeItem(owner: ivy, category: .top, seed: "ivy1"),
            makeItem(owner: ivy, category: .bottom, seed: "ivy2"),
            makeItem(owner: ivy, category: .accessory, seed: "ivy3"),
        ]

        items = allItems

        // MARK: - Outfit helper

        func makeOutfit(owner: Profile, itemPool: [ClothingItem], caption: String, occasion: String, hoursAgo: Double, hotness: Double = 0.5) -> Outfit {
            Outfit(
                id: UUID(),
                ownerId: owner.id,
                occasion: occasion,
                itemIds: itemPool.shuffled().prefix(3).map { $0.id },
                caption: caption,
                published: true,
                createdAt: Date(timeIntervalSinceNow: -hoursAgo * 3600),
                hotness: hotness
            )
        }

        // MARK: - Outfits

        outfits = [
            makeOutfit(owner: aria,   itemPool: allItems, caption: "weekend fit 🖤",   occasion: "Streetwear", hoursAgo: 1, hotness: 0.82),
            makeOutfit(owner: kai,    itemPool: allItems, caption: "clean lines only", occasion: "Work",       hoursAgo: 2, hotness: 0.55),
            makeOutfit(owner: jules,  itemPool: allItems, caption: "loud energy",      occasion: "Night Out",  hoursAgo: 3, hotness: 0.73),
            makeOutfit(owner: lena,   itemPool: allItems, caption: "soft tones",       occasion: "Casual",     hoursAgo: 5, hotness: 0.35),
            makeOutfit(owner: marcus, itemPool: allItems, caption: "tech mode",        occasion: "City",       hoursAgo: 6, hotness: 0.48),
            makeOutfit(owner: ivy,    itemPool: allItems, caption: "thrifted gems",    occasion: "Vintage",    hoursAgo: 8, hotness: 0.28)
        ]

        // MARK: - Follows

        followedIds = Set(profiles.filter { $0.id != me.id }.map { $0.id })
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

    func feed(limit: Int = 20) -> [Outfit] {
        outfits
            .filter { followedIds.contains($0.ownerId) }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func outfitsByUser(_ userId: UUID) -> [Outfit] {
        outfits.filter { $0.ownerId == userId }
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

        let newItems = itemsByIds(outfit.itemIds).map {
            ClothingItem(
                ownerId: currentUser.id,
                imageUrl: $0.imageUrl,
                category: $0.category,
                isWishlist: false,
                sourceItemId: $0.id
            )
        }

        batchAddItems(newItems)

        let savedOutfit = Outfit(
            ownerId: currentUser.id,
            occasion: outfit.occasion,
            itemIds: newItems.map { $0.id },
            caption: outfit.caption,
            published: true,
            hotness: outfit.hotness
        )
        publishOutfit(savedOutfit)

        stolenOutfitIds.insert(outfit.id)
    }

    // MARK: - Profiles

    func profile(for userId: UUID) -> Profile? {
        profiles.first { $0.id == userId }
    }

    func searchProfiles(_ query: String) -> [Profile] {
        let q = query.lowercased()
        return profiles.filter {
            $0.username.lowercased().contains(q) ||
            $0.handle.lowercased().contains(q)
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
