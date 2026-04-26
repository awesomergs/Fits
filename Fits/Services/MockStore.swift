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

        func asset(_ name: String) -> String { "asset://\(name)" }

        func makeItem(owner: Profile, category: ItemCategory, image: String, wishlist: Bool = false) -> ClothingItem {
            ClothingItem(
                id: UUID(),
                ownerId: owner.id,
                imageUrl: image,
                category: category,
                isWishlist: wishlist
            )
        }

        // MARK: - Items (coordinated per user)

        // Me — smart casual
        let meTop        = makeItem(owner: me, category: .top,       image: asset("top_white-and-blue_checkered-button-up"))
        let meBottom     = makeItem(owner: me, category: .bottom,    image: asset("bottom_jeans_trouser"))
        let meOuter      = makeItem(owner: me, category: .outerwear, image: asset("outer_tan_jacket"))
        let meShoes      = makeItem(owner: me, category: .shoes,     image: asset("shoes_purple_loafers"))
        let meAcc        = makeItem(owner: me, category: .accessory, image: asset("acc_black_cap"))

        // Aria — streetwear
        let ariaTop      = makeItem(owner: aria, category: .top,       image: asset("top_black_tshirt"))
        let ariaBottom   = makeItem(owner: aria, category: .bottom,    image: asset("bottom_black_cottonPants"))
        let ariaOuter    = makeItem(owner: aria, category: .outerwear, image: asset("outer_black_moto"))
        let ariaShoes    = makeItem(owner: aria, category: .shoes,     image: asset("shoes_orange_chunky"))
        let ariaAcc      = makeItem(owner: aria, category: .accessory, image: asset("acc_chain_bracelet"), wishlist: true)

        // Kai — minimal
        let kaiTop       = makeItem(owner: kai, category: .top,       image: asset("top_white_tshirt"))
        let kaiBottom    = makeItem(owner: kai, category: .bottom,    image: asset("bottom_beige_trousers"))
        let kaiOuter     = makeItem(owner: kai, category: .outerwear, image: asset("outer_tan_jacket"))
        let kaiShoes     = makeItem(owner: kai, category: .shoes,     image: asset("shoes_blue_suede"))

        // Jules — bold
        let julesTop     = makeItem(owner: jules, category: .top,       image: asset("top_red_polo"))
        let julesBottom  = makeItem(owner: jules, category: .bottom,    image: asset("bottom_jeans_trouser"))
        let julesShoes   = makeItem(owner: jules, category: .shoes,     image: asset("shoes_silver_hightop"))
        let julesOuter   = makeItem(owner: jules, category: .outerwear, image: asset("outer_purple_snow"))
        let julesAcc     = makeItem(owner: jules, category: .accessory, image: asset("acc_ring"))
        let julesShoes2  = makeItem(owner: jules, category: .shoes,     image: asset("shoes_rainbow_heels"))

        // Lena — soft neutrals
        let lenaTop      = makeItem(owner: lena, category: .top,       image: asset("top_white_boatneck"))
        let lenaTop2     = makeItem(owner: lena, category: .top,       image: asset("top_mint-green_tshirt"))
        let lenaBottom   = makeItem(owner: lena, category: .bottom,    image: asset("bottom_beige_trousers"))
        let lenaOuter    = makeItem(owner: lena, category: .outerwear, image: asset("outer_navy_rain"))
        let lenaShoes    = makeItem(owner: lena, category: .shoes,     image: asset("shoes_blue_heels"))
        let lenaShoes2   = makeItem(owner: lena, category: .shoes,     image: asset("shoes_denim_sandals"))
        let lenaAcc      = makeItem(owner: lena, category: .accessory, image: asset("acc_rose_earrings"))

        // Marcus — techwear
        let marcusTop    = makeItem(owner: marcus, category: .top,       image: asset("top_gray_tshirt"))
        let marcusTop2   = makeItem(owner: marcus, category: .top,       image: asset("top_black_polo"))
        let marcusBottom = makeItem(owner: marcus, category: .bottom,    image: asset("bottom_black_cottonPants"))
        let marcusOuter  = makeItem(owner: marcus, category: .outerwear, image: asset("outer_purple_snow"))
        let marcusShoes  = makeItem(owner: marcus, category: .shoes,     image: asset("shoes_silver_hightop"))
        let marcusAcc    = makeItem(owner: marcus, category: .accessory, image: asset("acc_backpack"))

        // Ivy — thrift
        let ivyTop       = makeItem(owner: ivy, category: .top,       image: asset("top_red-checkered_button-up"))
        let ivyBottom    = makeItem(owner: ivy, category: .bottom,    image: asset("bottom_olive_shorts"))
        let ivyShoes     = makeItem(owner: ivy, category: .shoes,     image: asset("shoes_pink_vans"))
        let ivyShoes2    = makeItem(owner: ivy, category: .shoes,     image: asset("shoes_chocolate_heels"))
        let ivyAcc       = makeItem(owner: ivy, category: .accessory, image: asset("acc_blue_cap"))

        items = [
            meTop, meBottom, meOuter, meShoes, meAcc,
            ariaTop, ariaBottom, ariaOuter, ariaShoes, ariaAcc,
            kaiTop, kaiBottom, kaiOuter, kaiShoes,
            julesTop, julesBottom, julesShoes, julesOuter, julesAcc, julesShoes2,
            lenaTop, lenaTop2, lenaBottom, lenaOuter, lenaShoes, lenaShoes2, lenaAcc,
            marcusTop, marcusTop2, marcusBottom, marcusOuter, marcusShoes, marcusAcc,
            ivyTop, ivyBottom, ivyShoes, ivyShoes2, ivyAcc,
        ]

        // MARK: - Outfits (curated, not shuffled)

        func outfit(owner: Profile, itemIds: [UUID], caption: String, occasion: String, hoursAgo: Double, hotness: Double = 0.5) -> Outfit {
            Outfit(
                id: UUID(),
                ownerId: owner.id,
                occasion: occasion,
                itemIds: itemIds,
                caption: caption,
                published: true,
                createdAt: Date(timeIntervalSinceNow: -hoursAgo * 3600),
                hotness: hotness
            )
        }

        outfits = [
            outfit(owner: aria,   itemIds: [ariaTop.id, ariaBottom.id, ariaOuter.id, ariaShoes.id, ariaAcc.id],          caption: "weekend fit 🖤",   occasion: "Streetwear", hoursAgo: 1, hotness: 0.82),
            outfit(owner: kai,    itemIds: [kaiTop.id, kaiBottom.id, kaiOuter.id, kaiShoes.id],                          caption: "clean lines only", occasion: "Work",       hoursAgo: 2, hotness: 0.55),
            outfit(owner: jules,  itemIds: [julesTop.id, julesBottom.id, julesOuter.id, julesShoes.id, julesAcc.id],      caption: "loud energy",      occasion: "Night Out",  hoursAgo: 3, hotness: 0.73),
            outfit(owner: lena,   itemIds: [lenaTop.id, lenaBottom.id, lenaOuter.id, lenaShoes.id, lenaAcc.id],           caption: "soft tones",       occasion: "Casual",     hoursAgo: 5, hotness: 0.35),
            outfit(owner: marcus, itemIds: [marcusTop.id, marcusBottom.id, marcusOuter.id, marcusShoes.id, marcusAcc.id], caption: "tech mode",        occasion: "City",       hoursAgo: 6, hotness: 0.48),
            outfit(owner: ivy,    itemIds: [ivyTop.id, ivyBottom.id, ivyShoes.id, ivyAcc.id],                            caption: "thrifted gems",     occasion: "Vintage",    hoursAgo: 8, hotness: 0.28),
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
        let map = Dictionary(uniqueKeysWithValues: items.compactMap { item -> (UUID, ClothingItem)? in
            guard ids.contains(item.id) else { return nil }
            return (item.id, item)
        })
        return ids.compactMap { map[$0] }
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
