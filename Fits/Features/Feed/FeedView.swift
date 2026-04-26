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
        .task { await model.load() }
    }

    // MARK: - Vertical paging feed

    private var pagingFeed: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(model.deck) { outfit in
                    FeedCardView(
                        outfit: outfit,
                        items: model.items(for: outfit),
                        profile: model.profile(for: outfit),
                        onLike: {
                            Task { await model.react(to: outfit, kind: .like) }
                        },
                        onDislike: {
                            Task { await model.react(to: outfit, kind: .dislike) }
                        },
                        onSteal: {
                            Task { await model.steal(outfit) }
                        }
                    )
                    .containerRelativeFrame([.horizontal, .vertical])
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
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
