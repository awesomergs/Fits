//
//  Components.swift
//  Fits
//

import SwiftUI

// MARK: - Toast

struct ToastView: View {
    let message: String
    var systemImage: String = "checkmark.circle.fill"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(FitsTheme.accent)
                .fontWeight(.semibold)
            Text(message)
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(FitsTheme.surface)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.10), radius: 12, y: 4)
    }
}

// MARK: - Image cache

private final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() { cache.countLimit = 200 }
    func get(_ key: String) -> UIImage? { cache.object(forKey: key as NSString) }
    func set(_ image: UIImage, for key: String) { cache.setObject(image, forKey: key as NSString) }
}

// MARK: - Item image

struct ItemImageView: View {
    let item: ClothingItem
    var contentMode: ContentMode = .fill

    @State private var uiImage: UIImage? = nil

    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .interpolation(.low)
                    .aspectRatio(contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                placeholderRect
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: item.id) {
            uiImage = await Self.loadImage(for: item)
        }
    }

    private static func loadImage(for item: ClothingItem) async -> UIImage? {
        if let img = MockStore.shared.imageCache[item.id] { return img }
        if let img = ImageCache.shared.get(item.imageUrl) { return img }
        guard let url = URL(string: item.imageUrl),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let img = UIImage(data: data) else { return nil }
        ImageCache.shared.set(img, for: item.imageUrl)
        return img
    }

    private var placeholderRect: some View {
        Rectangle().fill(FitsTheme.muted.opacity(0.5))
    }
}

// MARK: - Previews

#Preview("Toast") {
    ZStack {
        FitsTheme.background.ignoresSafeArea()
        ToastView(message: "3 items added to your wishlist")
    }
}
