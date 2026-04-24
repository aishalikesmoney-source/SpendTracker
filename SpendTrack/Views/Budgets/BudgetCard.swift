import SwiftUI

struct BudgetCard: View {
    let progress: BudgetProgress
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(CategoryHelper.color(for: progress.budget.category).opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: CategoryHelper.sfSymbol(for: progress.budget.category))
                        .font(.system(size: 15))
                        .foregroundStyle(CategoryHelper.color(for: progress.budget.category))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(CategoryHelper.displayName(for: progress.budget.category))
                        .font(.subheadline.bold())
                    Text(progress.budget.monthlyLimit.currencyString() + " / month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(progress.spent.currencyString())
                        .font(.subheadline.bold())
                        .foregroundColor(progress.isOverBudget ? .red : .primary)
                    if progress.isOverBudget {
                        Text("\((progress.spent - progress.budget.monthlyLimit).currencyString()) over")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    } else {
                        Text("\(progress.remaining.currencyString()) left")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            ProgressView(value: progress.ratio)
                .tint(progressColor)
                .animation(.spring, value: progress.ratio)

            HStack {
                Text(progress.ratio.percentString() + " used")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                if progress.isOverBudget {
                    Label("Over budget", systemImage: "exclamationmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .cardStyle()
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Budget", systemImage: "trash")
            }
        }
    }

    private var progressColor: Color {
        if progress.isOverBudget { return .red }
        if progress.ratio > 0.8 { return .orange }
        return CategoryHelper.color(for: progress.budget.category)
    }
}
