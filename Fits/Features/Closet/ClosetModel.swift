//
//  ClosetModel.swift
//  Fits
//

import Foundation
import Observation

@Observable
final class ClosetModel {
    // Read directly from the store so SwiftUI tracks MockStore.items
    // as a dependency — the view re-renders automatically when items change.
    private let store = MockStore.shared

    var populatedCategories: [ItemCategory] {
        ItemCategory.allCases.filter { !items(for: $0).isEmpty }
    }

    func items(for category: ItemCategory) -> [ClothingItem] {
        store.myItems().filter { $0.category == category }
    }

    var isEmpty: Bool {
        store.myItems().isEmpty
    }
}
