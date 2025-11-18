//
//  GameRepositoryProtocol.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 游戏仓储协议
/// 定义游戏会话的持久化操作
protocol GameRepositoryProtocol: Sendable {
    /// 保存游戏会话
    /// - Parameter session: 要保存的游戏会话
    func save(_ session: GameSession) async throws

    /// 获取所有游戏会话
    /// - Returns: 游戏会话数组，按创建时间倒序
    func fetchAll() async throws -> [GameSession]

    /// 根据 ID 获取游戏会话
    /// - Parameter id: 游戏会话 ID
    /// - Returns: 游戏会话，如果不存在则返回 nil
    func fetch(id: UUID) async throws -> GameSession?

    /// 删除游戏会话
    /// - Parameter id: 要删除的游戏会话 ID
    func delete(id: UUID) async throws

    /// 获取与特定伙伴的游戏会话
    /// - Parameter partnerName: 伙伴名称
    /// - Returns: 与该伙伴的所有游戏会话
    func fetchSessions(with partnerName: String) async throws -> [GameSession]

    /// 获取最近的游戏会话
    /// - Parameter limit: 限制数量
    /// - Returns: 最近的游戏会话
    func fetchRecent(limit: Int) async throws -> [GameSession]
}
