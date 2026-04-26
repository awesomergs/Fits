//
//  ProfileModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class ProfileModel {
    let userId: UUID

    init(userId: UUID = MockStore.shared.currentUser.id) {
        self.userId = userId
    }

    var profile: Profile? {
        MockStore.shared.profile(for: userId)
    }

    var outfits: [Outfit] {
        MockStore.shared.outfitsByUser(userId)
    }

    var recentItems: [ClothingItem] {
        Array(
            MockStore.shared.itemsForUser(userId)
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(12)
        )
    }

    var isCurrentUser: Bool {
        userId == MockStore.shared.currentUser.id
    }
}
