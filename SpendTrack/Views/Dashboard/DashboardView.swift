import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    @EnvironmentObject var accountsVM: AccountsViewModel
    @Environment(\.modelContext) private var modelContext

    @Query private var transactions: [STTransaction]
    @Query private var accounts: [STAccount]
    @Query private var budgets: [Budget]
    @Query private var plaidItems: [PlaidItem]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthSelector

                    overviewCard

                    if !accounts.isEmpty {
                        accountBalancesSection
                    }

                    let catSpends = vm.spendingByCategory(transactions: transactions)
                    if !catSpends.isEmpty {
                        categoryChartSection(catSpends)
                    }

                    let recent = vm.recentTransactions(transactions: transactions)
                    if !recent.isEmpty {
                        recentSection(recent)
                    }

                    if accounts.isEmpty {
                        noAccountsBanner
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            for item in plaidItems {
                                await accountsVM.syncItem(item: item, modelContext: modelContext)
                            }
                        }
                    } label: {
                        if accountsVM.isSyncing {
                            ProgressView().tint(.blue)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(accountsVM.isSyncing || plaidItems.isEmpty)
                }
            }
            .alert("Sync Error", isPresented: .constant(accountsVM.errorMessage != nil)) {
                Button("OK") { accountsVM.errorMessage = nil }
            } message: {
                Text(accountsVM.errorMessage ?? "")
            }
        }
    }

    // MARK: - Month Selector

    private var monthSelector: some View {
        HStack {
            Button { vm.advance(by: -1) } label: {
                Image(systemName: "chevron.left").fontWeight(.semibold)
            }
            .foregroundStyle(.blue)

            Spacer()

            Text(vm.selectedMonth.monthYear)
                .font(.headline)

            Spacer()

            Button { vm.advance(by: 1) } label: {
                Image(systemName: "chevron.right").fontWeight(.semibold)
            }
            .foregroundColor(vm.isCurrentMonth ? .secondary : .blue)
            .disabled(vm.isCurrentMonth)
        }
        .padding(.top, 8)
    }

    // MARK: - Overview Card

    private var overviewCard: some View {
        let spent = vm.totalSpent(transactions: transactions)
        let budget = vm.totalBudget(budgets: budgets)
        let ratio = budget > 0 ? min(spent / budget, 1.0) : 0.0

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(spent.currencyString())
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Income")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(vm.totalIncome(transactions: transactions).currencyString())
                        .font(.title3.bold())
                        .foregroundStyle(.green)
                }
            }

            if budget > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Budget")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(ratio.percentString()) of \(budget.currencyString())")
                            .font(.caption)
                            .foregroundColor(ratio > 0.9 ? .red : .secondary)
                    }
                    ProgressView(value: ratio)
                        .tint(ratio > 0.9 ? .red : ratio > 0.7 ? .orange : .blue)
                }
            }
        }
        .padding()
        .cardStyle()
    }

    // MARK: - Account Balances

    private var accountBalancesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accounts")
                .font(.headline)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(accounts, id: \.accountId) { account in
                        AccountChip(account: account)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Category Chart

    private func categoryChartSection(_ data: [CategorySpend]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.headline)
                .padding(.horizontal, 4)

            Chart(data) { item in
                BarMark(
                    x: .value("Amount", item.amount),
                    y: .value("Category", item.displayName)
                )
                .foregroundStyle(item.color)
                .cornerRadius(6)
            }
            .frame(height: CGFloat(min(data.count, 7)) * 44)
            .padding()
            .cardStyle()
        }
    }

    // MARK: - Recent Transactions

    private func recentSection(_ txs: [STTransaction]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent")
                    .font(.headline)
                Spacer()
                NavigationLink("See all") {
                    TransactionsView()
                }
                .font(.subheadline)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(txs, id: \.transactionId) { tx in
                    TransactionRowView(transaction: tx, showAccount: false)
                    if tx.transactionId != txs.last?.transactionId {
                        Divider().padding(.leading, 56)
                    }
                }
            }
            .cardStyle()
        }
    }

    // MARK: - No Accounts

    private var noAccountsBanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.and.123")
                .font(.system(size: 44))
                .foregroundStyle(.blue.opacity(0.7))

            VStack(spacing: 6) {
                Text("Connect Your Accounts")
                    .font(.title3.bold())
                Text("Link your bank accounts and credit cards to start tracking expenses.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

// MARK: - Account Chip

struct AccountChip: View {
    let account: STAccount

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: account.subtypeIcon)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(Color(hex: account.institutionColor))
                    .clipShape(Circle())
                Text(account.institutionName)
                    .font(.caption.bold())
                    .lineLimit(1)
            }
            Text(account.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            if let balance = account.currentBalance {
                Text(balance.currencyString())
                    .font(.subheadline.bold())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
