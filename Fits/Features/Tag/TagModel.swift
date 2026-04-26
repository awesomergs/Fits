//
//  TagModel.swift
//  Fits
//

import SwiftUI
import PhotosUI

@Observable
final class TagModel {
    var pickedImage: UIImage? = nil
    var isLoadingImage = false
    var isProcessingCutout = false
    var selectedCategory: ItemCategory? = nil
    var isWishlist = false
    var isSaving = false
    var showSuccessToast = false
    var error: String?

    var canSave: Bool { pickedImage != nil && selectedCategory != nil && !isSaving }

    private let mockStore = MockStore.shared

    func load(from item: PhotosPickerItem?) async {
        guard let item else { return }

        isLoadingImage = true
        guard let data = try? await item.loadTransferable(type: Data.self),
              let raw = UIImage(data: data) else {
            isLoadingImage = false
            return
        }

        pickedImage = raw
        isLoadingImage = false

        isProcessingCutout = true
        pickedImage = await Task.detached(priority: .userInitiated) {
            await BackgroundRemovalService.cutout(from: raw)
        }.value
        isProcessingCutout = false
    }

    func save() async {
        guard let image = pickedImage,
              let category = selectedCategory else {
            error = "Missing image or category"
            return
        }

        isSaving = true
        error = nil

        let itemId = UUID()
        let item = ClothingItem(
            id: itemId,
            ownerId: mockStore.currentUser.id,
            imageUrl: "https://picsum.photos/seed/\(itemId.uuidString)/300/400",
            category: category,
            isWishlist: isWishlist
        )

        mockStore.addItem(item, image: image)

        isSaving = false
        showSuccessToast = true
        try? await Task.sleep(for: .seconds(2))
        showSuccessToast = false
        reset()
    }

    func reset() {
        pickedImage = nil
        isLoadingImage = false
        isProcessingCutout = false
        selectedCategory = nil
        isWishlist = false
        error = nil
    }
}

enum TagError: LocalizedError {
    case imageSaveFailed

    var errorDescription: String? {
        switch self {
        case .imageSaveFailed:
            return "Failed to save image"
        }
    }
}
