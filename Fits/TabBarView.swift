//
//  TabBarView.swift
//  Fits
//

import SwiftUI
import PhotosUI

struct TabBarView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "house")
                }

            PlaceholderView(title: "Find")
                .tabItem {
                    Label("Find", systemImage: "magnifyingglass")
                }

            TagView()
                .tabItem {
                    Label("Tag", systemImage: "plus.circle.fill")
                }

            ClosetView()
                .tabItem {
                    Label("Closet", systemImage: "tshirt")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(.dustyMauve)
    }
}

private struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.fitsHeadline)
            Text("is a work in progress")
                .font(.fitsBody)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TabBarView()
}
