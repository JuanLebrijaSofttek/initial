import SwiftUI
// import Models (Implicit in same target)

/// A reusable row component for displaying transaction details in a list.
/// Follows View Composition principle with atomic design.
public struct TransactionRow: View {
    public let transaction: Transaction
    
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    public var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            // Category Icon
            CategoryIconView(symbolName: transaction.category.symbolName)
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.displayName)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(transaction.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount with Monospaced Digit font
            Text(transaction.formattedSignedAmount)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(amountColor)
        }
        .padding(.vertical, Constants.Spacing.small)
        .contentShape(Rectangle()) // Improves tap area
        .frame(maxWidth: .infinity)
    }
    
    private var amountColor: Color {
        switch transaction.type {
        case .income:
            return Constants.Colors.successGreen
        case .expense:
            return Constants.Colors.dangerRed
        }
    }
}

#if DEBUG
#Preview {
    List {
        TransactionRow(transaction: Transaction(
            amount: 1250.00,
            category: .housing,
            type: .expense
        ))
        TransactionRow(transaction: Transaction(
            amount: 5000.00,
            category: .income,
            type: .income
        ))
    }
}
#endif
