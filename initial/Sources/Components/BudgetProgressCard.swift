import SwiftUI
// import Models (Implicit in same target)

/// A card component displaying budget progress for a specific category.
/// Includes category label, amount vs limit text, and a horizontal progress bar.
/// Uses Sage Green for income/surplus and Coral Red for expenses/over-budget.
/// Applies adaptive layout principles for iPad split-view support.
public struct BudgetProgressCard: View {
    public let category: BudgetCategory
    public let totalSpent: Decimal
    public let limit: Decimal
    public let isIncome: Bool
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    public init(
        category: BudgetCategory,
        totalSpent: Decimal,
        limit: Decimal,
        isIncome: Bool = false
    ) {
        self.category = category
        self.totalSpent = totalSpent
        self.limit = limit
        self.isIncome = isIncome
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: adaptiveSpacing) {
            // Header: Category Label
            HStack {
                Label {
                    Text(category.displayName)
                        .font(adaptiveHeaderFont)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: category.symbolName)
                        .foregroundStyle(iconColor)
                }
                
                Spacer()
                
                Text(percentageFormatted)
                    .font(adaptiveCaptionFont)
                    .fontWeight(.bold)
                    .foregroundStyle(percentageColor)
            }
            
            // Progress Bar
            ProgressBar(
                progress: progress,
                foregroundColor: progressColor,
                height: adaptiveProgressBarHeight
            )
            
            // Footer: Amount vs Limit Text
            HStack {
                Text("\(formatCurrency(totalSpent)) \(isIncome ? "earned" : "spent")")
                    .font(adaptiveCaptionFont)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("of \(formatCurrency(limit))")
                    .font(adaptiveCaptionFont)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(adaptivePadding)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: adaptiveCornerRadius))
        .frame(maxWidth: .infinity)
    }
    
    private var progress: Double {
        guard limit > 0 else { return 1.0 }
        return Double(truncating: totalSpent as NSNumber) / Double(truncating: limit as NSNumber)
    }
    
    private var percentageFormatted: String {
        let percent = progress * 100
        return String(format: "%.0f%%", percent)
    }
    
    /// Progress bar color based on income/expense and budget status
    private var progressColor: Color {
        if isIncome {
            // Income: Use Sage Green for surplus
            return Constants.Colors.sageGreen
        } else {
            // Expense: Use Coral Red if over budget, otherwise Sage Green
            return progress >= 1.0 ? Constants.Colors.coralRed : Constants.Colors.sageGreen
        }
    }
    
    /// Icon color based on category type
    private var iconColor: Color {
        return isIncome ? Constants.Colors.sageGreen : Constants.Colors.primaryIndigo
    }
    
    /// Percentage text color based on budget status
    private var percentageColor: Color {
        if isIncome {
            return Constants.Colors.sageGreen
        } else {
            return progress >= 1.0 ? Constants.Colors.coralRed : .secondary
        }
    }
    
    // MARK: - Adaptive Layout Properties
    
    /// Adaptive spacing based on size class
    private var adaptiveSpacing: CGFloat {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return Constants.Spacing.medium // iPad full screen
        } else if horizontalSizeClass == .compact {
            return Constants.Spacing.small // iPhone or iPad split-view compact
        } else {
            return Constants.Spacing.small + 2 // iPad split-view regular
        }
    }
    
    /// Adaptive padding based on size class
    private var adaptivePadding: CGFloat {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return Constants.Spacing.large // iPad full screen
        } else if horizontalSizeClass == .compact {
            return Constants.Spacing.medium // iPhone or iPad split-view compact
        } else {
            return Constants.Spacing.medium + 2 // iPad split-view regular
        }
    }
    
    /// Adaptive corner radius based on size class
    private var adaptiveCornerRadius: CGFloat {
        if horizontalSizeClass == .regular {
            return 16 // Larger radius on iPad
        } else {
            return 12 // Standard radius on iPhone
        }
    }
    
    /// Adaptive header font based on size class
    private var adaptiveHeaderFont: Font {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return .title3 // Larger on iPad full screen
        } else {
            return .headline // Standard on iPhone or split-view
        }
    }
    
    /// Adaptive caption font based on size class
    private var adaptiveCaptionFont: Font {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return .subheadline // Slightly larger on iPad
        } else {
            return .caption // Standard on iPhone
        }
    }
    
    /// Adaptive progress bar height based on size class
    private var adaptiveProgressBarHeight: CGFloat {
        if horizontalSizeClass == .regular {
            return 10 // Taller on iPad
        } else {
            return 8 // Standard on iPhone
        }
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: value as NSDecimalNumber) ?? ""
    }
}

#if DEBUG
#Preview("Expense Categories") {
    VStack(spacing: 16) {
        BudgetProgressCard(
            category: .groceries,
            totalSpent: 450,
            limit: 600,
            isIncome: false
        )
        
        BudgetProgressCard(
            category: .dining,
            totalSpent: 300,
            limit: 250,
            isIncome: false
        ) // Over budget - Coral Red
        
        BudgetProgressCard(
            category: .transportation,
            totalSpent: 280,
            limit: 300,
            isIncome: false
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("Income Category") {
    VStack(spacing: 16) {
        BudgetProgressCard(
            category: .income,
            totalSpent: 5000,
            limit: 10000,
            isIncome: true
        ) // Sage Green for income
        
        BudgetProgressCard(
            category: .income,
            totalSpent: 12000,
            limit: 10000,
            isIncome: true
        ) // Over target - still Sage Green
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
}

#Preview("iPad Split-View Simulation") {
    HStack(spacing: 0) {
        VStack(spacing: 16) {
            BudgetProgressCard(
                category: .groceries,
                totalSpent: 450,
                limit: 600,
                isIncome: false
            )
            BudgetProgressCard(
                category: .dining,
                totalSpent: 300,
                limit: 250,
                isIncome: false
            )
        }
        .padding()
        .frame(maxWidth: 400)
        .background(Color(UIColor.systemGroupedBackground))
    }
}
#endif
