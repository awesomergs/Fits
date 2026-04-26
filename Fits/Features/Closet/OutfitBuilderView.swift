//
//  OutfitBuilderView.swift
//  Fits
//

import SwiftUI

struct OutfitBuilderView: View {
    @State private var model = OutfitBuilderModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                FitsTheme.background.ignoresSafeArea()

                if model.availableCategories.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            occasionPicker
                            categorySections
                        }
                        .padding(.vertical, 20)
                        .padding(.bottom, 96)
                    }
                }

                VStack(spacing: 12) {
                    if model.showSuccessToast {
                        ToastView(message: "Outfit published!")
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    publishButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.showSuccessToast)
            }
            .navigationTitle("Build a Fit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(FitsTheme.primary)
                }
            }
        }
        .task { await model.load() }
    }

    // MARK: - Occasion picker

    private var occasionPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Occasion")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(model.occasions, id: \.self) { occasion in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                model.selectedOccasion = occasion
                            }
                        } label: {
                            Text(occasion)
                                .font(.fitsCaption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    model.selectedOccasion == occasion
                                        ? FitsTheme.primary
                                        : FitsTheme.surface
                                )
                                .foregroundStyle(
                                    model.selectedOccasion == occasion
                                        ? Color.white
                                        : FitsTheme.primary
                                )
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Category carousels

    private var categorySections: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Pick your items")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
                .padding(.horizontal, 20)

            ForEach(model.availableCategories, id: \.self) { category in
                SlotCarousel(
                    category: category,
                    items: model.items(for: category),
                    selection: Binding(
                        get: { model.picks[category] },
                        set: { model.picks[category] = $0 }
                    )
                )
            }
        }
    }

    // MARK: - Publish button

    private var publishButton: some View {
        Button {
            Task {
                await model.publish()
                // Brief pause so the toast is visible before dismissing
                try? await Task.sleep(for: .seconds(1.5))
                dismiss()
            }
        } label: {
            HStack(spacing: 8) {
                if model.isPublishing {
                    ProgressView().tint(.white).scaleEffect(0.8)
                }
                Text(model.isPublishing ? "Publishing…" : "Publish Outfit")
                    .font(.fitsBody.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(model.canPublish ? FitsTheme.primary : FitsTheme.muted)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!model.canPublish)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.canPublish)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.isPublishing)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tshirt")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(FitsTheme.muted)
            Text("Nothing to build with yet")
                .font(.fitsHeadline)
                .foregroundStyle(FitsTheme.primary)
            Text("Tag some items first, then come back here")
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    OutfitBuilderView()
}
