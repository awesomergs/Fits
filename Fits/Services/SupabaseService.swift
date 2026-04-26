//
//  SupabaseService.swift
//  Fits
//
//  All database calls go through SupabaseHTTPClient (URLSession-based, no SDK).
//

import Foundation

@MainActor
final class SupabaseService {
    static let shared = SupabaseService()

    private let http = SupabaseHTTPClient.shared

    var currentUserId: UUID? { http.currentUserId }

    // MARK: - Items

    func myItems(wishlist: Bool? = nil) async throws -> [ClothingItem] {
        guard let userId = currentUserId else { throw SupabaseHTTPError.notAuthenticated }
        var filters: [String: String] = ["owner_id": userId.uuidString]
        if let wishlist { filters["is_wishlist"] = "eq.\(wishlist)" }
        return try await http.select(table: "clothing_items", filters: filters, order: "created_at.desc")
    }

    func itemsForUser(_ userId: UUID) async throws -> [ClothingItem] {
        try await http.select(
            table: "clothing_items",
            filters: ["owner_id": userId.uuidString, "is_wishlist": "eq.false"],
            order: "created_at.desc"
        )
    }

    func itemsByIds(_ ids: [UUID]) async throws -> [ClothingItem] {
        guard !ids.isEmpty else { return [] }
        return try await http.selectIn(
            table: "clothing_items",
            column: "id",
            values: ids.map(\.uuidString)
        )
    }

    func createItem(_ item: ClothingItem) async throws {
        try await http.insert(table: "clothing_items", body: item.toDict())
    }

    func batchCreateItems(_ items: [ClothingItem]) async throws {
        guard !items.isEmpty else { return }
        try await http.batchInsert(table: "clothing_items", body: items.map { $0.toDict() })
    }

    // MARK: - Outfits

    func feed(limit: Int = 20) async throws -> [Outfit] {
        try await http.select(
            table: "outfits",
            filters: ["published": "eq.true"],
            order: "created_at.desc",
            limit: limit
        )
    }

    func outfitsByUser(_ userId: UUID) async throws -> [Outfit] {
        try await http.select(
            table: "outfits",
            filters: ["owner_id": userId.uuidString],
            order: "created_at.desc"
        )
    }

    func publishOutfit(_ outfit: Outfit) async throws {
        try await http.upsert(table: "outfits", body: outfit.toDict())
    }

    // MARK: - Reactions

    func react(targetType: String, targetId: UUID, kind: ReactionKind, comment: String? = nil) async throws {
        guard let userId = currentUserId else { throw SupabaseHTTPError.notAuthenticated }
        var body: [String: Any] = [
            "user_id": userId.uuidString,
            "target_type": targetType,
            "target_id": targetId.uuidString,
            "kind": kind.rawValue
        ]
        if let comment { body["comment"] = comment }
        try await http.upsert(table: "reactions", body: body)
    }

    // MARK: - Steal

    func stealOutfit(_ outfit: Outfit, sourceItems: [ClothingItem]) async throws {
        guard let userId = currentUserId else { throw SupabaseHTTPError.notAuthenticated }
        let stolenItems = sourceItems.map { source in
            ClothingItem(
                id: UUID(),
                ownerId: userId,
                imageUrl: source.imageUrl,
                category: source.category,
                occasionTags: source.occasionTags,
                isWishlist: true,
                sourceItemId: source.id,
                sourceShop: source.sourceShop,
                sourceUrl: source.sourceUrl
            )
        }
        try await batchCreateItems(stolenItems)
        try await react(targetType: "outfit", targetId: outfit.id, kind: .steal)
    }

    // MARK: - Profiles

    func profile(for userId: UUID) async throws -> Profile {
        try await http.select(
            table: "profiles",
            filters: ["id": userId.uuidString],
            single: true
        )
    }

    func currentProfile() async throws -> Profile {
        guard let userId = currentUserId else { throw SupabaseHTTPError.notAuthenticated }
        return try await profile(for: userId)
    }

    func searchProfiles(_ query: String) async throws -> [Profile] {
        let results: [Profile] = try await http.selectLike(
            table: "profiles",
            column: "handle",
            pattern: query,
            limit: 10
        )
        return results
    }

    func createProfile(id: UUID, username: String, handle: String, bio: String? = nil) async throws {
        var body: [String: Any] = ["id": id.uuidString, "username": username, "handle": handle]
        if let bio { body["bio"] = bio }
        try await http.insert(table: "profiles", body: body)
    }

    func updateProfile(username: String? = nil, handle: String? = nil, avatarUrl: String? = nil, bio: String? = nil) async throws {
        guard let userId = currentUserId else { throw SupabaseHTTPError.notAuthenticated }
        var updates: [String: Any] = [:]
        if let username  { updates["username"]   = username }
        if let handle    { updates["handle"]      = handle }
        if let avatarUrl { updates["avatar_url"]  = avatarUrl }
        if let bio       { updates["bio"]         = bio }
        guard !updates.isEmpty else { return }
        try await http.update(table: "profiles", filters: ["id": userId.uuidString], body: updates)
    }
}

// MARK: - Codable → Dict helpers

private extension ClothingItem {
    func toDict() -> [String: Any] {
        var d: [String: Any] = [
            "id":          id.uuidString,
            "owner_id":    ownerId.uuidString,
            "image_url":   imageUrl,
            "category":    category.rawValue,
            "occasion_tags": occasionTags,
            "is_wishlist": isWishlist
        ]
        if let s = sourceItemId { d["source_item_id"] = s.uuidString }
        if let s = sourceShop   { d["source_shop"]    = s }
        if let s = sourceUrl    { d["source_url"]     = s }
        return d
    }
}

private extension Outfit {
    func toDict() -> [String: Any] {
        var d: [String: Any] = [
            "id":        id.uuidString,
            "owner_id":  ownerId.uuidString,
            "occasion":  occasion,
            "item_ids":  itemIds.map(\.uuidString),
            "published": published
        ]
        if let c = caption { d["caption"] = c }
        return d
    }
}
