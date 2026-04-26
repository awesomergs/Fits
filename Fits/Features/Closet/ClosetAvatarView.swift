//
//  ClosetAvatarView.swift
//  Fits
//

import SwiftUI

struct ClosetAvatarView: View {
    let items: [ClothingItem]
    var onSave: (() -> Void)? = nil
    private let preloadedItems: [ClothingItem]

    @State private var picks: [ItemCategory: ClothingItem]
    @State private var selectedCategory: ItemCategory? = nil
    @State private var showingPicker = false
    @State private var showEmptySlots = true

    init(
        items: [ClothingItem],
        preloadedItems: [ClothingItem] = [],
        onSave: (() -> Void)? = nil
    ) {
        self.items = items
        self.preloadedItems = preloadedItems
        self.onSave = onSave

        var initial: [ItemCategory: ClothingItem] = [:]
        for item in preloadedItems {
            initial[item.category] = item
        }
        _picks = State(initialValue: initial)
    }

    private var itemsByCategory: [ItemCategory: [ClothingItem]] {
        Dictionary(grouping: items.filter { !$0.isWishlist }, by: \.category)
    }

    var hotScore: Int { computeHotScore(items: Array(picks.values)) }

    var body: some View {
        ZStack {
            FitsTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    ZStack(alignment: .top) {

                        mannequin
                            .padding(.horizontal, 24)

                        let score = hotScore

                        ZStack {
                            HStack(spacing: 6) {
                                Image(systemName: score >= 50 ? "flame.fill" : "trash.fill")
                                    .font(.system(size: 18, weight: .bold))

                                Text("\(score)%")
                                    .font(.system(size: 22, weight: .black))
                            }
                            .foregroundStyle(score >= 50 ? Color.orange : Color.gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(score >= 50 ? Color.orange : Color.gray, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .rotationEffect(.degrees(score >= 50 ? 8 : -8))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 20)
                    }

                    categoryTray
                    emptySlotToggle
                    buildFitButton
                }
                .padding(.bottom, 12)
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
            let scale = w / 300

            ZStack(alignment: .top) {
                MannequinShape()
                    .fill(Color.clear)
                    .frame(width: w, height: w * 1.8)

                MannequinShape()
                    .stroke(Color.clear, lineWidth: 0)
                    .frame(width: w, height: w * 1.8)
                clothingLayers(width: w, scale: scale)
            }
            .drawingGroup()
        }
        .aspectRatio(300.0 / 540.0, contentMode: .fill)
        .clipped()
    }

    @ViewBuilder
    private func clothingLayers(width: CGFloat, scale: CGFloat) -> some View {
        let totalHeight = width * 1.8

        if let item = picks[.top] {
            wornItem(item, width: width * 0.70, height: totalHeight * 0.32)
                .offset(y: totalHeight * 0.22)
                .allowsHitTesting(false)
        }

        if let item = picks[.fullBody] {
            wornItem(item, width: width * 0.80, height: totalHeight * 0.60)
                .offset(y: totalHeight * 0.18)
                .allowsHitTesting(false)
        }

        if picks[.fullBody] == nil, let item = picks[.bottom] {
            wornItem(item, width: width * 0.65, height: totalHeight * 0.38)
                .offset(y: totalHeight * 0.50)
                .allowsHitTesting(false)
        }

        if let item = picks[.shoes] {
            HStack(spacing: width * 0.06) {
                wornItem(item, width: width * 0.28, height: totalHeight * 0.12)
                wornItem(item, width: width * 0.28, height: totalHeight * 0.12)
            }
            .offset(y: totalHeight * 0.84)
            .allowsHitTesting(false)
        }

        zoneTapTargets(width: width, totalHeight: totalHeight)
    }

    private func wornItem(_ item: ClothingItem, width: CGFloat, height: CGFloat) -> some View {
        ItemImageView(item: item, contentMode: .fit)
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }

    // MARK: - Tap Zones (unchanged)

    @ViewBuilder
    private func zoneTapTargets(width: CGFloat, totalHeight: CGFloat) -> some View {
        let zones: [(ItemCategory, CGFloat, CGFloat, CGFloat, CGFloat)] = [
            (.top, width * 0.70, totalHeight * 0.32, 0, totalHeight * 0.22),
            (.bottom, width * 0.65, totalHeight * 0.38, 0, totalHeight * 0.50),
            (.shoes, width * 0.60, totalHeight * 0.12, 0, totalHeight * 0.84),
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
                }
                .buttonStyle(.plain)
                .frame(width: w, height: h)
                .offset(x: ox, y: oy)
            }
        }
    }

    private var emptySlotToggle: some View {
        HStack {
            Label("Show empty slots", systemImage: "square.dashed")
                .font(.fitsCaption)
            Spacer()
            Toggle("", isOn: $showEmptySlots)
                .labelsHidden()
        }
        .padding(.horizontal, 24)
    }

    private var categoryTray: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(ItemCategory.allCases.filter { $0 != .outerwear && $0 != .accessory }, id: \.self) { category in
                    if !(itemsByCategory[category] ?? []).isEmpty {
                        Button {
                            selectedCategory = category
                            showingPicker = true
                        } label: {
                            Text(category.displayName)
                                .padding(8)
                                .background(FitsTheme.surface)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    
    private var buildFitButton: some View {
            Button {
                let itemIds = picks.values.map { $0.id }

                guard !itemIds.isEmpty else { return }

                let outfit = Outfit(
                    ownerId: MockStore.shared.currentUser.id,
                    occasion: "Custom",
                    itemIds: itemIds,
                    published: true
                )

                MockStore.shared.publishOutfit(outfit)

                onSave?()
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

// MARK: - Hot score

private func computeHotScore(items: [ClothingItem]) -> Int {
    guard !items.isEmpty else { return Int.random(in: 0...100) }

    var score = 0

    // Parse names from imageUrl last path component (e.g. "top_black_tshirt.png" → ["top","black","tshirt"])
    let parts: [[String]] = items.compactMap { item in
        let name = URL(string: item.imageUrl)
            .map { $0.deletingPathExtension().lastPathComponent }
            ?? String(item.imageUrl.split(separator: "/").last ?? "")
        guard !name.isEmpty, name != item.imageUrl else { return nil }
        return name.components(separatedBy: "_").filter { !$0.isEmpty }
    }

    // If any item had no parseable name, return fully random
    guard parts.count == items.count else { return Int.random(in: 0...100) }

    let allTokens = parts.flatMap { $0 }

    // +20 for complete outfit coverage
    let categories = Set(items.map { $0.category })
    let hasFullOutfit = (categories.contains(.top) && categories.contains(.bottom) && categories.contains(.shoes))
        || (categories.contains(.fullBody) && categories.contains(.shoes))
    if hasFullOutfit { score += 20 }

    // +15 for cohesive color family
    let neutrals: Set<String> = ["black", "white", "gray", "grey", "beige", "cream", "tan", "ivory", "off-white"]
    let itemColors = allTokens.filter { neutrals.contains($0.lowercased()) }
    if itemColors.count >= items.count - 1 { score += 15 }

    // +15 for consistent top style
    let topStyles: Set<String> = ["tshirt", "polo", "button-up", "buttonup", "crewneck", "henley", "boatneck"]
    let matchingStyles = allTokens.filter { topStyles.contains($0.lowercased()) }
    if matchingStyles.count >= 1 { score += 15 }

    // +0–20 random flair
    score += Int.random(in: 0...20)

    return min(max(score, 0), 100)
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

        // Torso
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
                .padding(20)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    Button { onPick(nil) } label: {
                        Text("None")
                            .frame(width: 100, height: 130)
                            .background(Color.gray.opacity(0.2))
                    }

                    ForEach(items) { item in
                        Button {
                            onPick(item)
                        } label: {
                            ItemImageView(item: item, contentMode: .fill)
                                .frame(width: 100, height: 130)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ClosetAvatarView(
        items: [
            ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/top/200/300", category: .top),
            ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/bottom/200/300", category: .bottom),
            ClothingItem(ownerId: UUID(), imageUrl: "https://picsum.photos/seed/shoes/200/300", category: .shoes),
        ]
    )
}
