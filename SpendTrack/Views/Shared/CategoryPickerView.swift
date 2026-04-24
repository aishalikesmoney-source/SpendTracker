import SwiftUI

struct CategoryPickerView: View {
    @Binding var selected: String?
    @Environment(\.dismiss) private var dismiss
    var onSelect: ((String) -> Void)?

    private let allCategories = Constants.defaultCategories

    var body: some View {
        NavigationStack {
            List(allCategories, id: \.self) { category in
                Button {
                    selected = category
                    onSelect?(category)
                    dismiss()
                } label: {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(CategoryHelper.color(for: category).opacity(0.15))
                                .frame(width: 36, height: 36)
                            Image(systemName: CategoryHelper.sfSymbol(for: category))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(CategoryHelper.color(for: category))
                        }
                        Text(CategoryHelper.displayName(for: category))
                            .foregroundStyle(.primary)
                        Spacer()
                        if selected == category {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct CategoryBadge: View {
    let category: String
    var small = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: CategoryHelper.sfSymbol(for: category))
                .font(.system(size: small ? 9 : 11))
            Text(CategoryHelper.displayName(for: category))
                .font(small ? .caption2 : .caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(CategoryHelper.color(for: category))
        .padding(.horizontal, small ? 6 : 8)
        .padding(.vertical, small ? 3 : 4)
        .background(CategoryHelper.color(for: category).opacity(0.12))
        .clipShape(Capsule())
    }
}
