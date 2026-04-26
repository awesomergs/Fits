import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var showingMagicLinkPrompt = false

    var body: some View {
        ZStack {
            FitsTheme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Fits")
                        .font(.fitsTitle)
                        .foregroundStyle(FitsTheme.primary)

                    Text("Build outfits. Get feedback. Steal the fits you love.")
                        .font(.fitsBody)
                        .foregroundStyle(FitsTheme.primary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: 16) {
                    SignInWithAppleButton(
                        onRequest: { _ in },
                        onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)

                    Button(action: { showingMagicLinkPrompt = true }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Sign in with email")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(FitsTheme.primary)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                }

                if let error = authService.errorMessage {
                    Text(error)
                        .font(.fitsCaption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding(24)
        }
        .alert(
            "Sign in with email",
            isPresented: $showingMagicLinkPrompt,
            actions: {
                TextField("Email", text: $email)
                Button("Send link") {
                    Task {
                        await authService.signInWithMagicLink(email: email)
                        email = ""
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        )
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                authService.errorMessage = "Invalid Apple ID credential"
                return
            }

            guard let idTokenData = appleIDCredential.identityToken,
                  let idToken = String(data: idTokenData, encoding: .utf8) else {
                authService.errorMessage = "Failed to get ID token"
                return
            }

            let nonce = UUID().uuidString

            Task {
                await authService.signInWithApple(idToken: idToken, nonce: nonce)
            }

        case .failure(let error):
            authService.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    SignInView()
}
