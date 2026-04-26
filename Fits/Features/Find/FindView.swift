//
//  FindView.swift
//  Fits
//

import SwiftUI

struct FindView: View {
    
    @State private var model = FindModel()
    
    var body: some View {
        VStack {
            
            // MARK: - Search Bar
            TextField("Search users...", text: $model.query)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: model.query) { _, newValue in
                    model.search(newValue)
                }
            
            // MARK: - Content
            if model.isSearching {
                ProgressView()
                    .padding()
                
            } else if !model.query.isEmpty {
                
                // MARK: - Search Results
                if model.searchResults.isEmpty {
                    Text("No results found")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    List(model.searchResults, id: \.id) { profile in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                            
                            VStack(alignment: .leading) {
                                Text(profile.username)
                                    .font(.headline)
                                
                                Text(profile.id.uuidString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
            } else {
                
                // MARK: - Category Rails (Netflix-style)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        ForEach(ItemCategory.allCases.filter { $0 != .fullBody }, id: \.self) { category in
                            CategoryRow(
                                title: category.displayName,
                                items: model.railItems(for: category),
                                model: model
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let title: String
    let items: [ClothingItem]
    let model: FindModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title)
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    ForEach(items, id: \.id) { item in
                        FindItemCard(item: item, model: model)
                    }
                }
            }
        }
    }
}

// MARK: - Find Item Card

struct FindItemCard: View {
    let item: ClothingItem
    let model: FindModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            ZStack(alignment: .topTrailing) {
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 140, height: 180)
                    .cornerRadius(12)
                
                Button {
                    Task {
                        await model.addToWishlist(item) // ✅ FIXED
                    }
                } label: {
                    Image(systemName: model.isInWishlist(item) ? "heart.fill" : "heart")
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(6)
            }
            
            Text(item.category.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    FindView()
}
