import SwiftUI
import SwiftData

struct TransactionsView: View {
    @StateObject private var vm = TransactionsViewModel()
    @Query(sort: \STTransaction.date, order: .reverse) private var transactions: [STTransaction]
    @Query private var accounts: [STAccount]

    @State private var selectedTransaction: STTransaction?
    @State private var showCategorySheet = false
    @State private var pendingCategoryTx: STTransaction?
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                let groups = vm.grouped(transactions: transactions)

                if groups.isEmpty {
                    EmptyStateView(
                        icon: "tray",
                        title: "No Transactions",
                        message: "Transactions will appear here after you connect an account and sync."
                    )
                } else {
                    List {
                        ForEach(groups, id: \.key) { group in
                            Section(header: Text(group.key).font(.footnote).textCase(.uppercase)) {
                                ForEach(group.value, id: \.transactionId) { tx in
                                    TransactionRowView(transaction: tx)
                                        .contentShape(Rectangle())
                                        .onTapGesture { selectedTransaction = tx }
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                pendingCategoryTx = tx
                                                showCategorySheet = true
                                            } label: {
                                                Label("Category", systemImage: "tag.fill")
                                            }
                                            .tint(.blue)
                                        }
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets())
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Transactions")
            .searchable(text: $vm.searchText, prompt: "Search transactions")
            .sheet(item: $selectedTransaction, onDismiss: nil) { tx in
                TransactionDetailView(transaction: tx)
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showCategorySheet) {
                if let tx = pendingCategoryTx {
                    CategoryPickerView(selected: .constant(tx.customCategory)) { cat in
                        tx.customCategory = cat
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases) { filter in
                    filterChip(filter)
                }

                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 2)

                Menu {
                    Button("All Accounts") { vm.selectedAccountId = nil }
                    ForEach(accounts, id: \.accountId) { acct in
                        Button(acct.displayName) { vm.selectedAccountId = acct.accountId }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard")
                            .font(.caption)
                        Text(accountLabel)
                            .font(.subheadline)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(vm.selectedAccountId != nil ? Color.blue : Color(.secondarySystemBackground))
                    .foregroundStyle(vm.selectedAccountId != nil ? .white : .primary)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
    }

    private func filterChip(_ filter: TransactionFilter) -> some View {
        let selected = vm.selectedFilter == filter
        return Button {
            vm.selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundStyle(selected ? .white : .primary)
                .clipShape(Capsule())
        }
    }

    private var accountLabel: String {
        if let id = vm.selectedAccountId,
           let acct = accounts.first(where: { $0.accountId == id }) {
            return acct.name
        }
        return "Account"
    }
}

// Make STTransaction Identifiable-compatible for sheet(item:)
extension STTransaction: Identifiable {
    var id: String { transactionId }
}
