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

    private let supabase = SupabaseService.shared
    private let imageUpload = ImageUploadService.shared

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
              let category = selectedCategory,
              let userId = supabase.currentUserId else {
            error = "Missing image or category"
            return
        }

        isSaving = true
        error = nil

        do {
            // Convert image to PNG data
            guard let imageData = image.pngData() else {
                throw TagError.imageSaveFailed
            }

            // Upload to storage
            let imageUrl = try await imageUpload.uploadItemImage(imageData)

            // Create item in database
            let item = ClothingItem(
                ownerId: userId,
                imageUrl: imageUrl,
                category: category,
                isWishlist: isWishlist
            )

            try await supabase.createItem(item)

            isSaving = false
            showSuccessToast = true
            try? await Task.sleep(for: .seconds(2))
            showSuccessToast = false
            reset()
        } catch {
            print("Save failed: \(error)")
            self.error = error.localizedDescription
            isSaving = false
        }
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
