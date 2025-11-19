//
//  AppError.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation

/// 应用层错误定义
enum AppError: LocalizedError, Sendable, Equatable {
    // MARK: - Connection Errors
    case connectionFailed(reason: String)
    case connectionLost
    case peerDisconnected
    case messageSendFailed
    case connectionTimeout

    // MARK: - Data Errors
    case saveFailed(reason: String)
    case loadFailed(reason: String)
    case deleteFailed(reason: String)
    case dataCorrupted
    case encodingFailed
    case decodingFailed

    // MARK: - Game Errors
    case invalidGameState
    case drawingDataInvalid
    case topicGenerationFailed
    case partnerNotReady
    case gameSessionExpired

    // MARK: - Network Errors
    case networkUnavailable
    case requestTimeout
    case serverError(statusCode: Int)

    // MARK: - General Errors
    case unknown(String)  // Store error description instead of Error

    var errorDescription: String? {
        switch self {
        // Connection Errors
        case .connectionFailed(let reason):
            return "连接失败: \(reason)"
        case .connectionLost:
            return "连接已断开"
        case .peerDisconnected:
            return "对方已断开连接"
        case .messageSendFailed:
            return "消息发送失败"
        case .connectionTimeout:
            return "连接超时，请重试"

        // Data Errors
        case .saveFailed(let reason):
            return "保存失败: \(reason)"
        case .loadFailed(let reason):
            return "加载失败: \(reason)"
        case .deleteFailed(let reason):
            return "删除失败: \(reason)"
        case .dataCorrupted:
            return "数据已损坏"
        case .encodingFailed:
            return "数据编码失败"
        case .decodingFailed:
            return "数据解码失败"

        // Game Errors
        case .invalidGameState:
            return "游戏状态异常"
        case .drawingDataInvalid:
            return "绘画数据无效"
        case .topicGenerationFailed:
            return "题目生成失败"
        case .partnerNotReady:
            return "对方还未准备好"
        case .gameSessionExpired:
            return "游戏会话已过期"

        // Network Errors
        case .networkUnavailable:
            return "网络不可用，请检查网络连接"
        case .requestTimeout:
            return "请求超时"
        case .serverError(let code):
            return "服务器错误 (代码: \(code))"

        // General
        case .unknown(let description):
            return "未知错误: \(description)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .connectionFailed, .connectionLost, .peerDisconnected:
            return "请确保两台设备都开启了 WiFi 和蓝牙，并且距离足够近"
        case .connectionTimeout:
            return "请检查网络连接后重试"
        case .networkUnavailable:
            return "请连接到 WiFi 或移动网络"
        case .saveFailed, .loadFailed:
            return "请稍后重试，如果问题持续存在，请重启应用"
        case .dataCorrupted:
            return "建议清除应用数据后重试"
        case .gameSessionExpired:
            return "请重新开始游戏"
        default:
            return "请重试或联系技术支持"
        }
    }

    /// 是否可以重试
    var isRetryable: Bool {
        switch self {
        case .connectionFailed, .connectionTimeout, .messageSendFailed,
             .networkUnavailable, .requestTimeout, .saveFailed, .loadFailed:
            return true
        case .dataCorrupted, .invalidGameState, .gameSessionExpired:
            return false
        default:
            return true
        }
    }
}

/// 错误处理辅助方法
extension AppError {
    /// 从通用错误转换为 AppError
    static func from(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        return .unknown(error.localizedDescription)
    }
}
