import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountsVM: AccountsViewModel

    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(accountsVM)
                .tabItem {
                    Label("Overview", systemImage: "chart.pie.fill")
                }

            TransactionsView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet.rectangle.fill")
                }

            BudgetsView()
                .tabItem {
                    Label("Budgets", systemImage: "target")
                }

            AccountsView()
                .environmentObject(accountsVM)
                .tabItem {
                    Label("Accounts", systemImage: "creditcard.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(Color(hex: "#007AFF"))
    }
}
