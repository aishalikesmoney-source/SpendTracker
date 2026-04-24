import Foundation

enum Constants {
    static var serverBaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "ServerBaseURL") as? String ?? "http://localhost:3000"
    }

    static var plaidEnvironment: String {
        Bundle.main.object(forInfoDictionaryKey: "PlaidEnvironment") as? String ?? "sandbox"
    }

    static let plaidRedirectURI = "spendtrack://oauth-redirect"

    enum UserDefaultsKeys {
        static let isBiometricEnabled = "isBiometricEnabled"
        static let customServerURL = "customServerURL"
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let lastSyncDate = "lastSyncDate"
    }

    enum NotificationIdentifiers {
        static let budgetAt80 = "budget_80_"
        static let budgetAt100 = "budget_100_"
    }

    static let defaultCategories = [
        "FOOD_AND_DRINK", "SHOPPING", "TRANSPORTATION", "TRAVEL",
        "ENTERTAINMENT", "MEDICAL", "BILLS", "PERSONAL_CARE",
        "HOME", "INCOME", "TRANSFER", "OTHER"
    ]
}
