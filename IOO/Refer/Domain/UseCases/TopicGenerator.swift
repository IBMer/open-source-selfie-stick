//
//  TopicGenerator.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 题目生成器
/// 负责加载和随机选择游戏题目
struct TopicGenerator: Sendable {
    private let topics: [Topic]

    init(topics: [Topic]) {
        self.topics = topics
    }

    /// 从 JSON 文件初始化
    static func fromJSON(fileName: String = "Topics") throws -> TopicGenerator {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw TopicError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let topics = try JSONDecoder().decode([Topic].self, from: data)

        guard !topics.isEmpty else {
            throw TopicError.emptyTopics
        }

        return TopicGenerator(topics: topics)
    }

    /// 随机获取一个题目
    func randomTopic() -> Topic? {
        topics.randomElement()
    }

    /// 根据分类随机获取题目
    func randomTopic(category: Topic.Category) -> Topic? {
        topics.filter { $0.category == category }.randomElement()
    }

    /// 根据难度随机获取题目
    func randomTopic(difficulty: Topic.Difficulty) -> Topic? {
        topics.filter { $0.difficulty == difficulty }.randomElement()
    }

    /// 根据分类和难度随机获取题目
    func randomTopic(
        category: Topic.Category,
        difficulty: Topic.Difficulty
    ) -> Topic? {
        topics.filter {
            $0.category == category && $0.difficulty == difficulty
        }.randomElement()
    }

    /// 获取所有题目
    var allTopics: [Topic] {
        topics
    }

    /// 题目总数
    var count: Int {
        topics.count
    }
}

// MARK: - Default Topics
extension TopicGenerator {
    /// 默认题目生成器（内置题目）
    static let `default` = TopicGenerator(topics: [
        // 动物类
        Topic(text: "猫", category: .animal, difficulty: .easy),
        Topic(text: "狗", category: .animal, difficulty: .easy),
        Topic(text: "大象", category: .animal, difficulty: .medium),
        Topic(text: "长颈鹿", category: .animal, difficulty: .medium),
        Topic(text: "企鹅", category: .animal, difficulty: .medium),
        Topic(text: "蝴蝶", category: .animal, difficulty: .hard),
        Topic(text: "章鱼", category: .animal, difficulty: .hard),

        // 食物类
        Topic(text: "苹果", category: .food, difficulty: .easy),
        Topic(text: "西瓜", category: .food, difficulty: .easy),
        Topic(text: "冰淇淋", category: .food, difficulty: .medium),
        Topic(text: "汉堡", category: .food, difficulty: .medium),
        Topic(text: "寿司", category: .food, difficulty: .hard),
        Topic(text: "火锅", category: .food, difficulty: .hard),

        // 物品类
        Topic(text: "杯子", category: .object, difficulty: .easy),
        Topic(text: "雨伞", category: .object, difficulty: .easy),
        Topic(text: "眼镜", category: .object, difficulty: .medium),
        Topic(text: "钥匙", category: .object, difficulty: .medium),
        Topic(text: "相机", category: .object, difficulty: .hard),
        Topic(text: "吉他", category: .object, difficulty: .hard),

        // 自然类
        Topic(text: "太阳", category: .nature, difficulty: .easy),
        Topic(text: "月亮", category: .nature, difficulty: .easy),
        Topic(text: "星星", category: .nature, difficulty: .easy),
        Topic(text: "彩虹", category: .nature, difficulty: .medium),
        Topic(text: "闪电", category: .nature, difficulty: .medium),
        Topic(text: "火山", category: .nature, difficulty: .hard),

        // 交通工具类
        Topic(text: "汽车", category: .transportation, difficulty: .easy),
        Topic(text: "自行车", category: .transportation, difficulty: .easy),
        Topic(text: "飞机", category: .transportation, difficulty: .medium),
        Topic(text: "火箭", category: .transportation, difficulty: .medium),
        Topic(text: "潜水艇", category: .transportation, difficulty: .hard),
        Topic(text: "热气球", category: .transportation, difficulty: .hard),

        // 通用类
        Topic(text: "房子", category: .general, difficulty: .easy),
        Topic(text: "树", category: .general, difficulty: .easy),
        Topic(text: "花", category: .general, difficulty: .easy),
        Topic(text: "爱心", category: .general, difficulty: .medium),
        Topic(text: "礼物", category: .general, difficulty: .medium),
    ])
}

// MARK: - Topic Error
enum TopicError: Error, LocalizedError {
    case fileNotFound
    case emptyTopics
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "题目文件未找到"
        case .emptyTopics:
            return "题目列表为空"
        case .invalidFormat:
            return "题目文件格式错误"
        }
    }
}
