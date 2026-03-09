import SwiftUI

/// A reusable horizontal progress bar component with customizable colors and adaptive layout.
/// Displays progress as a filled capsule with smooth animations.
public struct ProgressBar: View {
    public let progress: Double
    public let backgroundColor: Color
    public let foregroundColor: Color
    public let height: CGFloat
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public init(
        progress: Double,
        backgroundColor: Color = Color(UIColor.systemGray5),
        foregroundColor: Color = Constants.Colors.primaryIndigo,
        height: CGFloat = 8
    ) {
        self.progress = min(max(progress, 0.0), 1.0) // Clamp between 0 and 1
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.height = height
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Capsule()
                    .fill(backgroundColor)
                    .frame(height: adaptiveHeight)
                
                // Foreground progress
                Capsule()
                    .fill(foregroundColor)
                    .frame(
                        width: min(geometry.size.width * progress, geometry.size.width),
                        height: adaptiveHeight
                    )
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: adaptiveHeight)
    }
    
    /// Adaptive height based on size class for iPad split-view support
    private var adaptiveHeight: CGFloat {
        if horizontalSizeClass == .regular {
            return height * 1.25 // Slightly larger on iPad
        } else {
            return height
        }
    }
}

#if DEBUG
#Preview("Progress Levels") {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            Text("25% Progress")
                .font(.caption)
            ProgressBar(progress: 0.25)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("50% Progress")
                .font(.caption)
            ProgressBar(progress: 0.5)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("75% Progress")
                .font(.caption)
            ProgressBar(progress: 0.75)
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("100% Progress")
                .font(.caption)
            ProgressBar(progress: 1.0)
        }
    }
    .padding()
}

#Preview("Custom Colors") {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sage Green (Income/Surplus)")
                .font(.caption)
            ProgressBar(
                progress: 0.6,
                foregroundColor: Color(red: 0.545, green: 0.659, blue: 0.533) // #8BA888
            )
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Coral Red (Expense/Over-budget)")
                .font(.caption)
            ProgressBar(
                progress: 0.9,
                foregroundColor: Color(red: 0.898, green: 0.451, blue: 0.451) // #E57373
            )
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Custom Height")
                .font(.caption)
            ProgressBar(
                progress: 0.7,
                foregroundColor: Constants.Colors.successGreen,
                height: 12
            )
        }
    }
    .padding()
}
#endif
