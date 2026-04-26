//
//  TabBarView.swift
//  Fits
//

import SwiftUI
import PhotosUI

struct TabBarView: View {
    var body: some View {
        TabView {
            PlaceholderView(title: "Feed")
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

            PlaceholderView(title: "Closet")
                .tabItem {
                    Label("Closet", systemImage: "tshirt")
                }

            PlaceholderView(title: "Profile")
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
