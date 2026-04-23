import Foundation
import Combine

enum TransactionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case uncategorized = "Untagged"
    case expenses = "Expenses"
    case income = "Income"
    var id: String { rawValue }
}

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedFilter: TransactionFilter = .all
    @Published var selectedAccountId: String? = nil
    @Published var selectedCategory: String? = nil

    func filtered(transactions: [STTransaction]) -> [STTransaction] {
        transactions
            .filter { applyFilter($0) }
            .filter { applySearch($0) }
            .sorted { $0.date > $1.date }
    }

    private func applyFilter(_ tx: STTransaction) -> Bool {
        if let accountId = selectedAccountId, tx.accountId != accountId { return false }
        if let category = selectedCategory, tx.effectiveCategory != category { return false }
        switch selectedFilter {
        case .all:           return true
        case .uncategorized: return tx.isUncategorized
        case .expenses:      return tx.isExpense
        case .income:        return !tx.isExpense
        }
    }

    private func applySearch(_ tx: STTransaction) -> Bool {
        guard !searchText.isEmpty else { return true }
        let q = searchText.lowercased()
        return tx.displayName.lowercased().contains(q) ||
               (tx.note?.lowercased().contains(q) ?? false)
    }

    func grouped(transactions: [STTransaction]) -> [(key: String, value: [STTransaction])] {
        let sorted = filtered(transactions: transactions)
        var groups: [(key: String, value: [STTransaction])] = []
        var current: (key: String, value: [STTransaction])?

        for tx in sorted {
            let label = tx.date.relativeDay
            if current?.key == label {
                current?.value.append(tx)
            } else {
                if let c = current { groups.append(c) }
                current = (label, [tx])
            }
        }
        if let c = current { groups.append(c) }
        return groups
    }
}
