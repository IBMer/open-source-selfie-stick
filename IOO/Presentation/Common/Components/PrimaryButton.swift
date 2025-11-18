//
//  PrimaryButton.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

/// 主要按钮组件
/// 统一的按钮样式，遵循 DRY 原则
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .accentColor
        case .secondary:
            return Color.gray.opacity(0.2)
        case .destructive:
            return Color.red.opacity(0.1)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return .primary
        case .destructive:
            return .red
        }
    }
}

extension PrimaryButton {
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
    }
}

// MARK: - Convenience Initializers
extension PrimaryButton {
    static func primary(
        _ title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .primary, isEnabled: isEnabled)
    }

    static func secondary(
        _ title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .secondary, isEnabled: isEnabled)
    }

    static func destructive(
        _ title: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> PrimaryButton {
        PrimaryButton(title: title, action: action, style: .destructive, isEnabled: isEnabled)
    }
}
