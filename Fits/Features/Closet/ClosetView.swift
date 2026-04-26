//
//  ClosetView.swift
//  Fits
//

import SwiftUI

struct ClosetView: View {
    @State private var model = ClosetModel()
    @State private var showingBuilder = false
    @State private var viewMode: ClosetViewMode = .shelves
    @State private var selectedOutfitId: UUID? = nil

    enum ClosetViewMode: String, CaseIterable {
        case shelves = "Shelves"
        case avatar  = "Try On"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FitsTheme.background.ignoresSafeArea()

                if model.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("Closet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("View", selection: $viewMode) {
                        ForEach(ClosetViewMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingBuilder = true
                    } label: {
                        Label("Build a Fit", systemImage: "rectangle.stack.badge.plus")
                            .labelStyle(.iconOnly)
                            .foregroundStyle(FitsTheme.primary)
                    }
                    .disabled(model.isEmpty)
                }
            }
            .sheet(isPresented: $showingBuilder) {
                OutfitBuilderView()
            }
        }
    }

    // MARK: - Content switcher

    private var selectedOutfitItems: [ClothingItem] {
        guard let id = selectedOutfitId,
              let outfit = model.myOutfits.first(where: { $0.id == id }) else { return [] }
        return model.items(for: outfit)
    }

    @ViewBuilder
    private var content: some View {
        switch viewMode {
        case .shelves:
            shelvesView
        case .avatar:
            VStack(spacing: 0) {
                if !model.myOutfits.isEmpty {
                    outfitPicker
                }
                ClosetAvatarView(items: model.allItems, preloadedItems: selectedOutfitItems, onSave: {
                    viewMode = .shelves
                    selectedOutfitId = nil
                })
                    .id(selectedOutfitId?.uuidString ?? "custom")
            }
        }
    }

    private var outfitPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(label: "Custom", isSelected: selectedOutfitId == nil) {
                    selectedOutfitId = nil
                }
                ForEach(model.myOutfits) { outfit in
                    chipButton(label: outfit.occasion, isSelected: selectedOutfitId == outfit.id) {
                        selectedOutfitId = outfit.id
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(FitsTheme.background)
    }

    private func chipButton(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.fitsCaption)
                .foregroundStyle(isSelected ? .white : FitsTheme.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? FitsTheme.accent : FitsTheme.surface)
                .clipShape(Capsule())
                .overlay(Capsule().strokeBorder(FitsTheme.muted.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shelves view

    private var shelvesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(model.populatedCategories, id: \.self) { category in
                    categorySection(for: category)
                }
            }
            .padding(.vertical, 20)
        }
    }

    private func categorySection(for category: ItemCategory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName)
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(model.items(for: category)) { item in
                        ItemCard(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(FitsTheme.muted)

            Text("Your closet is empty")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)

            Text("Tap + to tag your first item")
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.6))
        }
    }
}

#Preview {
    ClosetView()
}
