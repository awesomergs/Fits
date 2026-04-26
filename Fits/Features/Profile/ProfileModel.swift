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

    private let mockStore = MockStore.shared

    init(userId: UUID? = nil) {
        if let userId = userId {
            self.userId = userId
        } else {
            self.userId = mockStore.currentUser.id
        }
    }

    var isCurrentUser: Bool {
        userId == mockStore.currentUser.id
    }

    func load() {
        isLoading = true
        error = nil

        profile = mockStore.profile(for: userId)
        let allOutfits = mockStore.outfitsByUser(userId)
        outfits = allOutfits.filter { $0.published || $0.ownerId == mockStore.currentUser.id }

        let items = mockStore.itemsForUser(userId)
        recentItems = Array(items.sorted { $0.createdAt > $1.createdAt }.prefix(12))

        isLoading = false
    }
}
