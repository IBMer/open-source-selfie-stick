//
//  PairingViewModel.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation
import Observation

/// 配对界面 ViewModel
@Observable
final class PairingViewModel {
    // MARK: - State
    var connectionState: ConnectionState = .disconnected
    var connectedPartnerName: String?
    var isSearching: Bool = false

    // MARK: - Dependencies
    private let connectionRepository: ConnectionRepositoryProtocol

    // MARK: - Initialization
    init(connectionRepository: ConnectionRepositoryProtocol) {
        self.connectionRepository = connectionRepository
        observeConnectionState()
    }

    // MARK: - Actions
    func startPairing() async {
        isSearching = true
        await connectionRepository.startSearching()
    }

    func stopPairing() async {
        isSearching = false
        await connectionRepository.stopSearching()
    }

    func disconnect() async {
        await connectionRepository.disconnect()
    }

    // MARK: - Private Methods
    private func observeConnectionState() {
        Task {
            // Observe connection state changes
            // This will be implemented when we add state observation to repository
        }
    }
}
