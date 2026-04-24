import Foundation
import LocalAuthentication
import AuthenticationServices

@MainActor
final class AuthenticationService: ObservableObject {
    @Published var isSignedIn = false
    @Published var isUnlocked = false
    @Published var authError: String?

    private let appleUserIdKey = "spendtrack_apple_user_id"

    var isBiometricEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isBiometricEnabled) }
        set { UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultsKeys.isBiometricEnabled) }
    }

    var biometryType: LABiometryType {
        let ctx = LAContext()
        _ = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return ctx.biometryType
    }

    var biometryLabel: String {
        switch biometryType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        default:       return "Biometrics"
        }
    }

    var hasBiometricHardware: Bool {
        let ctx = LAContext()
        return ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    // MARK: - Apple Sign In

    func checkAppleCredentialState() {
        guard let userId = KeychainService.get(appleUserIdKey) else {
            isSignedIn = false
            return
        }
        let key = appleUserIdKey
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userId) { [weak self] state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self?.isSignedIn = true
                case .revoked, .notFound, .transferred:
                    self?.isSignedIn = false
                    KeychainService.delete(key)
                @unknown default:
                    self?.isSignedIn = false
                }
            }
        }
    }

    func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
            KeychainService.save(credential.user, for: appleUserIdKey)
            completeSignIn()
        case .failure(let error):
            authError = error.localizedDescription
        }
    }

    func debugSignIn() {
        isSignedIn = true
        isUnlocked = true
        authError = nil
    }

    func signOut() {
        isUnlocked = false
        isSignedIn = false
        authError = nil
        KeychainService.delete(appleUserIdKey)
    }

    private func completeSignIn() {
        isSignedIn = true
        authError = nil
        if isBiometricEnabled {
            requestAuthentication()
        } else {
            isUnlocked = true
        }
    }

    // MARK: - Biometric unlock

    func requestAuthentication() {
        guard isBiometricEnabled else {
            isUnlocked = true
            return
        }
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            isUnlocked = true
            return
        }
        ctx.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock SpendTrack to view your finances"
        ) { success, err in
            let errMsg = err?.localizedDescription
            DispatchQueue.main.async { [weak self] in
                if success {
                    self?.isUnlocked = true
                    self?.authError = nil
                } else {
                    self?.authError = errMsg
                }
            }
        }
    }

    func lock() {
        isUnlocked = false
    }
}
