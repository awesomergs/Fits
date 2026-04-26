//
//  FeedCardView.swift
//  Fits
//
//  Full-screen TikTok layout + horizontal Tinder swipe for like/dislike.
//

import SwiftUI

struct FeedCardView: View {
    let outfit: Outfit
    let items: [ClothingItem]
    let profile: Profile?
    var onLike: (() -> Void)? = nil
    var onDislike: (() -> Void)? = nil
    var onSteal: (() -> Void)? = nil

    @GestureState private var dragX: CGFloat = 0
    @State private var stampDirection: CGFloat = 0   // 1 = like, -1 = dislike, 0 = none
    @State private var isStolen: Bool = false
    @State private var stealToastMessage: String? = nil

    private let threshold: CGFloat = 90

    var body: some View {
        ZStack {
            background

            HStack(alignment: .bottom, spacing: 0) {
                outfitContent
                actionSidebar
            }

            stampOverlay

            if let msg = stealToastMessage {
                VStack {
                    ToastView(message: msg)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .padding(.top, 60)
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: stealToastMessage != nil)
            }
        }
        // When reacted, snap back to center; during drag, follow finger
        .offset(x: stampDirection != 0 ? 0 : dragX)
        .rotationEffect(.degrees(stampDirection != 0 ? 0 : Double(dragX / 30)))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: stampDirection)
        .gesture(horizontalSwipeGesture)
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            Color.black

            if let first = items.first {
                ItemImageView(item: first, contentMode: .fill)
                    .blur(radius: 40)
                    .opacity(0.5)
                    .clipped()
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Outfit content

    private var outfitContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()
            itemsGrid

            VStack(alignment: .leading, spacing: 6) {
                profileRow

                if let caption = outfit.caption, !caption.isEmpty {
                    Text(caption)
                        .font(.fitsBody)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                }

                Text(outfit.occasion)
                    .font(.fitsCaption)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }

    private var itemsGrid: some View {
        let gridItems = Array(items.prefix(4))

        return Group {
            if gridItems.isEmpty {
                EmptyView()
            } else if gridItems.count == 1 {
                ItemImageView(item: gridItems[0], contentMode: .fill)
                    .frame(width: 200, height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.leading, 16)
            } else {
                LazyVGrid(
                    columns: [GridItem(.fixed(120)), GridItem(.fixed(120))],
                    spacing: 8
                ) {
                    ForEach(gridItems) { item in
                        ItemImageView(item: item, contentMode: .fill)
                            .frame(width: 120, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.leading, 16)
            }
        }
    }

    private var profileRow: some View {
        HStack(spacing: 8) {
            AsyncImage(url: profile?.avatarUrl.flatMap(URL.init)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Circle().fill(.white.opacity(0.3))
                }
            }
            .frame(width: 34, height: 34)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 1))

            VStack(alignment: .leading, spacing: 1) {
                Text(profile?.username ?? "User")
                    .font(.fitsCaption.weight(.semibold))
                    .foregroundStyle(.white)
                Text("@\(profile?.handle ?? "")")
                    .font(.micro)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
    }

    // MARK: - Action sidebar

    private var actionSidebar: some View {
        VStack(spacing: 24) {
            Spacer()

            AsyncImage(url: profile?.avatarUrl.flatMap(URL.init)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: Circle().fill(.white.opacity(0.3))
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))

            actionButton(systemImage: "heart.fill", label: "Like", color: .white) {
                triggerReaction(direction: 1)
            }

            actionButton(
                systemImage: isStolen ? "checkmark.circle.fill" : "tshirt.fill",
                label: isStolen ? "Stolen" : "Steal",
                color: isStolen ? FitsTheme.accent : .white
            ) {
                guard !isStolen else { return }
                isStolen = true
                onSteal?()
                showStealToast()
            }

            actionButton(systemImage: "xmark.circle.fill", label: "Pass", color: .white.opacity(0.7)) {
                triggerReaction(direction: -1)
            }
        }
        .padding(.trailing, 16)
        .padding(.bottom, 100)
        .frame(width: 80)
    }

    private func actionButton(
        systemImage: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(color)
                    .shadow(color: .black.opacity(0.4), radius: 4)
                Text(label)
                    .font(.micro)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Stamp overlay

    private var stampOverlay: some View {
        let likeOpacity: Double  = stampDirection > 0 ? 1 : (dragX > 20  ? min(Double(dragX  - 20) / 60, 1) : 0)
        let nopeOpacity: Double  = stampDirection < 0 ? 1 : (dragX < -20 ? min(Double(-dragX - 20) / 60, 1) : 0)

        return ZStack {
            Text("LIKE")
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(.green)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.green, lineWidth: 4))
                .rotationEffect(.degrees(-15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 80).padding(.leading, 20)
                .opacity(likeOpacity)

            Text("NOPE")
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(.red)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.red, lineWidth: 4))
                .rotationEffect(.degrees(15))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 80).padding(.trailing, 20)
                .opacity(nopeOpacity)
        }
    }

    // MARK: - Gesture

    private var horizontalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragX) { value, state, _ in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                state = value.translation.width
            }
            .onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > abs(value.translation.height) else { return }
                if dx > threshold { triggerReaction(direction: 1) }
                else if dx < -threshold { triggerReaction(direction: -1) }
            }
    }

    private func triggerReaction(direction: CGFloat) {
        guard stampDirection == 0 else { return }
        stampDirection = direction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if direction > 0 { onLike?() } else { onDislike?() }
            stampDirection = 0
        }
    }

    private func showStealToast() {
        let count = items.count
        stealToastMessage = "\(count) \(count == 1 ? "item" : "items") added to wishlist"
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            stealToastMessage = nil
        }
    }
}

// MARK: - micro font

private extension Font {
    static var micro: Font { .system(size: 11, weight: .medium) }
}

#Preview {
    let profile = Profile(
        id: UUID(),
        username: "Aria Chen",
        handle: "aria",
        avatarUrl: "https://i.pravatar.cc/150?img=47"
    )
    let outfit = Outfit(
        ownerId: profile.id,
        occasion: "Streetwear",
        itemIds: [],
        caption: "weekend fit 🖤",
        published: true
    )
    return FeedCardView(outfit: outfit, items: [], profile: profile)
        .background(Color.black)
}
