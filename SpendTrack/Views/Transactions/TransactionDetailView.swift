import SwiftUI

struct TransactionDetailView: View {
    @Bindable var transaction: STTransaction
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showCategoryPicker = false
    @State private var editingTag = false
    @State private var tagText = ""
    @State private var noteText = ""

    var body: some View {
        NavigationStack {
            List {
                // Amount Section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Text(
                                transaction.isExpense
                                ? "-\(transaction.amount.currencyString())"
                                : "+\(abs(transaction.amount).currencyString())"
                            )
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(transaction.isExpense ? .primary : .green)

                            if transaction.pending {
                                Label("Pending", systemImage: "clock")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }

                // Merchant Info
                Section("Transaction Details") {
                    labelRow("Merchant", value: transaction.displayName)
                    labelRow("Date", value: transaction.date.shortDate)
                    labelRow("Account", value: transaction.accountId)
                    if let note = transaction.merchantName, note != transaction.name {
                        labelRow("Reference", value: note)
                    }
                }

                // Category
                Section("Category") {
                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Text("Category")
                                .foregroundStyle(.primary)
                            Spacer()
                            CategoryBadge(category: transaction.effectiveCategory)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    if transaction.customCategory != nil {
                        Button(role: .destructive) {
                            transaction.customCategory = nil
                            try? modelContext.save()
                        } label: {
                            Label("Reset to Auto-Detected", systemImage: "arrow.counterclockwise")
                        }
                    }
                }

                // Tag
                Section("Custom Tag") {
                    if editingTag {
                        HStack {
                            TextField("e.g. vacation, work, shared", text: $tagText)
                                .textInputAutocapitalization(.never)
                            Button("Save") {
                                transaction.customTag = tagText.isEmpty ? nil : tagText
                                try? modelContext.save()
                                editingTag = false
                            }
                            .fontWeight(.semibold)
                        }
                    } else {
                        Button {
                            tagText = transaction.customTag ?? ""
                            editingTag = true
                        } label: {
                            HStack {
                                Text(transaction.customTag ?? "Add tag")
                                    .foregroundStyle(transaction.customTag == nil ? .secondary : .primary)
                                Spacer()
                                Image(systemName: transaction.customTag == nil ? "plus" : "pencil")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                // Note
                Section("Note") {
                    TextField("Add a personal note...", text: $noteText, axis: .vertical)
                        .lineLimit(3...6)
                        .onChange(of: noteText) { _, new in
                            transaction.note = new.isEmpty ? nil : new
                            try? modelContext.save()
                        }
                }
            }
            .navigationTitle("Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                noteText = transaction.note ?? ""
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selected: $transaction.customCategory) { cat in
                    transaction.customCategory = cat
                    try? modelContext.save()
                }
            }
        }
    }

    private func labelRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}
