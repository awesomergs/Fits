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

// MARK: - Item image

/// Checks the MockStore image cache first (for locally tagged items),
/// falls back to AsyncImage for seeded/network items.
/// Swap out the cache check when wiring Supabase.
struct ItemImageView: View {
    let item: ClothingItem
    var contentMode: ContentMode = .fill

    var body: some View {
        if let cached = MockStore.shared.imageCache[item.id] {
            Image(uiImage: cached)
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: contentMode)
                case .failure:
                    placeholderRect
                default:
                    placeholderRect.overlay(ProgressView().tint(FitsTheme.primary))
                }
            }
        }
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
