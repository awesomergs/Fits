//
//  SlotCarousel.swift
//  Fits
//

import SwiftUI

struct SlotCarousel: View {
    let category: ItemCategory
    let items: [ClothingItem]
    @Binding var selection: ClothingItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.displayName)
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.6))
                .padding(.horizontal, 20)

            if items.isEmpty {
                Text("No \(category.displayName.lowercased()) tagged yet")
                    .font(.fitsCaption)
                    .foregroundStyle(FitsTheme.muted)
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(items) { item in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selection = selection?.id == item.id ? nil : item
                                }
                            } label: {
                                ItemCard(item: item, size: 88)
                                    .opacity(opacity(for: item))
                                    .scaleEffect(selection?.id == item.id ? 1.05 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: selection?.id)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func opacity(for item: ClothingItem) -> Double {
        guard let selection else { return 1.0 }
        return selection.id == item.id ? 1.0 : 0.45
    }
}

#Preview {
    @Previewable @State var selection: ClothingItem? = nil
    let items = [
        ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/t1/300/400", category: .top),
        ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/t2/300/400", category: .top),
        ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/t3/300/400", category: .top),
    ]
    return VStack {
        SlotCarousel(category: .top, items: items, selection: $selection)
    }
    .padding(.vertical)
    .background(FitsTheme.background)
}
