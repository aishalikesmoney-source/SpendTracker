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

            BudgetProgressBar(progress: progress)
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

struct BudgetProgressBar: View {
    let progress: BudgetProgress

    private var baseColor: Color { CategoryHelper.color(for: progress.budget.category) }
    private var overColor: Color { baseColor.darker(by: 0.35) }
    private var budgetRatio: Double { min(progress.ratio, 1.0) }
    private var overRatio: Double {
        guard progress.isOverBudget else { return 0 }
        return (progress.spent - progress.budget.monthlyLimit) / progress.spent
    }

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let normalWidth = progress.isOverBudget
                ? totalWidth * (1 - overRatio)
                : totalWidth * budgetRatio

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemFill))
                    .frame(height: 8)

                if progress.isOverBudget {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(baseColor)
                            .frame(width: normalWidth, height: 8)
                        Rectangle()
                            .fill(overColor)
                            .frame(width: totalWidth * overRatio, height: 8)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(budgetRatio > 0.8 ? Color.orange : baseColor)
                        .frame(width: normalWidth, height: 8)
                }

                if progress.isOverBudget {
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .frame(width: 2, height: 12)
                        .offset(x: normalWidth - 1)
                }
            }
        }
        .frame(height: 8)
    }
}
