import SwiftUI

/// Custom view modifiers for layout helpers
/// Follows Constitution Principle V: Idiomatic & Clean Syntax
/// Follows 8pt grid system for consistent spacing

public extension View {
    /// Apply standard padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied padding
    func gridPadding(_ multiplier: CGFloat = 2) -> some View {
        self.padding(multiplier * 8)
    }
    
    /// Apply horizontal padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied horizontal padding
    func gridPaddingHorizontal(_ multiplier: CGFloat = 2) -> some View {
        self.padding(.horizontal, multiplier * 8)
    }
    
    /// Apply vertical padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied vertical padding
    func gridPaddingVertical(_ multiplier: CGFloat = 2) -> some View {
        self.padding(.vertical, multiplier * 8)
    }
    
    /// Apply leading padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied leading padding
    func gridPaddingLeading(_ multiplier: CGFloat = 2) -> some View {
        self.padding(.leading, multiplier * 8)
    }
    
    /// Apply trailing padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied trailing padding
    func gridPaddingTrailing(_ multiplier: CGFloat = 2) -> some View {
        self.padding(.trailing, multiplier * 8)
    }
    
    /// Apply top padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied top padding
    func gridPaddingTop(_ multiplier: CGFloat = 2) -> some View {
        self.padding(.top, multiplier * 8)
    }
    
    /// Apply bottom padding based on 8pt grid system
    /// - Parameter multiplier: Grid multiplier (default: 2 for 16pt)
    /// - Returns: View with applied bottom padding
    func gridPaddingBottom(_ multiplier: CGFloat = 2) -> some View {
        self.padding(.bottom, multiplier * 8)
    }
    
    /// Apply standard iPhone margins (16pt)
    /// - Returns: View with iPhone-appropriate margins
    func iPhoneMargins() -> some View {
        self.padding(.horizontal, 16)
    }
    
    /// Apply standard iPad margins (24pt for compact, 32pt for regular)
    /// - Parameter sizeClass: Horizontal size class
    /// - Returns: View with iPad-appropriate margins
    func iPadMargins(sizeClass: UserInterfaceSizeClass?) -> some View {
        let margin: CGFloat = sizeClass == .regular ? 32 : 24
        return self.padding(.horizontal, margin)
    }
    
    /// Apply adaptive margins based on device
    /// - Parameter sizeClass: Horizontal size class
    /// - Returns: View with device-appropriate margins
    func adaptiveMargins(sizeClass: UserInterfaceSizeClass?) -> some View {
        let margin: CGFloat
        switch sizeClass {
        case .regular:
            margin = 32
        case .compact:
            margin = 16
        case .none:
            margin = 16
        @unknown default:
            margin = 16
        }
        return self.padding(.horizontal, margin)
    }
}
