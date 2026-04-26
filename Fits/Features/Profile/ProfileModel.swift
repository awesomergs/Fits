//
//  ProfileModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class ProfileModel {
    let userId: UUID
    var profile: Profile?
    var outfits: [Outfit] = []
    var recentItems: [ClothingItem] = []
    var isLoading = false
    var error: String?

    private let supabase = SupabaseService.shared

    init(userId: UUID? = nil) {
        if let userId = userId {
            self.userId = userId
        } else {
            self.userId = supabase.currentUserId ?? UUID()
        }
    }

    var isCurrentUser: Bool {
        userId == supabase.currentUserId
    }

    func load() async {
        isLoading = true
        error = nil

        do {
            profile = try await supabase.profile(for: userId)
            let allOutfits = try await supabase.outfitsByUser(userId)
            outfits = allOutfits.filter { $0.published || $0.ownerId == supabase.currentUserId }

            let items = try await supabase.itemsForUser(userId)
            recentItems = Array(
                items.sorted { $0.createdAt > $1.createdAt }.prefix(12)
            )

            isLoading = false
        } catch {
            print("Failed to load profile: \(error)")
            self.error = error.localizedDescription
            isLoading = false
        }
    }
}
