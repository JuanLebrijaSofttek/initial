import SwiftUI

/// Main ledger view showing a list of transactions with filtering.
public struct LedgerListView: View {
    @State private var searchText = ""
    @State private var isShowingAddTransaction = false
    
    // Mock data for now, or injected ViewModel
    @State private var transactions: [Transaction] = [
        Transaction(amount: 120.50, category: .groceries, type: .expense),
        Transaction(amount: 3200.00, category: .income, type: .income),
        Transaction(amount: 45.00, category: .dining, type: .expense)
    ]
    
    public init() {}
    
    var filteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return transactions
        } else {
            return transactions.filter { $0.category.displayName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List {
                    ForEach(filteredTransactions) { transaction in
                        NavigationLink(value: transaction) {
                            TransactionRow(transaction: transaction)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Ledger")
                .navigationDestination(for: Transaction.self) { transaction in
                    Text("Transaction Detail for \(transaction.formattedAmount)") // Placeholder for detail view
                }
                
                // FAB
                Button(action: {
                    isShowingAddTransaction = true
                }) {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color.blue) // Theme color
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4, x: 0, y: 4)
                }
                .padding()
                .accessibilityLabel("Add Transaction")
            }
            .sheet(isPresented: $isShowingAddTransaction) {
                AddTransactionView()
            }
        }
    }
}
