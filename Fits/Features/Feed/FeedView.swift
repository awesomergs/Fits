//
//  FeedView.swift
//  Fits
//

import SwiftUI

struct FeedView: View {
    @State private var model = FeedModel()
    private let endCardID = "feed-end"

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch true {
            case model.isLoading:
                ProgressView().tint(.white)
            case model.deck.isEmpty && !model.isLoading:
                emptyState
            default:
                pagingFeed
            }
        }
        .onAppear { model.load() }
    }

    // MARK: - Scrolling feed

    private var pagingFeed: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 16) {
                    ForEach(Array(model.deck.enumerated()), id: \.element.id) { index, outfit in
                        FeedCardView(
                            outfit: outfit,
                            items: model.items(for: outfit),
                            profile: model.profile(for: outfit),
                            onLike: {
                                model.react(to: outfit, kind: .like)
                                scrollToNext(from: index, proxy: proxy)
                            },
                            onDislike: {
                                model.react(to: outfit, kind: .dislike)
                                scrollToNext(from: index, proxy: proxy)
                            },
                            onSteal: {
                                model.steal(outfit)
                            }
                        )
                        .id(outfit.id)
                        .frame(maxWidth: .infinity)
                        .frame(height: 560)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    endCard.id(endCardID)
                }
                .scrollTargetLayout()
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
    }

    private func scrollToNext(from index: Int, proxy: ScrollViewProxy) {
        let next = index + 1
        withAnimation(.easeInOut(duration: 0.4)) {
            if next < model.deck.count {
                proxy.scrollTo(model.deck[next].id, anchor: .top)
            } else {
                proxy.scrollTo(endCardID, anchor: .top)
            }
        }
    }

    // MARK: - End card

    private var endCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )

            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(.white.opacity(0.5))
                Text("You're all caught up")
                    .font(.fitsHeadline)
                    .foregroundStyle(.white)
                Text("You've reached the end of your feed")
                    .font(.fitsCaption)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 560)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(.white.opacity(0.4))
            Text("You're all caught up")
                .font(.fitsHeadline)
                .foregroundStyle(.white)
            Text("Follow people to see their fits")
                .font(.fitsCaption)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    FeedView()
}
