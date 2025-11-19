//
//  ResultViewModel.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation
import Observation

/// 结果界面 ViewModel
@Observable
final class ResultViewModel {
    // MARK: - State
    let session: GameSession
    var isSaving: Bool = false
    var isSaved: Bool = false
    var errorMessage: String?

    // MARK: - Dependencies
    private let saveGameUseCase: SaveGameSessionUseCase

    // MARK: - Initialization
    init(
        session: GameSession,
        saveGameUseCase: SaveGameSessionUseCase
    ) {
        self.session = session
        self.saveGameUseCase = saveGameUseCase
    }

    // MARK: - Actions
    func saveSession() async {
        isSaving = true
        errorMessage = nil

        do {
            try await saveGameUseCase.execute(session)
            isSaved = true
            isSaving = false
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }
}
