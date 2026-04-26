import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: Profile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let http = SupabaseHTTPClient.shared
    private let supabase = SupabaseService.shared

    init() {
        Task { @MainActor in
            await checkAuthStatus()
        }
    }

    func checkAuthStatus() async {
        if http.currentUserId != nil {
            isAuthenticated = true
            await loadCurrentProfile()
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }

    private func loadCurrentProfile() async {
        do {
            let profile = try await supabase.currentProfile()
            currentUser = profile
        } catch {
            print("Failed to load current profile: \(error)")
            errorMessage = "Failed to load profile"
        }
    }

    func signInWithMagicLink(email: String) async {
        isLoading = true
        defer { isLoading = false }

        errorMessage = nil
        do {
            try await http.signInWithMagicLink(email: email)
        } catch {
            print("Magic link sign-in failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func signInWithApple(idToken: String, nonce: String) async {
        isLoading = true
        defer { isLoading = false }

        errorMessage = nil
        do {
            try await http.signInWithIdToken(provider: "apple", idToken: idToken, nonce: nonce)
            isAuthenticated = true
            await loadCurrentProfile()
        } catch {
            print("Apple sign-in failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        isLoading = true
        defer { isLoading = false }

        errorMessage = nil
        do {
            try await http.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            print("Sign out failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func updateProfile(username: String? = nil, handle: String? = nil, bio: String? = nil) async {
        isLoading = true
        defer { isLoading = false }

        errorMessage = nil
        do {
            try await supabase.updateProfile(username: username, handle: handle, bio: bio)
            await loadCurrentProfile()
        } catch {
            print("Profile update failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    func updateProfileAvatar(_ imageData: Data) async {
        isLoading = true
        defer { isLoading = false }

        errorMessage = nil
        do {
            guard let userId = http.currentUserId else {
                throw SupabaseHTTPError.notAuthenticated
            }

            let avatarUrl = try await ImageUploadService.shared
                .uploadAvatarImage(imageData, userId: userId)

            try await supabase.updateProfile(avatarUrl: avatarUrl)
            await loadCurrentProfile()
        } catch {
            print("Avatar upload failed: \(error)")
            errorMessage = error.localizedDescription
        }
    }
}
