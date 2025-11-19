//
//  DrawingData.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation
import CoreGraphics

/// 绘画数据模型
/// 包含图片数据和笔触信息
struct DrawingData: Sendable, Codable, Equatable, Hashable {
    let imageData: Data
    let strokes: [DrawingStroke]

    init(imageData: Data, strokes: [DrawingStroke]) {
        self.imageData = imageData
        self.strokes = strokes
    }
}

/// 单个笔触
struct DrawingStroke: Sendable, Codable, Equatable, Hashable {
    let points: [CGPoint]
    let color: String  // Hex color string
    let width: Double

    init(points: [CGPoint], color: String, width: Double) {
        self.points = points
        self.color = color
        self.width = width
    }
}

// MARK: - Helper Methods
extension DrawingData {
    /// 创建空白绘画
    static var empty: DrawingData {
        DrawingData(imageData: Data(), strokes: [])
    }

    /// 是否为空
    var isEmpty: Bool {
        strokes.isEmpty
    }

    /// 笔触总数
    var strokeCount: Int {
        strokes.count
    }

    /// 图片大小（字节）
    var imageSizeInBytes: Int {
        imageData.count
    }
}
