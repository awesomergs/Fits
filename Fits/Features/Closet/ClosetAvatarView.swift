//
//  ClosetAvatarView.swift
//  Fits
//
//  Ghost-mannequin view: body silhouette with actual clothing items layered on top.
//

import SwiftUI

struct ClosetAvatarView: View {
    let items: [ClothingItem]
    private let preloadedItems: [ClothingItem]

    @State private var picks: [ItemCategory: ClothingItem]
    @State private var selectedCategory: ItemCategory? = nil
    @State private var showingPicker = false
    @State private var showEmptySlots = true

    init(items: [ClothingItem], preloadedItems: [ClothingItem] = []) {
        self.items = items
        self.preloadedItems = preloadedItems
        var initial: [ItemCategory: ClothingItem] = [:]
        for item in preloadedItems { initial[item.category] = item }
        _picks = State(initialValue: initial)
    }

    private var itemsByCategory: [ItemCategory: [ClothingItem]] {
        Dictionary(grouping: items.filter { !$0.isWishlist }, by: \.category)
    }

    var body: some View {
        ZStack {
            FitsTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    mannequin
                        .padding(.horizontal, 24)
                        .padding(.top, 16)

                    categoryTray

                    emptySlotToggle

                    buildFitButton
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showingPicker) {
            if let category = selectedCategory {
                CategoryPickerSheet(
                    category: category,
                    items: itemsByCategory[category] ?? [],
                    selected: picks[category],
                    onPick: { item in
                        if let item {
                            picks[category] = item
                        } else {
                            picks.removeValue(forKey: category)
                        }
                        showingPicker = false
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Mannequin body

    private var mannequin: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let scale = w / 300           // normalize to a 300-pt design width

            ZStack(alignment: .top) {
                // Body silhouette
                MannequinShape()
                    .fill(FitsTheme.muted.opacity(0.35))
                    .frame(width: w, height: w * 1.8)

                MannequinShape()
                    .stroke(FitsTheme.primary.opacity(0.25), lineWidth: 1.5)
                    .frame(width: w, height: w * 1.8)

                // Clothing items layered on body zones
                clothingLayers(width: w, scale: scale)
            }
        }
        .aspectRatio(300.0 / 540.0, contentMode: .fit)
    }

    @ViewBuilder
    private func clothingLayers(width: CGFloat, scale: CGFloat) -> some View {
        let totalHeight = width * 1.8

        // Outerwear (sits on top of everything, full torso)
        if let item = picks[.outerwear] {
            wornItem(item, width: width * 0.92, height: totalHeight * 0.40)
                .offset(y: totalHeight * 0.18)
                .allowsHitTesting(false)
        }

        // Top (shirt, inside jacket)
        if let item = picks[.top] {
            wornItem(item, width: width * 0.70, height: totalHeight * 0.32)
                .offset(y: totalHeight * 0.22)
                .allowsHitTesting(false)
        }

        // Full body (dress / jumpsuit — replaces top+bottom)
        if let item = picks[.fullBody] {
            wornItem(item, width: width * 0.80, height: totalHeight * 0.60)
                .offset(y: totalHeight * 0.18)
                .allowsHitTesting(false)
        }

        // Bottom (trousers / skirt)
        if picks[.fullBody] == nil, let item = picks[.bottom] {
            wornItem(item, width: width * 0.65, height: totalHeight * 0.38)
                .offset(y: totalHeight * 0.50)
                .allowsHitTesting(false)
        }

        // Shoes
        if let item = picks[.shoes] {
            HStack(spacing: width * 0.06) {
                wornItem(item, width: width * 0.28, height: totalHeight * 0.12)
                wornItem(item, width: width * 0.28, height: totalHeight * 0.12)
            }
            .offset(y: totalHeight * 0.84)
            .allowsHitTesting(false)
        }

        // Accessory (small, near neck)
        if let item = picks[.accessory] {
            wornItem(item, width: width * 0.22, height: width * 0.22)
                .offset(x: width * 0.22, y: totalHeight * 0.19)
                .allowsHitTesting(false)
        }

        // Tap targets over each zone
        zoneTapTargets(width: width, totalHeight: totalHeight)
    }

    private func wornItem(_ item: ClothingItem, width: CGFloat, height: CGFloat) -> some View {
        ItemImageView(item: item, contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }

    @ViewBuilder
    private func zoneTapTargets(width: CGFloat, totalHeight: CGFloat) -> some View {
        let zones: [(ItemCategory, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (.outerwear, width * 0.92, totalHeight * 0.40, 0,            totalHeight * 0.18),
            (.top,       width * 0.70, totalHeight * 0.32, 0,            totalHeight * 0.22),
            (.bottom,    width * 0.65, totalHeight * 0.38, 0,            totalHeight * 0.50),
            (.shoes,     width * 0.60, totalHeight * 0.12, 0,            totalHeight * 0.84),
            (.accessory, width * 0.22, width * 0.22,       width * 0.22, totalHeight * 0.19),
        ]

        ForEach(zones, id: \.0) { (category, w, h, ox, oy) in
            let hasItem = picks[category] != nil
            let hasOptions = !(itemsByCategory[category] ?? []).isEmpty

            if hasOptions && (hasItem || showEmptySlots) {
                Button {
                    selectedCategory = category
                    showingPicker = true
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            hasItem ? Color.clear : FitsTheme.primary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 1.5, dash: hasItem ? [] : [5])
                        )
                        .background(
                            hasItem ? Color.clear : FitsTheme.muted.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                        .overlay {
                            if !hasItem {
                                VStack(spacing: 3) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(category.displayName)
                                        .font(.system(size: 10, weight: .medium))
                                }
                                .foregroundStyle(FitsTheme.primary.opacity(0.5))
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: w, height: h)
                .offset(x: ox, y: oy)
            }
        }
    }

    // MARK: - Empty slot toggle

    private var emptySlotToggle: some View {
        HStack {
            Label("Show empty slots", systemImage: "square.dashed")
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.7))
            Spacer()
            Toggle("", isOn: $showEmptySlots)
                .tint(FitsTheme.accent)
                .labelsHidden()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Category tray (quick swaps below the avatar)

    private var categoryTray: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    let options = itemsByCategory[category] ?? []
                    if !options.isEmpty {
                        categoryChip(category, currentItem: picks[category])
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func categoryChip(_ category: ItemCategory, currentItem: ClothingItem?) -> some View {
        Button {
            selectedCategory = category
            showingPicker = true
        } label: {
            HStack(spacing: 6) {
                if let item = currentItem {
                    ItemImageView(item: item, contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }

                Text(category.displayName)
                    .font(.fitsCaption)
                    .foregroundStyle(FitsTheme.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(currentItem != nil ? FitsTheme.highlight : FitsTheme.surface)
            .clipShape(Capsule())
            .overlay(Capsule().strokeBorder(FitsTheme.muted.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Build fit CTA

    private var buildFitButton: some View {
        Button {
            // TODO: open outfit builder pre-filled with picks
        } label: {
            Text("Save as Outfit")
                .font(.fitsBody.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(picks.isEmpty ? FitsTheme.muted : FitsTheme.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(picks.isEmpty)
        .padding(.horizontal, 24)
    }

}

// MARK: - Mannequin SVG shape

struct MannequinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var p = Path()

        // Head
        let headCX = w / 2, headCY = h * 0.065, headR = w * 0.095
        p.addEllipse(in: CGRect(x: headCX - headR, y: headCY - headR,
                                width: headR * 2, height: headR * 2.1))

        // Neck
        p.move(to: CGPoint(x: w * 0.44, y: h * 0.125))
        p.addLine(to: CGPoint(x: w * 0.44, y: h * 0.16))
        p.addLine(to: CGPoint(x: w * 0.56, y: h * 0.16))
        p.addLine(to: CGPoint(x: w * 0.56, y: h * 0.125))

        // Torso (shoulders → waist)
        p.move(to: CGPoint(x: w * 0.44, y: h * 0.16))
        p.addCurve(to: CGPoint(x: w * 0.12, y: h * 0.20),
                   control1: CGPoint(x: w * 0.32, y: h * 0.16),
                   control2: CGPoint(x: w * 0.18, y: h * 0.17))
        p.addLine(to: CGPoint(x: w * 0.10, y: h * 0.42))
        p.addCurve(to: CGPoint(x: w * 0.38, y: h * 0.50),
                   control1: CGPoint(x: w * 0.10, y: h * 0.47),
                   control2: CGPoint(x: w * 0.26, y: h * 0.50))
        p.addLine(to: CGPoint(x: w * 0.62, y: h * 0.50))
        p.addCurve(to: CGPoint(x: w * 0.90, y: h * 0.42),
                   control1: CGPoint(x: w * 0.74, y: h * 0.50),
                   control2: CGPoint(x: w * 0.90, y: h * 0.47))
        p.addLine(to: CGPoint(x: w * 0.88, y: h * 0.20))
        p.addCurve(to: CGPoint(x: w * 0.56, y: h * 0.16),
                   control1: CGPoint(x: w * 0.82, y: h * 0.17),
                   control2: CGPoint(x: w * 0.68, y: h * 0.16))
        p.closeSubpath()

        // Left arm
        p.move(to: CGPoint(x: w * 0.12, y: h * 0.20))
        p.addCurve(to: CGPoint(x: w * 0.04, y: h * 0.40),
                   control1: CGPoint(x: w * 0.08, y: h * 0.25),
                   control2: CGPoint(x: w * 0.04, y: h * 0.32))
        p.addLine(to: CGPoint(x: w * 0.10, y: h * 0.41))
        p.addCurve(to: CGPoint(x: w * 0.16, y: h * 0.22),
                   control1: CGPoint(x: w * 0.13, y: h * 0.34),
                   control2: CGPoint(x: w * 0.16, y: h * 0.27))
        p.closeSubpath()

        // Right arm
        p.move(to: CGPoint(x: w * 0.88, y: h * 0.20))
        p.addCurve(to: CGPoint(x: w * 0.96, y: h * 0.40),
                   control1: CGPoint(x: w * 0.92, y: h * 0.25),
                   control2: CGPoint(x: w * 0.96, y: h * 0.32))
        p.addLine(to: CGPoint(x: w * 0.90, y: h * 0.41))
        p.addCurve(to: CGPoint(x: w * 0.84, y: h * 0.22),
                   control1: CGPoint(x: w * 0.87, y: h * 0.34),
                   control2: CGPoint(x: w * 0.84, y: h * 0.27))
        p.closeSubpath()

        // Left leg
        p.move(to: CGPoint(x: w * 0.38, y: h * 0.50))
        p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.86))
        p.addLine(to: CGPoint(x: w * 0.44, y: h * 0.86))
        p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.50))
        p.closeSubpath()

        // Right leg
        p.move(to: CGPoint(x: w * 0.62, y: h * 0.50))
        p.addLine(to: CGPoint(x: w * 0.70, y: h * 0.86))
        p.addLine(to: CGPoint(x: w * 0.56, y: h * 0.86))
        p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.50))
        p.closeSubpath()

        // Left foot
        p.addEllipse(in: CGRect(x: w * 0.24, y: h * 0.86,
                                width: w * 0.22, height: h * 0.065))

        // Right foot
        p.addEllipse(in: CGRect(x: w * 0.54, y: h * 0.86,
                                width: w * 0.22, height: h * 0.065))

        return p
    }
}

// MARK: - Category picker sheet

struct CategoryPickerSheet: View {
    let category: ItemCategory
    let items: [ClothingItem]
    let selected: ClothingItem?
    let onPick: (ClothingItem?) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Choose \(category.displayName)")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 100), spacing: 12)],
                    spacing: 12
                ) {
                    // N/A tile — clears the slot
                    Button { onPick(nil) } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(FitsTheme.muted.opacity(0.25))
                            .frame(width: 100, height: 130)
                            .overlay {
                                VStack(spacing: 6) {
                                    Image(systemName: "xmark.circle")
                                        .font(.system(size: 26, weight: .light))
                                    Text("None")
                                        .font(.fitsCaption)
                                }
                                .foregroundStyle(FitsTheme.primary.opacity(0.55))
                            }
                            .overlay {
                                if selected == nil {
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(FitsTheme.accent, lineWidth: 3)
                                }
                            }
                    }
                    .buttonStyle(.plain)

                    ForEach(items) { item in
                        Button {
                            onPick(item)
                        } label: {
                            ItemImageView(item: item, contentMode: .fill)
                                .frame(width: 100, height: 130)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay {
                                    if selected?.id == item.id {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(FitsTheme.accent, lineWidth: 3)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(FitsTheme.background)
    }
}

#Preview {
    ClosetAvatarView(items: [
        ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/top/200/300",    category: .top),
        ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/bottom/200/300", category: .bottom),
        ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/shoes/200/300",  category: .shoes),
    ])
}
