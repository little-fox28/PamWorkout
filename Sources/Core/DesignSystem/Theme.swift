import SwiftUI

public enum Theme {
    public enum Colors {
        public static let background = Color(.systemGroupedBackground) 
        public static let surface = Color(.secondarySystemGroupedBackground) 
        public static let primaryAccent = Color.green 
        public static let textPrimary = Color(.label)
        public static let textSecondary = Color(.secondaryLabel) 
    }
    
    public enum Typography {
        public static let title = Font.system(.title, design: .rounded).weight(.bold)
        public static let body = Font.system(.body, design: .rounded)
        public static let timerDisplay = Font.system(size: 72, weight: .bold, design: .monospaced)
    }
}