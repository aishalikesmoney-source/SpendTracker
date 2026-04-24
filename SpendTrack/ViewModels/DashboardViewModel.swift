import Foundation
import SwiftUI

struct CategorySpend: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    var displayName: String { CategoryHelper.displayName(for: category) }
    var color: Color { CategoryHelper.color(for: category) }
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var selectedMonth = Date()

    func totalSpent(transactions: [STTransaction]) -> Double {
        transactions
            .filter { $0.date.isSameMonth(as: selectedMonth) && $0.isExpense }
            .reduce(0) { $0 + $1.amount }
    }

    func totalIncome(transactions: [STTransaction]) -> Double {
        transactions
            .filter { $0.date.isSameMonth(as: selectedMonth) && !$0.isExpense }
            .reduce(0) { $0 + abs($1.amount) }
    }

    func totalBudget(budgets: [Budget]) -> Double {
        budgets
            .filter { $0.month == selectedMonth.month && $0.year == selectedMonth.year }
            .reduce(0) { $0 + $1.monthlyLimit }
    }

    func spendingByCategory(transactions: [STTransaction]) -> [CategorySpend] {
        let expenses = transactions.filter { $0.date.isSameMonth(as: selectedMonth) && $0.isExpense }
        var grouped: [String: Double] = [:]
        for tx in expenses {
            grouped[tx.effectiveCategory, default: 0] += tx.amount
        }
        return grouped
            .map { CategorySpend(category: $0.key, amount: $0.value) }
            .filter { $0.amount > 0 }
            .sorted { $0.amount > $1.amount }
    }

    func recentTransactions(transactions: [STTransaction], limit: Int = 10) -> [STTransaction] {
        transactions
            .filter { $0.date.isSameMonth(as: selectedMonth) }
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { $0 }
    }

    func netWorth(accounts: [STAccount]) -> Double {
        accounts.reduce(0) { total, acct in
            if acct.type == "credit" {
                return total - (acct.currentBalance ?? 0)
            }
            return total + (acct.currentBalance ?? acct.availableBalance ?? 0)
        }
    }

    func advance(by months: Int) {
        selectedMonth = Calendar.current.date(byAdding: .month, value: months, to: selectedMonth) ?? selectedMonth
    }

    var isCurrentMonth: Bool {
        selectedMonth.isSameMonth(as: Date())
    }
}
