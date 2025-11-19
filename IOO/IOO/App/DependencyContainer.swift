//
//  DependencyContainer.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation
import SwiftData
import Observation

/// 依赖注入容器
/// 管理所有依赖关系和对象创建
@Observable
final class DependencyContainer {
    // MARK: - Repositories
    let gameRepository: GameRepositoryProtocol
    let connectionRepository: ConnectionRepositoryProtocol

    // MARK: - Use Cases
    let saveGameUseCase: SaveGameSessionUseCase
    let fetchGameHistoryUseCase: FetchGameHistoryUseCase
    let deleteGameUseCase: DeleteGameSessionUseCase

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        // Initialize repositories
        self.gameRepository = SwiftDataGameRepository(modelContext: modelContext)
        self.connectionRepository = MultipeerConnectionRepository()

        // Initialize use cases
        self.saveGameUseCase = SaveGameSessionUseCase(repository: gameRepository)
        self.fetchGameHistoryUseCase = FetchGameHistoryUseCase(repository: gameRepository)
        self.deleteGameUseCase = DeleteGameSessionUseCase(repository: gameRepository)
    }

    // MARK: - ViewModel Factories
    func makePairingViewModel() -> PairingViewModel {
        PairingViewModel(connectionRepository: connectionRepository)
    }

    func makeGameViewModel() -> GameViewModel {
        GameViewModel(
            saveGameUseCase: saveGameUseCase,
            connectionRepository: connectionRepository
        )
    }

    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(
            fetchGameHistoryUseCase: fetchGameHistoryUseCase,
            deleteGameUseCase: deleteGameUseCase
        )
    }

    func makeResultViewModel(session: GameSession) -> ResultViewModel {
        ResultViewModel(
            session: session,
            saveGameUseCase: saveGameUseCase
        )
    }
}
