import Foundation

/// Defines the canonical set of budget categories available inside the app.
public enum BudgetCategory: String, CaseIterable, Codable, Hashable, Sendable, Identifiable {
    case groceries
    case dining
    case transportation
    case housing
    case utilities
    case entertainment
    case healthcare
    case savings
    case income
    case miscellaneous

    public var id: String { rawValue }

    /// Human-readable label for UI presentation.
    public var displayName: String {
        switch self {
        case .groceries: return "Groceries"
        case .dining: return "Dining"
        case .transportation: return "Transportation"
        case .housing: return "Housing"
        case .utilities: return "Utilities"
        case .entertainment: return "Entertainment"
        case .healthcare: return "Healthcare"
        case .savings: return "Savings"
        case .income: return "Income"
        case .miscellaneous: return "Miscellaneous"
        }
    }

    /// SF Symbol name that represents the category icon.
    public var symbolName: String {
        switch self {
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife"
        case .transportation: return "car.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .entertainment: return "sparkles"
        case .healthcare: return "cross.fill"
        case .savings: return "banknote"
        case .income: return "chart.line.uptrend.xyaxis"
        case .miscellaneous: return "ellipsis.circle"
        }
    }

    /// Suggested monthly limit (local currency) for budgeting guidance.
    public var suggestedLimit: Decimal {
        switch self {
        case .groceries: return 600
        case .dining: return 250
        case .transportation: return 300
        case .housing: return 1_500
        case .utilities: return 400
        case .entertainment: return 200
        case .healthcare: return 150
        case .savings: return 500
        case .income: return 10_000
        case .miscellaneous: return 150
        }
    }

    /// Returns the suggested limit formatted as a currency string using locale grouping separators.
    public var formattedLimit: String {
        Self.currencyFormatter.string(from: suggestedLimit as NSDecimalNumber) ?? ""
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        formatter.generatesDecimalNumbers = true
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()
}
