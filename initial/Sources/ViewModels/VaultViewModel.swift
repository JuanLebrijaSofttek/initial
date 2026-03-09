import Foundation
import SwiftUI

/// ViewModel responsible for managing budget categories, limits, and vault entries.
/// Handles all business logic related to budget management and secure storage.
@MainActor
public final class VaultViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// All budget categories with their current spending and limits
    @Published public var categoryBudgets: [CategoryBudget] = []
    
    /// All vault entries (encrypted data)
    @Published public var vaultEntries: [VaultEntry] = []
    
    /// Currently selected category for detailed view
    @Published public var selectedCategory: BudgetCategory?
    
    /// Flag indicating if vault is locked
    @Published public var isVaultLocked: Bool = true
    
    /// Search text for filtering categories
    @Published public var searchText: String = ""
    
    // MARK: - Computed Properties
    
    /// Filtered category budgets based on search text
    public var filteredCategoryBudgets: [CategoryBudget] {
        guard !searchText.isEmpty else {
            return categoryBudgets.sorted { $0.category.displayName < $1.category.displayName }
        }
        
        return categoryBudgets
            .filter { $0.category.displayName.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.category.displayName < $1.category.displayName }
    }
    
    /// Total budget limit across all categories
    public var totalBudgetLimit: Decimal {
        categoryBudgets.reduce(Decimal.zero) { $0 + $1.limit }
    }
    
    /// Total spent across all categories
    public var totalSpent: Decimal {
        categoryBudgets.reduce(Decimal.zero) { $0 + $1.spent }
    }
    
    /// Total remaining budget
    public var totalRemaining: Decimal {
        totalBudgetLimit - totalSpent
    }
    
    /// Percentage of total budget spent
    public var totalSpentPercentage: Double {
        guard totalBudgetLimit > 0 else { return 0 }
        return Double(truncating: (totalSpent / totalBudgetLimit) as NSDecimalNumber)
    }
    
    /// Categories that are over budget
    public var overBudgetCategories: [CategoryBudget] {
        categoryBudgets.filter { $0.isOverBudget }
    }
    
    /// Categories approaching their limit (>80%)
    public var warningCategories: [CategoryBudget] {
        categoryBudgets.filter { $0.isNearLimit && !$0.isOverBudget }
    }
    
    /// Formatted total budget limit
    public var formattedTotalLimit: String {
        formatCurrency(totalBudgetLimit)
    }
    
    /// Formatted total spent
    public var formattedTotalSpent: String {
        formatCurrency(totalSpent)
    }
    
    /// Formatted total remaining
    public var formattedTotalRemaining: String {
        formatCurrency(totalRemaining)
    }
    
    // MARK: - Initialization
    
    public init() {
        // Initialize with default categories and suggested limits
        self.categoryBudgets = BudgetCategory.allCases
            .filter { $0 != .income } // Exclude income from budget tracking
            .map { category in
                CategoryBudget(
                    category: category,
                    limit: category.suggestedLimit,
                    spent: 0
                )
            }
    }
    
    // MARK: - Public Methods - Budget Management
    
    /// Update the spending for a specific category
    public func updateSpending(for category: BudgetCategory, amount: Decimal) {
        if let index = categoryBudgets.firstIndex(where: { $0.category == category }) {
            categoryBudgets[index].spent = amount
        }
    }
    
    /// Add spending to a specific category
    public func addSpending(for category: BudgetCategory, amount: Decimal) {
        if let index = categoryBudgets.firstIndex(where: { $0.category == category }) {
            categoryBudgets[index].spent += amount
        }
    }
    
    /// Update the limit for a specific category
    public func updateLimit(for category: BudgetCategory, limit: Decimal) {
        if let index = categoryBudgets.firstIndex(where: { $0.category == category }) {
            categoryBudgets[index].limit = limit
        }
    }
    
    /// Reset all spending to zero
    public func resetAllSpending() {
        for index in categoryBudgets.indices {
            categoryBudgets[index].spent = 0
        }
    }
    
    /// Reset spending for a specific category
    public func resetSpending(for category: BudgetCategory) {
        if let index = categoryBudgets.firstIndex(where: { $0.category == category }) {
            categoryBudgets[index].spent = 0
        }
    }
    
    /// Get budget for a specific category
    public func budget(for category: BudgetCategory) -> CategoryBudget? {
        categoryBudgets.first { $0.category == category }
    }
    
    /// Calculate remaining budget for a category
    public func remainingBudget(for category: BudgetCategory) -> Decimal {
        guard let budget = budget(for: category) else { return 0 }
        return budget.remaining
    }
    
    /// Check if a category is over budget
    public func isOverBudget(_ category: BudgetCategory) -> Bool {
        budget(for: category)?.isOverBudget ?? false
    }
    
    // MARK: - Public Methods - Vault Management
    
    /// Add a new vault entry
    public func addVaultEntry(_ entry: VaultEntry) {
        vaultEntries.append(entry)
    }
    
    /// Remove a vault entry
    public func removeVaultEntry(_ entry: VaultEntry) {
        vaultEntries.removeAll { $0.id == entry.id }
    }
    
    /// Lock the vault
    public func lockVault() {
        isVaultLocked = true
    }
    
    /// Unlock the vault
    public func unlockVault() {
        isVaultLocked = false
    }
    
    /// Get vault entry by ID
    public func vaultEntry(withId id: UUID) -> VaultEntry? {
        vaultEntries.first { $0.id == id }
    }
    
    // MARK: - Public Methods - Formatting
    
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

/// Represents a budget category with its limit and current spending
public struct CategoryBudget: Identifiable, Hashable {
    public let id: UUID
    public let category: BudgetCategory
    public var limit: Decimal
    public var spent: Decimal
    
    public init(
        id: UUID = UUID(),
        category: BudgetCategory,
        limit: Decimal,
        spent: Decimal = 0
    ) {
        self.id = id
        self.category = category
        self.limit = limit
        self.spent = spent
    }
    
    /// Remaining budget amount
    public var remaining: Decimal {
        limit - spent
    }
    
    /// Percentage of budget spent
    public var spentPercentage: Double {
        guard limit > 0 else { return 0 }
        return Double(truncating: (spent / limit) as NSDecimalNumber)
    }
    
    /// Whether the category is over budget
    public var isOverBudget: Bool {
        spent > limit
    }
    
    /// Whether the category is near its limit (>80%)
    public var isNearLimit: Bool {
        spentPercentage >= 0.8
    }
    
    /// Formatted limit string
    public var formattedLimit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: limit as NSDecimalNumber) ?? ""
    }
    
    /// Formatted spent string
    public var formattedSpent: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: spent as NSDecimalNumber) ?? ""
    }
    
    /// Formatted remaining string
    public var formattedRemaining: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: remaining as NSDecimalNumber) ?? ""
    }
}
