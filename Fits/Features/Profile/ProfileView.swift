//
//  ProfileView.swift
//  Fits
//

import SwiftUI

struct ProfileView: View {
    @State private var model: ProfileModel

    init(userId: UUID = MockStore.shared.currentUser.id) {
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
                        Divider().padding(.vertical, 20)
                        favoritesPlaceholder
                            .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle(model.profile.map { "@\($0.handle)" } ?? "Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var profileHeader: some View {
        VStack(spacing: 12) {
            AsyncImage(url: URL(string: model.profile?.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Circle().fill(FitsTheme.muted)
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

                Text("@\(model.profile?.handle ?? "")")
                    .font(.fitsCaption)
                    .foregroundStyle(FitsTheme.primary.opacity(0.5))

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
            statCell(
                value: formatted(model.profile?.followerCount ?? 0),
                label: "Followers"
            )
            Rectangle()
                .fill(FitsTheme.muted)
                .frame(width: 1, height: 32)
            statCell(
                value: formatted(model.profile?.followingCount ?? 0),
                label: "Following"
            )
            Rectangle()
                .fill(FitsTheme.muted)
                .frame(width: 1, height: 32)
            statCell(
                value: "\(model.outfits.count)",
                label: "Outfits"
            )
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

    private func formatted(_ n: Int) -> String {
        n >= 1000 ? String(format: "%.1fk", Double(n) / 1000) : "\(n)"
    }

    // MARK: - Outfits section

    private var outfitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Outfits")

            if model.outfits.isEmpty {
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
        let cover = MockStore.shared.itemsByIds(outfit.itemIds).first
        return Color.clear
            .aspectRatio(1, contentMode: .fill)
            .overlay {
                if let item = cover {
                    ItemImageView(item: item, contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    // MARK: - Favorites placeholder

    private var favoritesPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Favorites")
            emptyLabel("Coming soon")
        }
    }

    // MARK: - Shared helpers

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
