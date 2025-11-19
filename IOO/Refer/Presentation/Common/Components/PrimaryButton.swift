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
    var accessibilityHint: String? = nil
    var accessibilityIdentifier: String? = nil

    var body: some View {
        Button {
            if isEnabled {
                HapticFeedback.buttonTap()
                action()
            }
        } label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: AccessibilityConstants.minimumTouchTargetSize)
                .padding()
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityRemoveTraits(isEnabled ? [] : .isButton)
        .accessibilityHint(accessibilityHint ?? defaultHint)
        .modifier(ConditionalAccessibilityIdentifier(identifier: accessibilityIdentifier))
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

    private var defaultHint: String {
        switch style {
        case .primary:
            return "双击激活主要操作"
        case .secondary:
            return "双击激活次要操作"
        case .destructive:
            return "双击执行删除操作"
        }
    }
}

/// 条件辅助功能标识符修饰符
private struct ConditionalAccessibilityIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier = identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
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
