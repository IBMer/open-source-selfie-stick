//
//  GameSessionEntity.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation
import SwiftData

/// 游戏会话 SwiftData 实体
/// 用于持久化存储游戏记录
@Model
final class GameSessionEntity {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var partnerName: String
    var topic: String

    // 绘画数据（使用外部存储）
    @Attribute(.externalStorage) var myDrawingImageData: Data
    var myDrawingStrokes: Data  // JSON encoded [DrawingStroke]

    @Attribute(.externalStorage) var partnerDrawingImageData: Data?
    var partnerDrawingStrokes: Data?

    var matchScore: Int?

    init(
        id: UUID,
        createdAt: Date,
        partnerName: String,
        topic: String,
        myDrawingImageData: Data,
        myDrawingStrokes: Data,
        partnerDrawingImageData: Data? = nil,
        partnerDrawingStrokes: Data? = nil,
        matchScore: Int? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.partnerName = partnerName
        self.topic = topic
        self.myDrawingImageData = myDrawingImageData
        self.myDrawingStrokes = myDrawingStrokes
        self.partnerDrawingImageData = partnerDrawingImageData
        self.partnerDrawingStrokes = partnerDrawingStrokes
        self.matchScore = matchScore
    }
}
