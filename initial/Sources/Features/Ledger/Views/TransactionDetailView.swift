import SwiftUI

/// Displays full metadata for a single transaction.
/// This is a leaf screen with no forward navigation.
struct TransactionDetailView: View {
    let transaction: Transaction
    
    var body: some View {
        List {
            Section {
                HStack {
                    Label {
                        Text(transaction.category.displayName)
                    } icon: {
                        Image(systemName: transaction.category.symbolName)
                            .foregroundStyle(transaction.kind == .income ? .green : .red)
                    }
                    Spacer()
                    Text(transaction.formattedAmount)
                        .font(.headline)
                        .foregroundStyle(transaction.kind == .income ? .green : .red)
                }
            } header: {
                Text("Transaction Details")
            }
            
            Section {
                LabeledContent("Type") {
                    Text(transaction.kind == .income ? "Income" : "Expense")
                        .foregroundStyle(transaction.kind == .income ? .green : .red)
                }
                
                LabeledContent("Date") {
                    Text(transaction.timestamp, style: .date)
                }
                
                LabeledContent("Time") {
                    Text(transaction.timestamp, style: .time)
                }
                
                LabeledContent("ID") {
                    Text(transaction.id.uuidString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Metadata")
            }
            
            if let note = transaction.note, !note.isEmpty {
                Section {
                    Text(note)
                } header: {
                    Text("Notes")
                }
            }
        }
        .navigationTitle("Transaction")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(
            transaction: Transaction(
                amount: 42.50,
                category: .groceries,
                timestamp: Date(),
                note: "Weekly shopping at the local market",
                kind: .expense
            )
        )
    }
}
