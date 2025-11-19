//
//  Topic.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation

/// 游戏题目模型
struct Topic: Codable, Identifiable, Sendable {
    let id: UUID
    let text: String
    let category: Category
    let difficulty: Difficulty

    init(
        id: UUID = UUID(),
        text: String,
        category: Category = .general,
        difficulty: Difficulty = .medium
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.difficulty = difficulty
    }

    /// 题目分类
    enum Category: String, Codable, CaseIterable {
        case animal = "动物"
        case object = "物品"
        case food = "食物"
        case nature = "自然"
        case transportation = "交通工具"
        case general = "通用"
    }

    /// 难度等级
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "简单"
        case medium = "中等"
        case hard = "困难"
    }
}

// MARK: - Equatable
extension Topic: Equatable {
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        lhs.id == rhs.id
    }
}
