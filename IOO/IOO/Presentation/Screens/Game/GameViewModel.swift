//
//  GameViewModel.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation
import Observation

/// 游戏状态
enum GameState: Sendable {
    case waiting
    case drawing
    case timeUp
    case waitingForPartner
    case showingResult
}

/// 游戏界面 ViewModel
@Observable
final class GameViewModel {
    // MARK: - State
    var gameState: GameState = .waiting
    var currentTopic: String = ""
    var countdown: Int = 30
    var myDrawing: DrawingData?
    var partnerDrawing: DrawingData?
    var partnerName: String = ""

    // MARK: - Dependencies
    private let saveGameUseCase: SaveGameSessionUseCase
    private let connectionRepository: ConnectionRepositoryProtocol

    // MARK: - Initialization
    init(
        saveGameUseCase: SaveGameSessionUseCase,
        connectionRepository: ConnectionRepositoryProtocol
    ) {
        self.saveGameUseCase = saveGameUseCase
        self.connectionRepository = connectionRepository
        observeIncomingMessages()
    }

    // MARK: - Actions
    func startGame(topic: String) {
        currentTopic = topic
        gameState = .drawing
        countdown = 30
        startCountdown()
    }

    func submitDrawing(_ drawing: DrawingData) async {
        myDrawing = drawing
        gameState = .waitingForPartner

        let message = GameMessage.drawingSubmitted(drawing)
        try? await connectionRepository.sendMessage(message)
    }

    func saveSession() async throws {
        guard let myDrawing, let partnerDrawing else {
            throw GameSessionError.incompleteSession
        }

        let session = GameSession(
            partnerName: partnerName,
            topic: currentTopic,
            myDrawing: myDrawing,
            partnerDrawing: partnerDrawing
        )

        try await saveGameUseCase.execute(session)
    }

    // MARK: - Private Methods
    private func observeIncomingMessages() {
        Task { @MainActor in
            for await message in connectionRepository.observeMessages() {
                handleMessage(message)
            }
        }
    }

    @MainActor
    private func handleMessage(_ message: GameMessage) {
        switch message {
        case .drawingSubmitted(let drawing):
            partnerDrawing = drawing
            if myDrawing != nil {
                gameState = .showingResult
            }

        case .gameStarted(let topic):
            startGame(topic: topic)

        case .requestNewGame:
            resetGame()

        default:
            break
        }
    }

    private func startCountdown() {
        Task {
            while countdown > 0 && gameState == .drawing {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run {
                    countdown -= 1
                }
            }

            await MainActor.run {
                if gameState == .drawing {
                    gameState = .timeUp
                }
            }
        }
    }

    private func resetGame() {
        gameState = .waiting
        currentTopic = ""
        countdown = 30
        myDrawing = nil
        partnerDrawing = nil
    }
}
