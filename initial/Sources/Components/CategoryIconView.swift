import SwiftUI

/// A reusable circular icon view for displaying budget category symbols.
/// Renders an SF Symbol on a circular background with consistent styling.
public struct CategoryIconView: View {
    public let symbolName: String
    public let backgroundColor: Color
    public let iconColor: Color
    public let size: CGFloat
    
    public init(
        symbolName: String,
        backgroundColor: Color = Constants.Colors.primaryIndigo.opacity(0.1),
        iconColor: Color = Constants.Colors.primaryIndigo,
        size: CGFloat = 40
    ) {
        self.symbolName = symbolName
        self.backgroundColor = backgroundColor
        self.iconColor = iconColor
        self.size = size
    }
    
    public var body: some View {
        Image(systemName: symbolName)
            .font(.title2)
            .foregroundStyle(iconColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .clipShape(Circle())
    }
}

#if DEBUG
#Preview("Default Style") {
    CategoryIconView(symbolName: "cart.fill")
}

#Preview("Custom Colors") {
    HStack(spacing: 16) {
        CategoryIconView(
            symbolName: "house.fill",
            backgroundColor: Constants.Colors.successGreen.opacity(0.1),
            iconColor: Constants.Colors.successGreen
        )
        CategoryIconView(
            symbolName: "car.fill",
            backgroundColor: Constants.Colors.dangerRed.opacity(0.1),
            iconColor: Constants.Colors.dangerRed
        )
    }
}
#endif
