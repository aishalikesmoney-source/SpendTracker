import Foundation
import LocalAuthentication

@MainActor
final class AuthenticationService: ObservableObject {
    @Published var isUnlocked = false
    @Published var authError: String?

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

    func requestAuthentication() {
        guard isBiometricEnabled else {
            isUnlocked = true
            return
        }
        let ctx = LAContext()
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Fallback: allow access if biometrics not available on device
            isUnlocked = true
            return
        }
        ctx.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock SpendTrack to view your finances"
        ) { [weak self] success, err in
            DispatchQueue.main.async {
                if success {
                    self?.isUnlocked = true
                    self?.authError = nil
                } else {
                    self?.authError = err?.localizedDescription
                }
            }
        }
    }

    func lock() {
        isUnlocked = false
    }
}
