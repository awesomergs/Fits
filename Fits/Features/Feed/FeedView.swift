//
//  FeedView.swift
//  Fits
//

import SwiftUI

struct FeedView: View {
    @State private var model = FeedModel()

    var body: some View {
        NavigationStack {
            ZStack {
                FitsTheme.background.ignoresSafeArea()
                content
            }
            .navigationTitle("Fits")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task { model.load() }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if model.isLoading {
            ProgressView().tint(FitsTheme.primary)
        } else if model.deck.isEmpty {
            emptyState
        } else {
            cardStack
        }
    }

    // MARK: - Card stack

    private var cardStack: some View {
        let shown = Array(model.deck.prefix(3))
        return ZStack {
            ForEach(Array(shown.enumerated()), id: \.element.id) { idx, outfit in
                FeedCardView(
                    outfit: outfit,
                    items: model.items(for: outfit),
                    profile: model.profile(for: outfit),
                    isTopCard: idx == 0,
                    onLike: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            model.react(to: outfit, kind: .like)
                        }
                    },
                    onDislike: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            model.react(to: outfit, kind: .dislike)
                        }
                    },
                    onSteal: {
                        model.steal(outfit)
                    }
                )
                .scaleEffect(1.0 - CGFloat(idx) * 0.04)
                .offset(y: CGFloat(idx) * 10)
                .zIndex(Double(shown.count - idx))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: model.deck.count)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(FitsTheme.muted)
            Text("You're all caught up")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
            Text("Follow some people to see their fits")
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.6))
        }
    }
}

#Preview {
    FeedView()
}
