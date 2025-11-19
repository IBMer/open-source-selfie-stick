//
//  GameSession.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 游戏会话领域模型
/// 代表一次完整的画画游戏记录
struct GameSession: Identifiable, Sendable {
    let id: UUID
    let createdAt: Date
    let partnerName: String
    let topic: String
    let myDrawing: DrawingData
    let partnerDrawing: DrawingData?
    let matchScore: Int?

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        partnerName: String,
        topic: String,
        myDrawing: DrawingData,
        partnerDrawing: DrawingData? = nil,
        matchScore: Int? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.partnerName = partnerName
        self.topic = topic
        self.myDrawing = myDrawing
        self.partnerDrawing = partnerDrawing
        self.matchScore = matchScore
    }
}

// MARK: - Helper Methods
extension GameSession {
    /// 游戏是否已完成（双方都提交了绘画）
    var isCompleted: Bool {
        partnerDrawing != nil
    }

    /// 创建一个新的游戏会话（仅包含自己的绘画）
    static func create(
        partnerName: String,
        topic: String,
        myDrawing: DrawingData
    ) -> GameSession {
        GameSession(
            partnerName: partnerName,
            topic: topic,
            myDrawing: myDrawing
        )
    }

    /// 添加对方的绘画
    func withPartnerDrawing(_ drawing: DrawingData, score: Int? = nil) -> GameSession {
        GameSession(
            id: id,
            createdAt: createdAt,
            partnerName: partnerName,
            topic: topic,
            myDrawing: myDrawing,
            partnerDrawing: drawing,
            matchScore: score
        )
    }
}
