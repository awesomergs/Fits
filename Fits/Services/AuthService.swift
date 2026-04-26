import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: Profile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let mockStore = MockStore.shared

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        isAuthenticated = true
        currentUser = mockStore.currentUser
    }

    private func loadCurrentProfile() {
        currentUser = mockStore.currentUser
    }

    func signInWithMagicLink(email: String) {
        isLoading = true
        errorMessage = nil
        isAuthenticated = true
        currentUser = mockStore.currentUser
        isLoading = false
    }

    func signInWithApple(idToken: String, nonce: String) {
        isLoading = true
        errorMessage = nil
        isAuthenticated = true
        currentUser = mockStore.currentUser
        isLoading = false
    }

    func signOut() {
        isLoading = true
        errorMessage = nil
        isAuthenticated = false
        currentUser = nil
        isLoading = false
    }

    func updateProfile(username: String? = nil, handle: String? = nil, bio: String? = nil) {
        isLoading = true
        errorMessage = nil
        loadCurrentProfile()
        isLoading = false
    }

    func updateProfileAvatar(_ imageData: Data) {
        isLoading = true
        errorMessage = nil
        loadCurrentProfile()
        isLoading = false
    }
}
