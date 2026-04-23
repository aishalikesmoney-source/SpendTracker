import SwiftUI
import SwiftData

struct BudgetsView: View {
    @StateObject private var vm = BudgetsViewModel()
    @Environment(\.modelContext) private var modelContext

    @Query private var budgets: [Budget]
    @Query private var transactions: [STTransaction]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month navigation
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
                    .foregroundStyle(vm.selectedMonth.isSameMonth(as: Date()) ? .secondary : .blue)
                    .disabled(vm.selectedMonth.isSameMonth(as: Date()))
                }
                .padding()
                .background(Color(.systemBackground))

                let progressList = vm.progress(budgets: budgets, transactions: transactions)

                if progressList.isEmpty {
                    EmptyStateView(
                        icon: "target",
                        title: "No Budgets",
                        message: "Set monthly spending limits per category to stay on track.",
                        actionLabel: "Add Budget",
                        action: { vm.showAddBudget = true }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            summaryCard(progressList)

                            ForEach(progressList) { progress in
                                BudgetCard(progress: progress) {
                                    vm.deleteBudget(progress.budget, modelContext: modelContext)
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { vm.showAddBudget = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $vm.showAddBudget) {
                AddBudgetView(selectedMonth: vm.selectedMonth) { category, limit in
                    vm.addBudget(category: category, limit: limit, modelContext: modelContext)
                }
            }
        }
    }

    private func summaryCard(_ list: [BudgetProgress]) -> some View {
        let totalBudget = list.reduce(0) { $0 + $1.budget.monthlyLimit }
        let totalSpent = list.reduce(0) { $0 + $1.spent }
        let overCount = list.filter(\.isOverBudget).count

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Budget")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(totalBudget.currencyString())
                        .font(.title2.bold())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(totalSpent.currencyString())
                        .font(.title2.bold())
                        .foregroundStyle(totalSpent > totalBudget ? .red : .primary)
                }
            }
            if overCount > 0 {
                Label("\(overCount) budget\(overCount > 1 ? "s" : "") over limit", systemImage: "exclamationmark.triangle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .cardStyle()
    }
}
