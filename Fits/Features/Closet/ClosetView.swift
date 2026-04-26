//
//  ClosetView.swift
//  Fits
//

import SwiftUI

struct ClosetView: View {
    @State private var model = ClosetModel()
    @State private var showingBuilder = false

    var body: some View {
        NavigationStack {
            ZStack {
                FitsTheme.background.ignoresSafeArea()

                if model.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            ForEach(model.populatedCategories, id: \.self) { category in
                                categorySection(for: category)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Closet")
            .toolbar {
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

    // MARK: - Category section

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

            Text("Tap  +  to tag your first item")
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.6))
        }
    }
}

#Preview {
    ClosetView()
}
