import Foundation
import SwiftData

struct BudgetProgress: Identifiable {
    let id: String
    let budget: Budget
    let spent: Double
    var ratio: Double { min(spent / budget.monthlyLimit, 1.0) }
    var isOverBudget: Bool { spent > budget.monthlyLimit }
    var remaining: Double { max(budget.monthlyLimit - spent, 0) }
}

@MainActor
final class BudgetsViewModel: ObservableObject {
    @Published var selectedMonth = Date()
    @Published var showAddBudget = false

    func progress(budgets: [Budget], transactions: [STTransaction]) -> [BudgetProgress] {
        let monthBudgets = budgets.filter {
            $0.month == selectedMonth.month && $0.year == selectedMonth.year
        }
        return monthBudgets.map { budget in
            let spent = transactions
                .filter {
                    $0.effectiveCategory == budget.category &&
                    $0.date.month == budget.month &&
                    $0.date.year == budget.year &&
                    $0.isExpense
                }
                .reduce(0) { $0 + $1.amount }
            return BudgetProgress(id: budget.id, budget: budget, spent: spent)
        }
        .sorted { $0.ratio > $1.ratio }
    }

    func addBudget(
        category: String,
        limit: Double,
        modelContext: ModelContext
    ) {
        let budget = Budget(
            category: category,
            monthlyLimit: limit,
            month: selectedMonth.month,
            year: selectedMonth.year
        )
        modelContext.insert(budget)
        try? modelContext.save()
    }

    func deleteBudget(_ budget: Budget, modelContext: ModelContext) {
        modelContext.delete(budget)
        try? modelContext.save()
    }

    func advance(by months: Int) {
        selectedMonth = Calendar.current.date(
            byAdding: .month, value: months, to: selectedMonth
        ) ?? selectedMonth
    }
}
