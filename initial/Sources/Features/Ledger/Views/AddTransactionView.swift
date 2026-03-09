import SwiftUI

/// Modal form for adding a new transaction with focused amount field and category grid.
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isAmountFocused: Bool
    
    @State private var amountText: String = ""
    @State private var selectedCategory: BudgetCategory = .miscellaneous
    @State private var selectedKind: Transaction.Kind = .expense
    @State private var note: String = ""
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?
    
    private let columns = [
        GridItem(.adaptive(minimum: 80), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $selectedKind) {
                        Text("Expense").tag(Transaction.Kind.expense)
                        Text("Income").tag(Transaction.Kind.income)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Transaction Type")
                }
                
                Section {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .font(.title2)
                        .multilineTextAlignment(.trailing)
                        .focused($isAmountFocused)
                        .onChange(of: amountText) { _, newValue in
                            amountText = formatAmountInput(newValue)
                        }
                } header: {
                    Text("Amount")
                } footer: {
                    Text("Enter amount. Use underscore (_) for thousands separator.")
                        .font(.caption)
                }
                
                Section {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(BudgetCategory.allCases) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Category")
                }
                
                Section {
                    TextField("Add a note (optional)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Notes")
                }
                
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveTransaction()
                        }
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .disabled(isSaving)
            .onAppear {
                isAmountFocused = true
            }
        }
    }
    
    private var isValid: Bool {
        guard let amount = parseAmount(from: amountText) else {
            return false
        }
        return amount > 0
    }
    
    /// Formats the amount input to support underscore as thousands separator
    private func formatAmountInput(_ input: String) -> String {
        // Allow digits, decimal point, and underscore
        let filtered = input.filter { $0.isNumber || $0 == "." || $0 == "_" }
        
        // Ensure only one decimal point
        let components = filtered.components(separatedBy: ".")
        if components.count > 2 {
            return String(filtered.dropLast())
        }
        
        // Limit decimal places to 2
        if components.count == 2, components[1].count > 2 {
            return String(filtered.dropLast())
        }
        
        return filtered
    }
    
    /// Parses the amount from text, treating underscore as thousands separator
    private func parseAmount(from text: String) -> Decimal? {
        let cleaned = text.replacingOccurrences(of: "_", with: "")
        return Decimal(string: cleaned)
    }
    
    private func saveTransaction() async {
        guard let amount = parseAmount(from: amountText), amount > 0 else {
            errorMessage = "Please enter a valid amount"
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        do {
            // Simulate async save operation
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // TODO: Integrate with actual Transaction storage/service
            // let transaction = Transaction(
            //     amount: amount,
            //     category: selectedCategory,
            //     note: note.isEmpty ? nil : note,
            //     kind: selectedKind
            // )
            
            dismiss()
        } catch {
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
            isSaving = false
        }
    }
}

/// Button for selecting a budget category in the grid
private struct CategoryButton: View {
    let category: BudgetCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: category.symbolName)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(category.displayName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.accentColor : Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddTransactionView()
}
