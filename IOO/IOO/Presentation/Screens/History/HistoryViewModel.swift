//
//  HistoryViewModel.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation
import Observation

/// 历史记录 ViewModel
@Observable
final class HistoryViewModel {
    // MARK: - State
    var gameSessions: [GameSession] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let fetchGameHistoryUseCase: FetchGameHistoryUseCase
    private let deleteGameUseCase: DeleteGameSessionUseCase

    // MARK: - Initialization
    init(
        fetchGameHistoryUseCase: FetchGameHistoryUseCase,
        deleteGameUseCase: DeleteGameSessionUseCase
    ) {
        self.fetchGameHistoryUseCase = fetchGameHistoryUseCase
        self.deleteGameUseCase = deleteGameUseCase
    }

    // MARK: - Actions
    func loadHistory() async {
        isLoading = true
        errorMessage = nil

        do {
            gameSessions = try await fetchGameHistoryUseCase.execute()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func deleteSession(id: UUID) async {
        do {
            try await deleteGameUseCase.execute(id: id)
            gameSessions.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
