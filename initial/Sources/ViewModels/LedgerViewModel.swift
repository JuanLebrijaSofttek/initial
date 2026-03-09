import Foundation
import SwiftUI

/// ViewModel responsible for managing ledger transactions, filtering, and aggregation.
/// Handles all business logic related to transaction display and manipulation.
@MainActor
public final class LedgerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// All transactions in the ledger
    @Published public var transactions: [Transaction] = []
    
    /// Currently selected filter for transaction type
    @Published public var selectedFilter: TransactionFilter = .all
    
    /// Search text for filtering transactions
    @Published public var searchText: String = ""
    
    /// Selected category filter
    @Published public var selectedCategory: BudgetCategory?
    
    /// Date range filter
    @Published public var startDate: Date?
    @Published public var endDate: Date?
    
    // MARK: - Computed Properties
    
    /// Filtered transactions based on current filters
    public var filteredTransactions: [Transaction] {
        var result = transactions
        
        // Filter by transaction type
        switch selectedFilter {
        case .all:
            break
        case .income:
            result = result.filter { $0.type == .income }
        case .expense:
            result = result.filter { $0.type == .expense }
        }
        
        // Filter by category
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { transaction in
                transaction.categoryName.localizedCaseInsensitiveContains(searchText) ||
                (transaction.note?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by date range
        if let start = startDate {
            result = result.filter { $0.timestamp >= start }
        }
        if let end = endDate {
            result = result.filter { $0.timestamp <= end }
        }
        
        return result.sorted { $0.timestamp > $1.timestamp }
    }
    
    /// Total income from filtered transactions
    public var totalIncome: Decimal {
        filteredTransactions
            .filter { $0.type == .income }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Total expenses from filtered transactions
    public var totalExpenses: Decimal {
        filteredTransactions
            .filter { $0.type == .expense }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Net balance (income - expenses)
    public var netBalance: Decimal {
        totalIncome - totalExpenses
    }
    
    /// Formatted total income string
    public var formattedTotalIncome: String {
        formatCurrency(totalIncome)
    }
    
    /// Formatted total expenses string
    public var formattedTotalExpenses: String {
        formatCurrency(totalExpenses)
    }
    
    /// Formatted net balance string
    public var formattedNetBalance: String {
        formatCurrency(netBalance)
    }
    
    /// Transactions grouped by date
    public var transactionsByDate: [(date: Date, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.timestamp)
        }
        
        return grouped
            .sorted { $0.key > $1.key }
            .map { (date: $0.key, transactions: $0.value.sorted { $0.timestamp > $1.timestamp }) }
    }
    
    /// Transactions grouped by category with totals
    public var transactionsByCategory: [(category: BudgetCategory, total: Decimal, count: Int)] {
        let grouped = Dictionary(grouping: filteredTransactions) { $0.category }
        
        return grouped.map { category, transactions in
            let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
            return (category: category, total: total, count: transactions.count)
        }
        .sorted { $0.total > $1.total }
    }
    
    // MARK: - Initialization
    
    public init(transactions: [Transaction] = []) {
        self.transactions = transactions
    }
    
    // MARK: - Public Methods
    
    /// Add a new transaction to the ledger
    public func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    /// Remove a transaction from the ledger
    public func removeTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
    }
    
    /// Update an existing transaction
    public func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
    }
    
    /// Clear all filters
    public func clearFilters() {
        selectedFilter = .all
        searchText = ""
        selectedCategory = nil
        startDate = nil
        endDate = nil
    }
    
    /// Get transactions for a specific month
    public func transactionsForMonth(_ date: Date) -> [Transaction] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }
        
        return transactions.filter { transaction in
            transaction.timestamp >= startOfMonth && transaction.timestamp <= endOfMonth
        }
    }
    
    /// Get total for a specific category
    public func totalForCategory(_ category: BudgetCategory) -> Decimal {
        filteredTransactions
            .filter { $0.category == category }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Format a decimal amount as currency
    public func formatCurrency(_ amount: Decimal) -> String {
        Self.currencyFormatter.string(from: amount as NSDecimalNumber) ?? ""
    }
    
    // MARK: - Private Properties
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.generatesDecimalNumbers = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
}

// MARK: - Supporting Types

public enum TransactionFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case income = "Income"
    case expense = "Expenses"
    
    public var id: String { rawValue }
}
