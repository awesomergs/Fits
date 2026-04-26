//
//  FindView.swift
//  Fits
//

import SwiftUI

struct FindView: View {

    @State private var model = FindModel()
    @State private var selectedProfile: Profile? = nil
    @State private var showProfile = false

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
                        Button {
                            selectedProfile = profile
                            showProfile = true
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(FitsTheme.accent)

                                VStack(alignment: .leading) {
                                    Text(profile.username)
                                        .font(.fitsHeadline)
                                        .foregroundStyle(FitsTheme.primary)

                                    Text("@\(profile.username.lowercased())")
                                        .font(.fitsCaption)
                                        .foregroundStyle(FitsTheme.primary.opacity(0.5))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(FitsTheme.muted)
                            }
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(FitsTheme.background)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .sheet(item: $selectedProfile) { profile in
                        MiniProfileView(profile: profile)
                    }
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
        .task {
            ItemCategory.allCases.filter { $0 != .fullBody }.forEach {
                model.loadRailItems(for: $0)
            }
            model.loadWishlist()
        }
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
                LazyHStack(spacing: 12) {

                    ForEach(Array(items.dropFirst()), id: \.imageUrl) { item in
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

// MARK: - Mini Profile

struct MiniProfileView: View {
    let profile: Profile

    @State private var topOutfit: Outfit? = nil
    @State private var outfitItems: [ClothingItem] = []

    private let store = MockStore.shared

    var body: some View {
        ZStack {
            FitsTheme.background.ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                VStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(FitsTheme.accent)

                    Text(profile.username)
                        .font(.fitsHeadline)
                        .foregroundStyle(FitsTheme.primary)

                    Text("@\(profile.username.lowercased())")
                        .font(.fitsCaption)
                        .foregroundStyle(FitsTheme.primary.opacity(0.5))
                }
                .padding(.top, 20)

                // Top outfit
                if let outfit = topOutfit {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Latest Fit")
                                .font(.fitsHeadline)
                                .foregroundStyle(FitsTheme.primary)
                            Spacer()
                            Text(outfit.occasion)
                                .font(.fitsCaption)
                                .foregroundStyle(FitsTheme.primary.opacity(0.5))
                        }
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(outfitItems) { item in
                                    ItemImageView(item: item, contentMode: .fill)
                                        .frame(width: 110, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                } else {
                    Text("No outfits yet")
                        .font(.fitsCaption)
                        .foregroundStyle(FitsTheme.primary.opacity(0.5))
                        .padding(.top, 20)
                }

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            topOutfit = store.outfitsByUser(profile.id).first
            if let outfit = topOutfit {
                outfitItems = store.itemsByIds(outfit.itemIds)
            }
        }
    }
}

#Preview {
    FindView()
}
