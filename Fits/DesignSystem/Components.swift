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

final class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

// MARK: - Item image

struct ItemImageView: View {
    let item: ClothingItem
    var contentMode: ContentMode = .fill

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.low)
                    .aspectRatio(contentMode: contentMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            } else {
                Rectangle()
                    .fill(FitsTheme.muted.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if let cached = ImageCache.shared.object(forKey: item.imageUrl as NSString) {
                image = cached
                return
            }

            if let cached = MockStore.shared.imageCache[item.id] {
                ImageCache.shared.setObject(cached, forKey: item.imageUrl as NSString)
                image = cached
                return
            }

            if item.imageUrl.hasPrefix("asset://") {
                let name = String(item.imageUrl.dropFirst("asset://".count))
                if let ui = UIImage(named: name) {
                    ImageCache.shared.setObject(ui, forKey: item.imageUrl as NSString)
                    image = ui
                }
                return
            }

            guard let url = URL(string: item.imageUrl) else { return }

            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data, let ui = UIImage(data: data) {
                    ImageCache.shared.setObject(ui, forKey: item.imageUrl as NSString)
                    DispatchQueue.main.async {
                        image = ui
                    }
                }
            }.resume()
        }
    }
}

// MARK: - Previews

#Preview("Toast") {
    ZStack {
        FitsTheme.background.ignoresSafeArea()
        ToastView(message: "3 items added to your wishlist")
    }
}
