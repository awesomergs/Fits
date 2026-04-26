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

    var canSave: Bool { pickedImage != nil && selectedCategory != nil && !isSaving }

    func load(from item: PhotosPickerItem?) async {
        guard let item else { return }

        isLoadingImage = true
        guard let data = try? await item.loadTransferable(type: Data.self),
              let raw = UIImage(data: data) else {
            isLoadingImage = false
            return
        }

        // Show the raw image immediately for instant feedback
        pickedImage = raw
        isLoadingImage = false

        // Run VisionKit off the main actor (~200ms), then swap in the cutout
        isProcessingCutout = true
        pickedImage = await Task.detached(priority: .userInitiated) {
            await BackgroundRemovalService.cutout(from: raw)
        }.value
        isProcessingCutout = false
    }

    func save() async {
        guard let image = pickedImage, let category = selectedCategory else { return }
        isSaving = true

        let id = UUID()
        let item = ClothingItem(
            id: id,
            ownerId: MockStore.shared.currentUser.id,
            imageUrl: "local://\(id)",
            category: category,
            isWishlist: isWishlist
        )
        MockStore.shared.addItem(item, image: image)

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
    }
}
