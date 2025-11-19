//
//  HapticFeedback.swift
//  IOO
//
//  Created on 2025-11-18.
//

import UIKit
import SwiftUI

/// 触觉反馈管理器
/// 提供统一的触觉反馈接口
enum HapticFeedback {
    // MARK: - Impact Feedback

    /// 轻微撞击反馈
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// 中等撞击反馈
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// 重度撞击反馈
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// 柔和撞击反馈（iOS 13+）
    static func soft() {
        if #available(iOS 13.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        } else {
            light()
        }
    }

    /// 强烈撞击反馈（iOS 13+）
    static func rigid() {
        if #available(iOS 13.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        } else {
            heavy()
        }
    }

    // MARK: - Notification Feedback

    /// 成功反馈
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// 警告反馈
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// 错误反馈
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// 选择改变反馈
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Contextual Feedback

    /// 连接成功反馈
    static func connected() {
        success()
    }

    /// 断开连接反馈
    static func disconnected() {
        warning()
    }

    /// 绘画完成反馈
    static func drawingComplete() {
        success()
    }

    /// 清空画布反馈
    static func canvasCleared() {
        medium()
    }

    /// 颜色选择反馈
    static func colorSelected() {
        selection()
    }

    /// 按钮点击反馈
    static func buttonTap() {
        light()
    }

    /// 游戏开始反馈
    static func gameStart() {
        heavy()
    }

    /// 倒计时警告反馈（时间即将用尽）
    static func timeWarning() {
        warning()
    }

    /// 时间到反馈
    static func timeUp() {
        rigid()
    }
}

/// 视图修饰符：为视图添加触觉反馈
struct HapticModifier: ViewModifier {
    let feedback: () -> Void

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                feedback()
            }
    }
}

extension View {
    /// 为点击操作添加触觉反馈
    /// - Parameter style: 触觉反馈类型
    /// - Returns: 修改后的视图
    func hapticFeedback(_ feedback: @escaping () -> Void = HapticFeedback.light) -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    feedback()
                }
        )
    }
}
