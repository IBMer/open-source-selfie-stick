//
//  DeleteGameSessionUseCase.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 删除游戏会话用例
struct DeleteGameSessionUseCase: Sendable {
    private let repository: GameRepositoryProtocol

    init(repository: GameRepositoryProtocol) {
        self.repository = repository
    }

    /// 删除指定的游戏会话
    /// - Parameter id: 游戏会话 ID
    func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
