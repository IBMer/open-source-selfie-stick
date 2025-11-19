//
//  ErrorBanner.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI

/// 错误提示横幅
/// 显示错误消息并提供重试选项
struct ErrorBanner: View {
    let error: AppError
    let onRetry: (() -> Void)?
    let onDismiss: (() -> Void)?

    init(
        error: AppError,
        onRetry: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // 错误图标
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(.red)

                // 错误信息
                VStack(alignment: .leading, spacing: 4) {
                    Text("出错了")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let description = error.errorDescription {
                        Text(description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let suggestion = error.recoverySuggestion {
                        Text(suggestion)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 2)
                    }
                }

                Spacer()

                // 关闭按钮
                if let onDismiss = onDismiss {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // 重试按钮
            if error.isRetryable, let onRetry = onRetry {
                HStack {
                    Spacer()
                    Button {
                        onRetry()
                    } label: {
                        Label("重试", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}

/// 全屏错误视图
/// 用于关键错误的全屏显示
struct FullScreenErrorView: View {
    let error: AppError
    let onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.red)
                .symbolEffect(.pulse, value: error)

            VStack(spacing: 8) {
                Text("出错了")
                    .font(.title2)
                    .fontWeight(.bold)

                if let description = error.errorDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
            }

            Spacer()

            if error.isRetryable, let onRetry = onRetry {
                PrimaryButton.primary("重试") {
                    onRetry()
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}
