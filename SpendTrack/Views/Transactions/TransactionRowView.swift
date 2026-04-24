import SwiftUI

struct TransactionRowView: View {
    let transaction: STTransaction
    var showAccount: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            categoryIcon

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.displayName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    CategoryBadge(category: transaction.effectiveCategory, small: true)
                    if transaction.pending {
                        Text("Pending")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(.orange.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    if let tag = transaction.customTag {
                        Text("# \(tag)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(transaction.isExpense ? "-\(transaction.amount.currencyString())" : "+\(abs(transaction.amount).currencyString())")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(transaction.isExpense ? .primary : .green)

                Text(transaction.date.shortDate)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }

    private var categoryIcon: some View {
        let category = transaction.effectiveCategory
        return ZStack {
            Circle()
                .fill(CategoryHelper.color(for: category).opacity(0.12))
                .frame(width: 40, height: 40)
            Image(systemName: CategoryHelper.sfSymbol(for: category))
                .font(.system(size: 16))
                .foregroundStyle(CategoryHelper.color(for: category))
        }
    }
}
