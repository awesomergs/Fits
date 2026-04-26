//
//  ItemCard.swift
//  Fits
//

import SwiftUI

struct ItemCard: View {
    let item: ClothingItem
    var size: CGFloat = 110

    var body: some View {
        ItemImageView(item: item)
            .frame(width: size, height: size * 4 / 3)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        item.isWishlist ? FitsTheme.accent : .clear,
                        style: StrokeStyle(lineWidth: 2, dash: item.isWishlist ? [4] : [])
                    )
            }
            .overlay(alignment: .topTrailing) {
                if item.isWishlist {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(FitsTheme.accent)
                        .padding(6)
                }
            }
            .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }
}

#Preview {
    HStack(spacing: 12) {
        // Simulated owned item
        ItemCard(item: ClothingItem(
            ownerId: UUID(),
            imageUrl: "https://picsum.photos/seed/preview-top/300/400",
            category: .top
        ))
        // Simulated wishlist item
        ItemCard(item: ClothingItem(
            ownerId: UUID(),
            imageUrl: "https://picsum.photos/seed/preview-shoes/300/400",
            category: .shoes,
            isWishlist: true
        ))
    }
    .padding()
    .background(FitsTheme.background)
}
