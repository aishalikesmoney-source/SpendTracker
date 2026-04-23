import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var authService: AuthenticationService
    @Environment(\.modelContext) private var modelContext

    @Query private var plaidItems: [PlaidItem]
    @Query private var transactions: [STTransaction]
    @Query private var accounts: [STAccount]

    @AppStorage(Constants.UserDefaultsKeys.isBiometricEnabled) private var biometricEnabled = true
    @AppStorage(Constants.UserDefaultsKeys.customServerURL) private var serverURL = ""

    @State private var showServerURLAlert = false
    @State private var draftServerURL = ""
    @State private var showClearDataConfirm = false
    @State private var showAbout = false

    private var effectiveServerURL: String {
        serverURL.isEmpty ? Constants.serverBaseURL : serverURL
    }

    var body: some View {
        NavigationStack {
            List {
                // Security
                Section("Security") {
                    Toggle(
                        "Require \(authService.biometryLabel)",
                        isOn: $biometricEnabled
                    )
                    .onChange(of: biometricEnabled) { _, new in
                        authService.isBiometricEnabled = new
                    }
                }

                // Server
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Server URL")
                            Text(effectiveServerURL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button("Edit") {
                            draftServerURL = effectiveServerURL
                            showServerURLAlert = true
                        }
                        .foregroundStyle(.blue)
                    }
                } header: {
                    Text("Backend Server")
                } footer: {
                    Text("The local Node.js server that handles Plaid API calls. Default: http://localhost:3000")
                }

                // Stats
                Section("Data") {
                    labelRow("Connected Banks", value: "\(plaidItems.count)")
                    labelRow("Accounts", value: "\(accounts.count)")
                    labelRow("Transactions", value: "\(transactions.count)")

                    if let lastSync = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.lastSyncDate) as? Date {
                        labelRow("Last Sync", value: lastSync.shortDate)
                    }
                }

                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showClearDataConfirm = true
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("This deletes all local transactions, accounts, and budgets. Plaid connections will also be removed.")
                }

                // About
                Section("About") {
                    labelRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                    labelRow("Environment", value: Constants.plaidEnvironment.capitalized)
                    Button {
                        showAbout = true
                    } label: {
                        Text("SpendTrack — Personal Expense Tracker")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Server URL", isPresented: $showServerURLAlert) {
                TextField("http://localhost:3000", text: $draftServerURL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button("Save") {
                    serverURL = draftServerURL.trimmingCharacters(in: .whitespaces)
                }
                Button("Reset to Default") { serverURL = "" }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter the URL where the SpendTrack Node.js server is running.")
            }
            .alert("Clear All Data?", isPresented: $showClearDataConfirm) {
                Button("Delete Everything", role: .destructive) {
                    clearAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone. All transactions, budgets, and account connections will be permanently deleted.")
            }
        }
    }

    private func labelRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func clearAllData() {
        try? modelContext.delete(model: STTransaction.self)
        try? modelContext.delete(model: STAccount.self)
        try? modelContext.delete(model: Budget.self)
        try? modelContext.delete(model: PlaidItem.self)
        try? modelContext.save()
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.lastSyncDate)
    }
}
