import SwiftUI
import SwiftData

@main
struct SpendTrackApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var accountsVM = AccountsViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authService)
                .environmentObject(accountsVM)
                .onOpenURL { url in
                    // Handle Plaid OAuth redirect: spendtrack://oauth-redirect
                    _ = url
                }
        }
        .modelContainer(for: [
            PlaidItem.self,
            STAccount.self,
            STTransaction.self,
            Budget.self,
            CustomCategory.self
        ])
    }
}

struct RootView: View {
    @EnvironmentObject var authService: AuthenticationService

    var body: some View {
        Group {
            if authService.isUnlocked {
                ContentView()
            } else {
                LockView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: authService.isUnlocked)
        .onAppear {
            // Seed Face ID setting on first launch
            if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isBiometricEnabled)
            }
            authService.isBiometricEnabled = UserDefaults.standard.bool(
                forKey: Constants.UserDefaultsKeys.isBiometricEnabled
            )
        }
    }
}
