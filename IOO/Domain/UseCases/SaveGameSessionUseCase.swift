//
//  SaveGameSessionUseCase.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 保存游戏会话用例
/// 负责将游戏会话保存到持久化存储
struct SaveGameSessionUseCase: Sendable {
    private let repository: GameRepositoryProtocol

    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }

    /// 执行保存操作
    /// - Parameter session: 要保存的游戏会话
    func execute(_ session: GameSession) async throws {
        // 验证游戏会话
        guard session.isCompleted else {
            throw GameSessionError.incompleteSession
        }

        try await repository.save(session)
    }
}

/// 游戏会话错误
enum GameSessionError: Error, LocalizedError {
    case incompleteSession
    case invalidData

    var errorDescription: String? {
        switch self {
        case .incompleteSession:
            return "游戏会话未完成，缺少对方的绘画"
        case .invalidData:
            return "游戏数据无效"
        }
    }
}
