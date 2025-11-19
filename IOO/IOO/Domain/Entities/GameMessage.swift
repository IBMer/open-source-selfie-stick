//
//  GameMessage.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation

/// 游戏消息类型
/// 用于设备间通信
enum GameMessage: Codable, Sendable {
    /// 游戏开始（包含题目）
    case gameStarted(topic: String)

    /// 绘画已提交
    case drawingSubmitted(DrawingData)

    /// 请求开始新游戏
    case requestNewGame

    /// 伙伴准备就绪
    case partnerReady

    /// 游戏取消
    case gameCancelled

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }

    enum MessageType: String, Codable {
        case gameStarted
        case drawingSubmitted
        case requestNewGame
        case partnerReady
        case gameCancelled
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)

        switch type {
        case .gameStarted:
            let topic = try container.decode(String.self, forKey: .payload)
            self = .gameStarted(topic: topic)

        case .drawingSubmitted:
            let drawing = try container.decode(DrawingData.self, forKey: .payload)
            self = .drawingSubmitted(drawing)

        case .requestNewGame:
            self = .requestNewGame

        case .partnerReady:
            self = .partnerReady

        case .gameCancelled:
            self = .gameCancelled
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .gameStarted(let topic):
            try container.encode(MessageType.gameStarted, forKey: .type)
            try container.encode(topic, forKey: .payload)

        case .drawingSubmitted(let drawing):
            try container.encode(MessageType.drawingSubmitted, forKey: .type)
            try container.encode(drawing, forKey: .payload)

        case .requestNewGame:
            try container.encode(MessageType.requestNewGame, forKey: .type)

        case .partnerReady:
            try container.encode(MessageType.partnerReady, forKey: .type)

        case .gameCancelled:
            try container.encode(MessageType.gameCancelled, forKey: .type)
        }
    }
}

// MARK: - Helper Methods
extension GameMessage {
    /// 消息描述（用于调试）
    var description: String {
        switch self {
        case .gameStarted(let topic):
            return "Game started with topic: \(topic)"
        case .drawingSubmitted:
            return "Drawing submitted"
        case .requestNewGame:
            return "Request new game"
        case .partnerReady:
            return "Partner ready"
        case .gameCancelled:
            return "Game cancelled"
        }
    }
}
