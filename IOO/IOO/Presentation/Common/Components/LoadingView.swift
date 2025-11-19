//
//  LoadingView.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

/// 加载视图组件
/// 统一的加载状态显示
struct LoadingView: View {
    let message: String?

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String?
    var action: (() -> Void)?
    var actionTitle: String?

    init(
        icon: String = "tray",
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 错误视图
/// 支持 String 和 AppError 两种错误类型
struct ErrorView: View {
    let error: String
    let appError: AppError?
    var retryAction: (() -> Void)?

    init(error: String, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.appError = nil
        self.retryAction = retryAction
    }

    init(appError: AppError, retryAction: (() -> Void)? = nil) {
        self.error = appError.localizedDescription
        self.appError = appError
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)

            Text("出错了")
                .font(.title3)
                .fontWeight(.semibold)

            Text(error)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // 恢复建议
            if let suggestion = appError?.recoverySuggestion {
                Text(suggestion)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // 重试按钮（仅对可重试的错误显示）
            if let retryAction = retryAction,
               appError?.isRetryable ?? true {
                Button("重试", action: retryAction)
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
