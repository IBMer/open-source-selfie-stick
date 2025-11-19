//
//  RetryHelper.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 重试辅助工具
enum RetryHelper {
    /// 执行带重试的异步操作
    /// - Parameters:
    ///   - maxAttempts: 最大重试次数（默认3次）
    ///   - delay: 每次重试间隔秒数（默认1秒）
    ///   - backoffMultiplier: 退避倍数（默认2.0，即每次重试延迟翻倍）
    ///   - operation: 要执行的异步操作
    /// - Returns: 操作结果
    /// - Throws: 如果所有重试都失败，抛出最后一次的错误
    static func retry<T>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 1.0,
        backoffMultiplier: Double = 2.0,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        var currentDelay = delay
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error

                // 如果错误不可重试，直接抛出
                if let appError = error as? AppError, !appError.isRetryable {
                    throw error
                }

                // 如果还有重试机会，等待后重试
                if attempt < maxAttempts {
                    try await Task.sleep(for: .seconds(currentDelay))
                    currentDelay *= backoffMultiplier
                }
            }
        }

        // 所有重试都失败，抛出最后一个错误
        throw lastError ?? AppError.unknown(NSError(domain: "RetryHelper", code: -1))
    }

    /// 执行带超时的异步操作
    /// - Parameters:
    ///   - timeout: 超时时间（秒）
    ///   - operation: 要执行的异步操作
    /// - Returns: 操作结果
    /// - Throws: 如果超时，抛出 connectionTimeout 错误
    static func withTimeout<T>(
        _ timeout: TimeInterval,
        operation: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            // 添加实际操作任务
            group.addTask {
                try await operation()
            }

            // 添加超时任务
            group.addTask {
                try await Task.sleep(for: .seconds(timeout))
                throw AppError.connectionTimeout
            }

            // 返回第一个完成的任务结果
            guard let result = try await group.next() else {
                throw AppError.connectionTimeout
            }

            // 取消其他任务
            group.cancelAll()

            return result
        }
    }
}
