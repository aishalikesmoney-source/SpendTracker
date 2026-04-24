import SwiftUI
import LocalAuthentication

struct LockView: View {
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            VStack(spacing: 8) {
                Text("SpendTrack")
                    .font(.title.bold())
                Text("Your finances are protected.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let error = authService.authError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                authService.requestAuthentication()
            } label: {
                Label(
                    "Unlock with \(authService.biometryLabel)",
                    systemImage: authService.biometryType == .faceID ? "faceid" : "touchid"
                )
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 32)
            }

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear { authService.requestAuthentication() }
    }
}
