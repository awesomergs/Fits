//
//  ProfileView.swift
//  Fits
//

import SwiftUI

struct ProfileView: View {
    @State private var model: ProfileModel
    @State private var tryOnItems: [ClothingItem] = []
    @State private var showTryOn = false

    init(userId: UUID? = nil) {
        _model = State(initialValue: ProfileModel(userId: userId))
    }

    private let threeCol = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationStack {
            ZStack {
                FitsTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        profileHeader
                        Divider().padding(.vertical, 20)
                        outfitSection
                        Divider().padding(.vertical, 20)
                        itemsSection
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle(
                model.profile.map { "@\($0.handle)" } ?? "Profile"
            )
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTryOn) {
                ClosetAvatarView(items: tryOnItems, preloadedItems: tryOnItems, onSave: { showTryOn = false })
            }
        }
        .onAppear {
            model.load()
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: model.profile?.avatarUrl.flatMap(URL.init)) { phase in
                switch phase {
                case .success(let img):
                    img
                        .resizable()
                        .scaledToFill()
                default:
                    Circle()
                        .fill(FitsTheme.muted)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(FitsTheme.primary.opacity(0.4))
                                .font(.system(size: 32))
                        )
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.08), radius: 8, y: 2)

            VStack(spacing: 4) {
                Text(model.profile?.username ?? "—")
                    .font(.fitsHeadline)
                    .foregroundStyle(FitsTheme.primary)

                if let handle = model.profile?.handle {
                    Text("@\(handle)")
                        .font(.fitsCaption)
                        .foregroundStyle(FitsTheme.primary.opacity(0.5))
                }

                if let bio = model.profile?.bio {
                    Text(bio)
                        .font(.fitsCaption)
                        .foregroundStyle(FitsTheme.primary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
            }

            statsRow
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(value: "\(model.outfits.count)", label: "Outfits")

            Rectangle()
                .fill(FitsTheme.muted)
                .frame(width: 1, height: 32)

            statCell(value: "\(model.recentItems.count)", label: "Items")
        }
        .padding(.top, 8)
        .padding(.horizontal, 20)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)

            Text(label)
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Outfits section

    private var outfitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Outfits")

            if model.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)

            } else if model.outfits.isEmpty {
                emptyLabel("No outfits published yet")

            } else {
                LazyVGrid(columns: threeCol, spacing: 2) {
                    ForEach(model.outfits) { outfit in
                        outfitCell(outfit)
                    }
                }
            }
        }
    }

    private func outfitCell(_ outfit: Outfit) -> some View {
        let items = model.items(for: outfit)
        let coverItem = items.first

        return Button {
            tryOnItems = items
            showTryOn = true
        } label: {
            Color.clear
                .aspectRatio(1, contentMode: .fill)
                .overlay {
                    if let item = coverItem {
                        ItemImageView(item: item, contentMode: .fill)
                            .clipped()
                    } else {
                        Rectangle().fill(FitsTheme.muted)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Text(outfit.occasion)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(5)
                }
                .clipped()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Items section

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Recent Items")

            if model.recentItems.isEmpty {
                emptyLabel("Tag some items to see them here")

            } else {
                LazyVGrid(columns: threeCol, spacing: 2) {
                    ForEach(model.recentItems) { item in
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                            .overlay {
                                ItemImageView(item: item, contentMode: .fill)
                                    .clipped()
                            }
                            .overlay(alignment: .topTrailing) {
                                if item.isWishlist {
                                    Image(systemName: "bookmark.fill")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(FitsTheme.accent)
                                        .padding(4)
                                }
                            }
                            .clipped()
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.fitsHeadline)
            .foregroundStyle(FitsTheme.primary)
            .padding(.horizontal, 16)
    }

    private func emptyLabel(_ message: String) -> some View {
        Text(message)
            .font(.fitsCaption)
            .foregroundStyle(FitsTheme.primary.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }
}

#Preview {
    ProfileView()
}
