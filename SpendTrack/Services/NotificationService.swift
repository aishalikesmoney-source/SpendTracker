import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleBudgetAlert(
        category: String,
        limit: Double,
        spent: Double,
        month: String,
        threshold: Double
    ) {
        let pct = Int(threshold * 100)
        let identifier = "\(threshold == 0.8 ? Constants.NotificationIdentifiers.budgetAt80 : Constants.NotificationIdentifiers.budgetAt100)\(category)"

        let content = UNMutableNotificationContent()
        content.title = threshold < 1.0 ? "Budget Alert: \(pct)% Used" : "Budget Limit Reached"
        content.body = "You've used \(pct)% of your \(CategoryHelper.displayName(for: category)) budget for \(month). Spent \(spent.currencyString()) of \(limit.currencyString())."
        content.sound = .default
        content.categoryIdentifier = "BUDGET_ALERT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func checkBudgets(budgets: [Budget], transactions: [STTransaction]) {
        let now = Date()
        for budget in budgets {
            guard budget.month == now.month, budget.year == now.year else { continue }

            let monthTransactions = transactions.filter { tx in
                tx.effectiveCategory == budget.category &&
                tx.date.month == budget.month &&
                tx.date.year == budget.year &&
                tx.isExpense
            }
            let spent = monthTransactions.reduce(0) { $0 + $1.amount }
            let ratio = spent / budget.monthlyLimit
            let monthLabel = DateFormatter().string(from: now)

            if ratio >= 0.8 && !budget.notifiedAt80 {
                scheduleBudgetAlert(
                    category: budget.category,
                    limit: budget.monthlyLimit,
                    spent: spent,
                    month: now.monthYear,
                    threshold: 0.8
                )
                budget.notifiedAt80 = true
            }
            if ratio >= 1.0 && !budget.notifiedAt100 {
                scheduleBudgetAlert(
                    category: budget.category,
                    limit: budget.monthlyLimit,
                    spent: spent,
                    month: now.monthYear,
                    threshold: 1.0
                )
                budget.notifiedAt100 = true
            }
            _ = monthLabel
        }
    }
}
