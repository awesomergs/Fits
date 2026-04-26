//
//  FitsApp.swift
//  Fits
//

import SwiftUI

@main
struct FitsApp: App {
    @StateObject private var authService = AuthService.shared

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                TabBarView()
                    .environmentObject(authService)
            } else {
                SignInView()
                    .environmentObject(authService)
            }
        }
    }
}
