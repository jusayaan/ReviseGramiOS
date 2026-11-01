import SwiftUI

enum DesignTokens {
    // Spacing scale (matches Android DesignTokens)
    static let spaceXXS: CGFloat = 4
    static let spaceXS: CGFloat = 8
    static let spaceSM: CGFloat = 12
    static let spaceMD: CGFloat = 16
    static let spaceLG: CGFloat = 20
    static let spaceXL: CGFloat = 24
    static let spaceXXL: CGFloat = 32

    static let screenHorizontalPadding: CGFloat = 20

    // Corner radii
    static let radiusSmall: CGFloat = 8
    static let radiusMedium: CGFloat = 12
    static let radiusLarge: CGFloat = 16
    static let radiusPill: CGFloat = 999

    // Brand & Functional Colours
    static let primaryBrand = Color(red: 0x4F / 255.0, green: 0x46 / 255.0, blue: 0xE5 / 255.0)       // #4F46E5
    static let primaryBrandDark = Color(red: 0x37 / 255.0, green: 0x30 / 255.0, blue: 0xA3 / 255.0)   // #3730A3
    static let primaryBrandLight = Color(red: 0x6D / 255.0, green: 0x67 / 255.0, blue: 0xE4 / 255.0)  // #6D67E4
    static let secondaryBrand = Color(red: 0x43 / 255.0, green: 0x38 / 255.0, blue: 0xCA / 255.0)     // #4338CA

    static let successGreen = Color(red: 0x15 / 255.0, green: 0x80 / 255.0, blue: 0x3D / 255.0)       // #15803D
    static let errorRed = Color(red: 0xB9 / 255.0, green: 0x1C / 255.0, blue: 0x1C / 255.0)           // #B91C1C
    static let warningAmber = Color(red: 0xB4 / 255.0, green: 0x53 / 255.0, blue: 0x09 / 255.0)       // #B45309

    // Light & Dark Adaptive Surfaces
    static func background(isDark: Bool) -> Color {
        isDark
            ? Color(red: 0x11 / 255.0, green: 0x12 / 255.0, blue: 0x15 / 255.0) // #111215
            : Color(red: 0xFA / 255.0, green: 0xF9 / 255.0, blue: 0xF6 / 255.0) // #FAF9F6
    }

    static func surface(isDark: Bool) -> Color {
        isDark
            ? Color(red: 0x18 / 255.0, green: 0x1A / 255.0, blue: 0x1F / 255.0) // #181A1F
            : Color.white
    }

    static func surfaceVariant(isDark: Bool) -> Color {
        isDark
            ? Color(red: 0x21 / 255.0, green: 0x24 / 255.0, blue: 0x2C / 255.0) // #21242C
            : Color(red: 0xF2 / 255.0, green: 0xEF / 255.0, blue: 0xE9 / 255.0) // #F2EFE9
    }

    static func border(isDark: Bool) -> Color {
        isDark
            ? Color(red: 0x2A / 255.0, green: 0x2E / 255.0, blue: 0x37 / 255.0) // #2A2E37
            : Color(red: 0xE5 / 255.0, green: 0xE2 / 255.0, blue: 0xDC / 255.0) // #E5E2DC
    }
}
