import Foundation

/// Represents a single financial movement within the ledger.
public struct Transaction: Identifiable, Codable, Hashable, Sendable {
    /// Distinguishes whether a transaction increases or decreases the balance.
    public enum TransactionType: String, Codable, CaseIterable, Sendable {
        case income
        case expense
    }

    public let id: UUID
    public let amount: Decimal
    public let category: BudgetCategory
    public let timestamp: Date
    public let note: String?
    public let type: TransactionType

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.generatesDecimalNumbers = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()

    public init(
        id: UUID = UUID(),
        amount: Decimal,
        category: BudgetCategory,
        timestamp: Date = Date(),
        note: String? = nil,
        type: TransactionType
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.timestamp = timestamp
        self.note = note
        self.type = type
    }

    /// Localized amount string that respects grouping separators for the active locale.
    public var formattedAmount: String {
        Self.currencyFormatter.string(from: amount.nsDecimalNumber) ?? ""
    }

    /// Localized amount string prefixed with the appropriate financial sign.
    public var formattedSignedAmount: String {
        let baseAmount = formattedAmount
        guard !baseAmount.isEmpty else { return baseAmount }

        switch type {
        case .income where amount.isNegative:
            return baseAmount
        case .income:
            return "+" + baseAmount
        case .expense where amount.isNegative:
            return baseAmount
        case .expense:
            return "-" + baseAmount
        }
    }

    /// Convenience bridge for UI layers that expect display names per category.
    public var categoryName: String { category.displayName }

    /// Convenience bridge for UI layers that expect an icon per category.
    public var categoryIconName: String { category.symbolName }
}

private extension Decimal {
    var nsDecimalNumber: NSDecimalNumber { self as NSDecimalNumber }
    var isNegative: Bool { self < .zero }
}
