import SwiftUI
import SwiftData

struct AccountsView: View {
    @EnvironmentObject var vm: AccountsViewModel
    @Environment(\.modelContext) private var modelContext

    @Query private var plaidItems: [PlaidItem]
    @Query private var accounts: [STAccount]

    @State private var showAddAccount = false
    @State private var itemToRemove: PlaidItem?

    var body: some View {
        NavigationStack {
            Group {
                if plaidItems.isEmpty {
                    EmptyStateView(
                        icon: "creditcard",
                        title: "No Connected Accounts",
                        message: "Connect your bank accounts and credit cards to start tracking.",
                        actionLabel: "Connect Account",
                        action: { showAddAccount = true }
                    )
                } else {
                    List {
                        ForEach(plaidItems, id: \.itemId) { item in
                            institutionSection(item)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAccount) {
                AddAccountView()
                    .environmentObject(vm)
            }
            .alert("Remove Account?", isPresented: .constant(itemToRemove != nil)) {
                Button("Remove", role: .destructive) {
                    if let item = itemToRemove {
                        Task {
                            await vm.removeItem(item: item, modelContext: modelContext)
                            itemToRemove = nil
                        }
                    }
                }
                Button("Cancel", role: .cancel) { itemToRemove = nil }
            } message: {
                Text("This will disconnect \(itemToRemove?.institutionName ?? "this institution") and remove all its transactions from SpendTrack.")
            }
        }
    }

    @ViewBuilder
    private func institutionSection(_ item: PlaidItem) -> some View {
        Section {
            let itemAccounts = accounts.filter { $0.itemId == item.itemId }
            ForEach(itemAccounts, id: \.accountId) { account in
                AccountRow(account: account)
            }
        } header: {
            HStack {
                Circle()
                    .fill(Color(hex: item.institutionColor))
                    .frame(width: 10, height: 10)
                Text(item.institutionName)
                    .font(.subheadline.bold())
                    .textCase(.none)
                    .foregroundStyle(.primary)
                Spacer()
                if vm.isSyncing {
                    ProgressView().scaleEffect(0.7)
                } else {
                    Button {
                        Task { await vm.syncItem(item: item, modelContext: modelContext) }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
        } footer: {
            if let lastSynced = item.lastSynced {
                Text("Last synced \(lastSynced.shortDate)")
                    .font(.caption2)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                itemToRemove = item
            } label: {
                Label("Disconnect", systemImage: "trash")
            }
        }
    }
}

struct AccountRow: View {
    let account: STAccount

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: account.institutionColor).opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: account.subtypeIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(hex: account.institutionColor))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(account.displayName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(account.subtype.capitalized + (account.mask.map { " ••\($0)" } ?? ""))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                if let balance = account.currentBalance {
                    Text(balance.currencyString())
                        .font(.subheadline.bold())
                        .foregroundStyle(account.type == "credit" && balance > 0 ? .red : .primary)
                }
                if let available = account.availableBalance, account.type != "credit" {
                    Text("\(available.currencyString()) avail.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
