//
//  Color+Theme.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI

extension Color {
    /// IOO 应用主题颜色
    struct Theme {
        // Primary Colors
        static let primary = Color.accentColor
        static let secondary = Color.gray

        // Background Colors
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)

        // Status Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // UI Element Colors
        static let border = Color.gray.opacity(0.3)
        static let divider = Color.gray.opacity(0.2)

        // Canvas Colors
        static let canvasBackground = Color.white
        static let canvasBorder = Color.gray.opacity(0.5)

        // Connection Status Colors
        static let connected = Color.green
        static let connecting = Color.blue
        static let disconnected = Color.gray
    }
}

// MARK: - Hex Color Extension
extension Color {
    /// 从 Hex 字符串创建颜色
    /// - Parameter hex: Hex 颜色字符串（支持 "#RRGGBB" 或 "RRGGBB"）
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// 转换为 Hex 字符串
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]

        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
}

// MARK: - Predefined Drawing Colors
extension Color {
    /// 绘画时的预设颜色
    struct DrawingColors {
        static let black = Color.black
        static let white = Color.white
        static let red = Color.red
        static let blue = Color.blue
        static let green = Color.green
        static let yellow = Color.yellow
        static let orange = Color.orange
        static let purple = Color.purple
        static let pink = Color.pink
        static let brown = Color.brown

        static let all: [Color] = [
            black, red, blue, green, yellow,
            orange, purple, pink, brown
        ]
    }
}
