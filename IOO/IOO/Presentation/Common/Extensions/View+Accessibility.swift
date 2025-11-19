//
//  View+Accessibility.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

extension View {
    /// 添加完整的辅助功能标签
    /// - Parameters:
    ///   - label: 辅助功能标签
    ///   - hint: 辅助功能提示
    ///   - value: 辅助功能值
    ///   - identifier: UI 测试标识符
    /// - Returns: 修改后的视图
    func accessibilityInfo(
        label: String,
        hint: String? = nil,
        value: String? = nil,
        identifier: String? = nil
    ) -> some View {
        var view = self.accessibilityLabel(label)

        if let hint = hint {
            view = view.accessibilityHint(hint)
        }

        if let value = value {
            view = view.accessibilityValue(value)
        }

        if let identifier = identifier {
            view = view.accessibilityIdentifier(identifier)
        }

        return view
    }

    /// 标记为辅助功能按钮
    /// - Parameters:
    ///   - label: 按钮标签
    ///   - hint: 操作提示
    /// - Returns: 修改后的视图
    func accessibilityButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .modifier(ConditionalAccessibilityHint(hint: hint))
    }

    /// 标记为辅助功能标题
    /// - Parameter label: 标题文本
    /// - Returns: 修改后的视图
    func accessibilityHeading(_ label: String? = nil) -> some View {
        var view = self.accessibilityAddTraits(.isHeader)
        if let label = label {
            view = view.accessibilityLabel(label)
        }
        return view
    }
}

/// 条件辅助功能提示修饰符
private struct ConditionalAccessibilityHint: ViewModifier {
    let hint: String?

    func body(content: Content) -> some View {
        if let hint = hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}

/// 辅助功能相关常量
enum AccessibilityConstants {
    /// 最小触摸目标尺寸（符合 Apple 指南）
    static let minimumTouchTargetSize: CGFloat = 44

    /// 推荐的触摸目标尺寸
    static let recommendedTouchTargetSize: CGFloat = 48
}
