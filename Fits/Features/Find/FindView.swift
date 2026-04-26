//
//  FindView.swift
//  Fits
//

import SwiftUI

struct FindView: View {

    @State private var model = FindModel()

    var body: some View {
        ZStack {
            FitsTheme.background.ignoresSafeArea()

            VStack {

            // MARK: - Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(FitsTheme.primary.opacity(0.5))
                TextField("Search users...", text: $model.query)
                    .foregroundStyle(FitsTheme.primary)
                    .tint(FitsTheme.accent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(FitsTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(FitsTheme.muted, lineWidth: 1))
            .padding()
            .onChange(of: model.query) { _, newValue in
                model.search(newValue)
            }

            // MARK: - Content
            if model.isSearching {
                ProgressView()
                    .tint(FitsTheme.primary)
                    .padding()

            } else if !model.query.isEmpty {

                // MARK: - Search Results
                if model.searchResults.isEmpty {
                    Text("No results found")
                        .foregroundStyle(FitsTheme.primary.opacity(0.6))
                        .padding()
                } else {
                    List(model.searchResults, id: \.id) { profile in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(FitsTheme.accent)

                            VStack(alignment: .leading) {
                                Text(profile.username)
                                    .font(.fitsHeadline)
                                    .foregroundStyle(FitsTheme.primary)

                                Text(profile.id.uuidString)
                                    .font(.fitsCaption)
                                    .foregroundStyle(FitsTheme.primary.opacity(0.5))
                            }
                        }
                        .listRowBackground(FitsTheme.background)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

            } else {

                // MARK: - Category Rails (Netflix-style)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        ForEach(ItemCategory.allCases.filter { $0 != .fullBody }, id: \.self) { category in
                            CategoryRow(
                                title: category.displayName,
                                items: model.railItems(for: category),
                                model: model
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }  // VStack
        }  // ZStack
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let title: String
    let items: [ClothingItem]
    let model: FindModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {

                    ForEach(items, id: \.id) { item in
                        FindItemCard(item: item, model: model)
                    }
                }
            }
        }
    }
}

// MARK: - Find Item Card

struct FindItemCard: View {
    let item: ClothingItem
    let model: FindModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            ZStack(alignment: .topTrailing) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(FitsTheme.muted)
                        .frame(width: 140, height: 180)

                    ItemImageView(item: item, contentMode: .fill)
                        .frame(width: 140, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    model.addToWishlist(item)
                } label: {
                    Image(systemName: model.isInWishlist(item) ? "heart.fill" : "heart")
                        .foregroundStyle(model.isInWishlist(item) ? FitsTheme.accent : FitsTheme.primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(6)
            }

            Text(item.category.displayName)
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.7))
        }
    }
}

#Preview {
    FindView()
}
