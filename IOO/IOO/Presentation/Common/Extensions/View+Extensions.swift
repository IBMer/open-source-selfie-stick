//
//  View+Extensions.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI

extension View {
    /// 条件性修饰符
    /// - Parameters:
    ///   - condition: 条件
    ///   - transform: 应用的修饰符
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 隐藏键盘
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    /// 卡片样式
    func cardStyle(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 12
    ) -> some View {
        self
            .padding(padding)
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    /// 震动效果
    func shake(trigger: Int) -> some View {
        modifier(ShakeEffect(shakes: trigger))
    }
}

// MARK: - Shake Effect Modifier
struct ShakeEffect: GeometryEffect {
    var shakes: Int

    var animatableData: Int {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: 10 * sin(CGFloat(shakes) * .pi * 2),
                y: 0
            )
        )
    }
}

// MARK: - Conditional Modifier
extension View {
    /// 有条件地应用修饰符
    @ViewBuilder
    func conditionalModifier<T: View>(
        _ condition: Bool,
        modifier: (Self) -> T
    ) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}

// MARK: - Border Extension
extension View {
    /// 添加边框
    func border(
        _ color: Color,
        width: CGFloat = 1,
        cornerRadius: CGFloat = 0
    ) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: width)
            )
    }
}
