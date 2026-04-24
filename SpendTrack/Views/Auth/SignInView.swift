import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue)
                    Text("SpendTrack")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                    Text("Track your spending, effortlessly.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        authService.handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    if let error = authService.authError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    if authService.hasBiometricHardware {
                        HStack(spacing: 6) {
                            Image(systemName: authService.biometryType == .faceID ? "faceid" : "touchid")
                                .foregroundStyle(.secondary)
                            Text("\(authService.biometryLabel) will lock the app after sign-in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Skip Sign In") {
                        authService.debugSignIn()
                    }
                    .font(.caption)
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal, 32)

                Spacer()

                Text("Your data is stored privately on this device.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
    }
}
