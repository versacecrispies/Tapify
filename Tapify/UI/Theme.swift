import SwiftUI

enum Theme {
    // MARK: - Colours
    static let background    = Color(hex: "#1C2220")
    static let surface       = Color(hex: "#242B28")
    static let surfaceHover  = Color(hex: "#2C342F")
    static let accent        = Color(hex: "#E8742A")
    static let accentSoft    = Color(hex: "#E8742A").opacity(0.15)
    static let primaryText   = Color.white
    static let secondaryText = Color(hex: "#8A9E8F")
    static let waveformLine  = Color(hex: "#4CAF7A")
    static let waveformPeak  = Color(hex: "#E8742A")
    static let divider       = Color(hex: "#2C342F")
    static let cardBorder    = Color(hex: "#303B36")

    // MARK: - Geometry
    static let cornerRadius:  CGFloat = 10
    static let cardPadding:   CGFloat = 16
    static let windowWidth:   CGFloat = 480
    static let windowHeight:  CGFloat = 580
}

// MARK: - Color hex initialiser
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
