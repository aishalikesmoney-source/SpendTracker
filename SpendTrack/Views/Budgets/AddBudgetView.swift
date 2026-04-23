import SwiftUI

struct AddBudgetView: View {
    let selectedMonth: Date
    let onAdd: (String, Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = Constants.defaultCategories[0]
    @State private var limitText = ""
    @State private var showCategoryPicker = false

    private var isValid: Bool {
        Double(limitText) != nil && (Double(limitText) ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Month") {
                    Text(selectedMonth.monthYear)
                        .foregroundStyle(.secondary)
                }

                Section("Category") {
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Text("Category")
                                .foregroundStyle(.primary)
                            Spacer()
                            CategoryBadge(category: selectedCategory)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Section("Monthly Limit") {
                    HStack {
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $limitText)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let limit = Double(limitText) {
                            onAdd(selectedCategory, limit)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selected: Binding(
                    get: { selectedCategory },
                    set: { if let v = $0 { selectedCategory = v } }
                ))
            }
        }
    }
}
