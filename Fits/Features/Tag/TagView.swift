//
//  TagView.swift
//  Fits
//

import SwiftUI
import PhotosUI
import UIKit

struct TagView: View {
    @State private var model = TagModel()
    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                FitsTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        imageArea

                        if model.pickedImage != nil {
                            categorySection
                            wishlistRow
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 96)
                    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.pickedImage != nil)
                }

                VStack(spacing: 12) {
                    if model.showSuccessToast {
                        ToastView(message: model.isWishlist ? "Added to your wishlist" : "Added to your closet")
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    if model.pickedImage != nil {
                        saveButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.pickedImage != nil)
                .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.showSuccessToast)
            }
            .navigationTitle("Tag")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: pickerItem) { _, item in
            Task { await model.load(from: item) }
        }
        // When the model resets pickedImage, also clear the picker so tapping
        // the same photo again will re-trigger onChange.
        .onChange(of: model.pickedImage) { _, image in
            if image == nil { pickerItem = nil }
        }
    }

    // MARK: - Image area

    @ViewBuilder
    private var imageArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(FitsTheme.muted.opacity(0.3))
                .frame(width: 260, height: 360)

            if let image = model.pickedImage {
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 360)
                        .background(FitsTheme.muted.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            } else if model.isLoadingImage {
                ProgressView().tint(FitsTheme.primary)
                    .frame(width: 260, height: 360)
            } else {
                HStack(spacing: 24) {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        sourceOption(icon: "photo.on.rectangle", label: "Library")
                    }
                    .buttonStyle(.plain)

                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button { showCamera = true } label: {
                            sourceOption(icon: "camera.fill", label: "Camera")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 260, height: 360)
            }

            if model.isProcessingCutout {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.4))
                    .frame(width: 260, height: 360)
                    .overlay {
                        VStack(spacing: 10) {
                            ProgressView().tint(.white)
                            Text("Removing background…")
                                .font(.fitsCaption)
                                .foregroundStyle(.white)
                        }
                    }
                    .allowsHitTesting(false)
            }
        }
        .frame(width: 260, height: 360)
        .sheet(isPresented: $showCamera) {
            CameraPickerView { image in
                DispatchQueue.main.async { showCamera = false }
                Task { await model.load(from: image) }
            }
            .ignoresSafeArea()
        }
    }

    private func sourceOption(icon: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(FitsTheme.primary)
            Text(label)
                .font(.fitsCaption)
                .foregroundStyle(FitsTheme.primary.opacity(0.7))
        }
    }

    // MARK: - Category picker

    private var categorySection: some View {
        HStack {
            Text("Category")
                .font(.fitsBody)
                .foregroundStyle(FitsTheme.primary)

            Spacer()

            Picker("Category", selection: $model.selectedCategory) {
                Text("Select…").tag(Optional<ItemCategory>.none)
                ForEach(ItemCategory.allCases, id: \.self) { cat in
                    Text(cat.displayName).tag(Optional(cat))
                }
            }
            .pickerStyle(.menu)
            .tint(FitsTheme.primary)
        }
        .padding(16)
        .background(FitsTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Wishlist toggle

    private var wishlistRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Add to wishlist")
                    .font(.fitsBody)
                    .foregroundStyle(FitsTheme.primary)
                Text("I want this but don't own it yet")
                    .font(.fitsCaption)
                    .foregroundStyle(FitsTheme.primary.opacity(0.6))
            }

            Spacer()

            Toggle("", isOn: $model.isWishlist)
                .tint(FitsTheme.accent)
                .labelsHidden()
        }
        .padding(16)
        .background(FitsTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button {
            Task { await model.save() }
        } label: {
            HStack(spacing: 8) {
                if model.isSaving {
                    ProgressView().tint(.white).scaleEffect(0.8)
                }
                Text(model.isSaving ? "Saving…" : "Save to Closet")
                    .font(.fitsBody.weight(.semibold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(model.canSave ? FitsTheme.primary : FitsTheme.muted)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!model.canSave)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.canSave)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: model.isSaving)
    }
}

// MARK: - Camera picker

struct CameraPickerView: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImage: (UIImage) -> Void
        init(onImage: @escaping (UIImage) -> Void) { self.onImage = onImage }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                onImage(image)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    TabView {
        TagView()
            .tabItem { Label("Tag", systemImage: "plus.circle.fill") }
    }
}
