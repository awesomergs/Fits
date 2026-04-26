//
//  FeedCardView.swift
//  Fits
//

import SwiftUI

struct FeedCardView: View {
    let outfit: Outfit
    let items: [ClothingItem]
    let profile: Profile?
    var isTopCard: Bool = false
    var onLike: (() -> Void)? = nil
    var onDislike: (() -> Void)? = nil
    var onSteal: (() -> Void)? = nil

    @State private var dragOffset: CGSize = .zero
    @State private var isDismissing = false
    @State private var stealToastMessage: String? = nil

    private let swipeThreshold: CGFloat = 100

    private var isStolen: Bool { MockStore.shared.hasStolen(outfit.id) }

    var body: some View {
        ZStack(alignment: .bottom) {
            cardContent
                .rotationEffect(.degrees(Double(dragOffset.width) / 25))
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard isTopCard, !isDismissing else { return }
                            dragOffset = value.translation
                        }
                        .onEnded { value in
                            guard isTopCard, !isDismissing else { return }
                            let width = value.translation.width
                            if abs(width) > swipeThreshold {
                                flyOff(direction: width > 0 ? 1 : -1)
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    dragOffset = .zero
                                }
                            }
                        }
                )

            // Steal toast floats outside the card's clip shape
            if let message = stealToastMessage {
                ToastView(message: message)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: stealToastMessage != nil)
    }

    // MARK: - Card content

    private var cardContent: some View {
        VStack(spacing: 0) {
            profileHeader
            itemGrid
            footer
        }
        .background(FitsTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
        .overlay { stampOverlay }
        .overlay(alignment: .topTrailing) { stolenBadge }
    }

    // MARK: - Profile header

    private var profileHeader: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: profile?.avatarUrl ?? "")) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                default:
                    Circle().fill(FitsTheme.muted)
                }
            }
            .frame(width: 38, height: 38)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(profile?.username ?? "Unknown")
                    .font(.fitsCaption.weight(.semibold))
                    .foregroundStyle(FitsTheme.primary)
                Text("@\(profile?.handle ?? "")")
                    .font(.fitsCaption)
                    .foregroundStyle(FitsTheme.primary.opacity(0.5))
            }

            Spacer()

            Text(outfit.occasion)
                .font(.fitsCaption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(FitsTheme.highlight)
                .foregroundStyle(FitsTheme.primary)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Item scroll

    private var itemGrid: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(items) { item in
                    ItemImageView(item: item, contentMode: .fill)
                        .frame(width: 120, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let caption = outfit.caption, !caption.isEmpty {
                Text(caption)
                    .font(.fitsCaption)
                    .foregroundStyle(FitsTheme.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
            }
            actionButtons
        }
    }

    private var actionButtons: some View {
        HStack {
            Spacer()

            // Dislike
            Button {
                guard !isDismissing else { return }
                flyOff(direction: -1)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.red.opacity(0.75))
            }

            Spacer()

            // Steal this fit
            Button {
                guard !isStolen else { return }
                onSteal?()
                triggerStealToast()
            } label: {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(isStolen ? FitsTheme.accent : FitsTheme.primary)
            }

            Spacer()

            // Like
            Button {
                guard !isDismissing else { return }
                flyOff(direction: 1)
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(FitsTheme.accent)
            }

            Spacer()
        }
        .padding(.vertical, 14)
        .disabled(!isTopCard)
    }

    // MARK: - Stolen badge

    @ViewBuilder
    private var stolenBadge: some View {
        if isStolen {
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                Text("Stolen")
                    .font(.fitsCaption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(FitsTheme.primary)
            .clipShape(Capsule())
            .padding(12)
        }
    }

    // MARK: - Stamp overlay

    private var stampOverlay: some View {
        ZStack {
            stampLabel("LIKE", color: .green, rotation: -15, alignment: .topLeading)
                .opacity(dragOffset.width > 20 ? min(Double(dragOffset.width - 20) / 60, 1) : 0)

            stampLabel("NOPE", color: .red, rotation: 15, alignment: .topTrailing)
                .opacity(dragOffset.width < -20 ? min(Double(-dragOffset.width - 20) / 60, 1) : 0)
        }
    }

    private func stampLabel(
        _ text: String,
        color: Color,
        rotation: Double,
        alignment: Alignment
    ) -> some View {
        Text(text)
            .font(.system(size: 36, weight: .black))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(color, lineWidth: 3))
            .rotationEffect(.degrees(rotation))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            .padding(20)
    }

    // MARK: - Actions

    private func flyOff(direction: CGFloat) {
        isDismissing = true
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(width: direction * 1200, height: 100)
        } completion: {
            if direction > 0 { onLike?() } else { onDislike?() }
        }
    }

    private func triggerStealToast() {
        let count = items.count
        let noun = count == 1 ? "item" : "items"
        stealToastMessage = "\(count) \(noun) added to your wishlist"
        Task {
            try? await Task.sleep(for: .seconds(2))
            stealToastMessage = nil
        }
    }
}

#Preview {
    let profile = Profile(
        id: UUID(),
        username: "Aria Chen",
        handle: "aria",
        avatarUrl: "https://i.pravatar.cc/150?img=47",
        bio: nil,
        createdAt: .now
    )
    let outfit = Outfit(
        ownerId: profile.id,
        occasion: "Streetwear",
        itemIds: [],
        caption: "weekend fit 🖤",
        published: true
    )
    return FeedCardView(outfit: outfit, items: [], profile: profile, isTopCard: true)
        .padding(20)
        .background(FitsTheme.background)
}
