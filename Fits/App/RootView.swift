import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        ZStack {
            TabBarView()

            if authService.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(AuthService.shared)
}
