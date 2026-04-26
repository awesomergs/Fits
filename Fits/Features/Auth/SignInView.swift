//
//  SignInView.swift
//

import SwiftUI

struct SignInView: View {
    @StateObject private var authService = AuthService.shared
    @State private var email = ""
    @State private var showingEmailPrompt = false

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

                Button {
                    showingEmailPrompt = true
                } label: {
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

                Spacer()
            }
            .padding(24)
        }
        .alert(
            "Sign in",
            isPresented: $showingEmailPrompt,
            actions: {
                TextField("Email", text: $email)

                Button("Continue") {
                    let enteredEmail = email
                    showingEmailPrompt = false
                    email = ""
                    guard !enteredEmail.isEmpty else { return }
                    dummySignIn(email: enteredEmail)
                }

                Button("Cancel", role: .cancel) {}
            }
        )
    }

    private func dummySignIn(email: String) {
        let handle = email.components(separatedBy: "@").first ?? "user"
        authService.currentUser = Profile(
            id: UUID(),
            username: handle,
            handle: handle
        )
        authService.isAuthenticated = true
    }
}

#Preview {
    SignInView()
}
