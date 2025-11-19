//
//  GameSessionMapper.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 游戏会话映射器
/// 负责 Domain Model 和 SwiftData Entity 之间的转换
enum GameSessionMapper {
    /// SwiftData Entity → Domain Model
    /// - Parameter entity: SwiftData 实体
    /// - Returns: 领域模型
    /// - Throws: 解码错误
    static func toDomain(_ entity: GameSessionEntity) throws -> GameSession {
        // 解码自己的笔触数据
        let myStrokes = try JSONDecoder().decode(
            [DrawingStroke].self,
            from: entity.myDrawingStrokes
        )

        let myDrawing = DrawingData(
            imageData: entity.myDrawingImageData,
            strokes: myStrokes
        )

        // 解码对方的笔触数据（如果存在）
        var partnerDrawing: DrawingData?
        if let partnerImageData = entity.partnerDrawingImageData,
           let partnerStrokesData = entity.partnerDrawingStrokes {
            let partnerStrokes = try JSONDecoder().decode(
                [DrawingStroke].self,
                from: partnerStrokesData
            )
            partnerDrawing = DrawingData(
                imageData: partnerImageData,
                strokes: partnerStrokes
            )
        }

        return GameSession(
            id: entity.id,
            createdAt: entity.createdAt,
            partnerName: entity.partnerName,
            topic: entity.topic,
            myDrawing: myDrawing,
            partnerDrawing: partnerDrawing,
            matchScore: entity.matchScore
        )
    }

    /// Domain Model → SwiftData Entity
    /// - Parameter domain: 领域模型
    /// - Returns: SwiftData 实体
    /// - Throws: 编码错误
    static func toEntity(_ domain: GameSession) throws -> GameSessionEntity {
        // 编码自己的笔触数据
        let myStrokesData = try JSONEncoder().encode(domain.myDrawing.strokes)

        // 编码对方的笔触数据（如果存在）
        var partnerImageData: Data?
        var partnerStrokesData: Data?
        if let partnerDrawing = domain.partnerDrawing {
            partnerImageData = partnerDrawing.imageData
            partnerStrokesData = try JSONEncoder().encode(partnerDrawing.strokes)
        }

        return GameSessionEntity(
            id: domain.id,
            createdAt: domain.createdAt,
            partnerName: domain.partnerName,
            topic: domain.topic,
            myDrawingImageData: domain.myDrawing.imageData,
            myDrawingStrokes: myStrokesData,
            partnerDrawingImageData: partnerImageData,
            partnerDrawingStrokes: partnerStrokesData,
            matchScore: domain.matchScore
        )
    }
}
