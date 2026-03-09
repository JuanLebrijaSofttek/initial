import Foundation
import SwiftUI

/// ViewModel responsible for aggregating and managing dashboard data.
/// Provides a unified view of financial health, recent transactions, and budget status.
@MainActor
public final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// All transactions for dashboard calculations
    @Published public var transactions: [Transaction] = []
    
    /// Category budgets for dashboard display
    @Published public var categoryBudgets: [CategoryBudget] = []
    
    /// Selected time period for dashboard data
    @Published public var selectedPeriod: TimePeriod = .month
    
    /// Flag indicating if data is being loaded
    @Published public var isLoading: Bool = false
    
    // MARK: - Computed Properties - Financial Summary
    
    /// Transactions for the selected period
    public var periodTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .all:
            return transactions
        }
        
        return transactions.filter { $0.timestamp >= startDate }
    }
    
    /// Total income for the selected period
    public var totalIncome: Decimal {
        periodTransactions
            .filter { $0.type == .income }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Total expenses for the selected period
    public var totalExpenses: Decimal {
        periodTransactions
            .filter { $0.type == .expense }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Net balance for the selected period
    public var netBalance: Decimal {
        totalIncome - totalExpenses
    }
    
    /// Savings rate (percentage of income saved)
    public var savingsRate: Double {
        guard totalIncome > 0 else { return 0 }
        let saved = totalIncome - totalExpenses
        return Double(truncating: (saved / totalIncome) as NSDecimalNumber)
    }
    
    /// Formatted total income
    public var formattedTotalIncome: String {
        formatCurrency(totalIncome)
    }
    
    /// Formatted total expenses
    public var formattedTotalExpenses: String {
        formatCurrency(totalExpenses)
    }
    
    /// Formatted net balance
    public var formattedNetBalance: String {
        formatCurrency(netBalance)
    }
    
    /// Formatted savings rate
    public var formattedSavingsRate: String {
        formatPercentage(savingsRate)
    }
    
    // MARK: - Computed Properties - Recent Activity
    
    /// Recent transactions (last 5)
    public var recentTransactions: [Transaction] {
        Array(transactions.sorted { $0.timestamp > $1.timestamp }.prefix(5))
    }
    
    /// Transactions grouped by category for the period
    public var categoryBreakdown: [(category: BudgetCategory, amount: Decimal, percentage: Double)] {
        let grouped = Dictionary(grouping: periodTransactions.filter { $0.type == .expense }) { $0.category }
        
        let breakdown = grouped.map { category, transactions in
            let total = transactions.reduce(Decimal.zero) { $0 + $1.amount }
            let percentage = totalExpenses > 0 ? Double(truncating: (total / totalExpenses) as NSDecimalNumber) : 0
            return (category: category, amount: total, percentage: percentage)
        }
        
        return breakdown.sorted { $0.amount > $1.amount }
    }
    
    /// Top spending categories (top 5)
    public var topSpendingCategories: [(category: BudgetCategory, amount: Decimal)] {
        Array(categoryBreakdown.prefix(5).map { (category: $0.category, amount: $0.amount) })
    }
    
    // MARK: - Computed Properties - Budget Status
    
    /// Total budget limit
    public var totalBudgetLimit: Decimal {
        categoryBudgets.reduce(Decimal.zero) { $0 + $1.limit }
    }
    
    /// Total spent against budgets
    public var totalBudgetSpent: Decimal {
        categoryBudgets.reduce(Decimal.zero) { $0 + $1.spent }
    }
    
    /// Overall budget health percentage
    public var budgetHealthPercentage: Double {
        guard totalBudgetLimit > 0 else { return 0 }
        return Double(truncating: (totalBudgetSpent / totalBudgetLimit) as NSDecimalNumber)
    }
    
    /// Categories over budget
    public var overBudgetCategories: [CategoryBudget] {
        categoryBudgets.filter { $0.isOverBudget }
    }
    
    /// Categories near limit (>80%)
    public var warningCategories: [CategoryBudget] {
        categoryBudgets.filter { $0.isNearLimit && !$0.isOverBudget }
    }
    
    /// Number of budget alerts
    public var budgetAlertCount: Int {
        overBudgetCategories.count + warningCategories.count
    }
    
    /// Formatted budget health percentage
    public var formattedBudgetHealth: String {
        formatPercentage(budgetHealthPercentage)
    }
    
    // MARK: - Computed Properties - Trends
    
    /// Daily average spending for the period
    public var dailyAverageSpending: Decimal {
        let days = daysSinceStartOfPeriod
        guard days > 0 else { return 0 }
        return totalExpenses / Decimal(days)
    }
    
    /// Formatted daily average spending
    public var formattedDailyAverage: String {
        formatCurrency(dailyAverageSpending)
    }
    
    /// Number of days in the selected period
    private var daysSinceStartOfPeriod: Int {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        case .all:
            guard let earliest = transactions.min(by: { $0.timestamp < $1.timestamp })?.timestamp else {
                return 1
            }
            return max(1, calendar.dateComponents([.day], from: earliest, to: now).day ?? 1)
        }
        
        return max(1, calendar.dateComponents([.day], from: startDate, to: now).day ?? 1)
    }
    
    /// Spending trend compared to previous period
    public var spendingTrend: TrendDirection {
        let previousPeriodExpenses = calculatePreviousPeriodExpenses()
        
        if totalExpenses > previousPeriodExpenses {
            return .up
        } else if totalExpenses < previousPeriodExpenses {
            return .down
        } else {
            return .stable
        }
    }
    
    /// Percentage change in spending compared to previous period
    public var spendingChangePercentage: Double {
        let previousPeriodExpenses = calculatePreviousPeriodExpenses()
        guard previousPeriodExpenses > 0 else { return 0 }
        
        let change = totalExpenses - previousPeriodExpenses
        return Double(truncating: (change / previousPeriodExpenses) as NSDecimalNumber)
    }
    
    /// Formatted spending change
    public var formattedSpendingChange: String {
        let percentage = abs(spendingChangePercentage)
        let sign = spendingTrend == .up ? "+" : (spendingTrend == .down ? "-" : "")
        return sign + formatPercentage(percentage)
    }
    
    // MARK: - Initialization
    
    public init(transactions: [Transaction] = [], categoryBudgets: [CategoryBudget] = []) {
        self.transactions = transactions
        self.categoryBudgets = categoryBudgets
    }
    
    // MARK: - Public Methods
    
    /// Update transactions data
    public func updateTransactions(_ transactions: [Transaction]) {
        self.transactions = transactions
    }
    
    /// Update category budgets
    public func updateCategoryBudgets(_ budgets: [CategoryBudget]) {
        self.categoryBudgets = budgets
    }
    
    /// Refresh dashboard data
    public func refresh() {
        isLoading = true
        // In a real app, this would fetch data from a repository or service
        // For now, we just toggle the loading state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
        }
    }
    
    /// Get spending for a specific category
    public func spendingForCategory(_ category: BudgetCategory) -> Decimal {
        periodTransactions
            .filter { $0.category == category && $0.type == .expense }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    /// Get transaction count for a specific category
    public func transactionCountForCategory(_ category: BudgetCategory) -> Int {
        periodTransactions.filter { $0.category == category }.count
    }
    
    // MARK: - Private Methods
    
    /// Calculate expenses for the previous period
    private func calculatePreviousPeriodExpenses() -> Decimal {
        let calendar = Calendar.current
        let now = Date()
        
        let (startDate, endDate): (Date, Date)
        switch selectedPeriod {
        case .week:
            endDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            startDate = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        case .month:
            endDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            startDate = calendar.date(byAdding: .month, value: -2, to: now) ?? now
        case .year:
            endDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            startDate = calendar.date(byAdding: .year, value: -2, to: now) ?? now
        case .all:
            return 0 // No previous period for "all time"
        }
        
        return transactions
            .filter { $0.timestamp >= startDate && $0.timestamp < endDate && $0.type == .expense }
            .reduce(Decimal.zero) { $0 + $1.amount }
    }
    
    // MARK: - Formatting Methods
    
    /// Format a decimal amount as currency
    public func formatCurrency(_ amount: Decimal) -> String {
        Self.currencyFormatter.string(from: amount as NSDecimalNumber) ?? ""
    }
    
    /// Format a percentage value
    public func formatPercentage(_ value: Double) -> String {
        Self.percentFormatter.string(from: NSNumber(value: value)) ?? ""
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
    
    private static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter
    }()
}

// MARK: - Supporting Types

/// Time period for dashboard data filtering
public enum TimePeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"
    
    public var id: String { rawValue }
}

/// Trend direction for spending analysis
public enum TrendDirection {
    case up
    case down
    case stable
    
    public var iconName: String {
        switch self {
        case .up: return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .stable: return "arrow.right"
        }
    }
    
    public var color: Color {
        switch self {
        case .up: return .red
        case .down: return .green
        case .stable: return .gray
        }
    }
}
