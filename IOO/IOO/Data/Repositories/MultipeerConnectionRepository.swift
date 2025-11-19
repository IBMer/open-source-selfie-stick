//
//  MultipeerConnectionRepository.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation

/// MultipeerConnectivity 连接仓储实现
/// 桥接 ConnectionManager 和 Domain 层
final class MultipeerConnectionRepository: ConnectionRepositoryProtocol {
    private let connectionManager: ConnectionManager

    var connectionState: ConnectionState {
        connectionManager.connectionState
    }

    var connectedPartnerName: String? {
        connectionManager.connectedPartnerName
    }

    init(connectionManager: ConnectionManager = ConnectionManager()) {
        self.connectionManager = connectionManager
    }

    func startSearching() async {
        connectionManager.startSearching()
    }

    func stopSearching() async {
        connectionManager.stopSearching()
    }

    func sendMessage(_ message: GameMessage) async throws {
        try await connectionManager.sendMessage(message)
    }

    func observeMessages() -> AsyncStream<GameMessage> {
        connectionManager.observeMessages()
    }

    func disconnect() async {
        connectionManager.disconnect()
    }
}
