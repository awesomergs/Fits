//
//  FeedView.swift
//  Fits
//

import SwiftUI

struct FeedView: View {
    @State private var model = FeedModel()

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
        .ignoresSafeArea()
        .onAppear { model.load() }
    }

    // MARK: - Vertical paging feed

    private var pagingFeed: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
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
                        .containerRelativeFrame([.horizontal, .vertical])
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
        }
    }

    private func scrollToNext(from index: Int, proxy: ScrollViewProxy) {
        let next = index + 1
        guard next < model.deck.count else { return }
        withAnimation(.easeInOut(duration: 0.4)) {
            proxy.scrollTo(model.deck[next].id, anchor: .top)
        }
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
