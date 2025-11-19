//
//  FetchGameHistoryUseCase.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation

/// 获取游戏历史用例
/// 负责获取历史游戏记录
struct FetchGameHistoryUseCase: Sendable {
    private let repository: GameRepositoryProtocol

    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }

    /// 获取所有游戏历史
    /// - Returns: 游戏会话数组，按时间倒序
    func execute() async throws -> [GameSession] {
        try await repository.fetchAll()
    }

    /// 获取与特定伙伴的游戏历史
    /// - Parameter partnerName: 伙伴名称
    /// - Returns: 与该伙伴的游戏会话
    func execute(partnerName: String) async throws -> [GameSession] {
        try await repository.fetchSessions(with: partnerName)
    }

    /// 获取最近的游戏
    /// - Parameter limit: 限制数量，默认 20
    /// - Returns: 最近的游戏会话
    func executeRecent(limit: Int = 20) async throws -> [GameSession] {
        try await repository.fetchRecent(limit: limit)
    }
}
