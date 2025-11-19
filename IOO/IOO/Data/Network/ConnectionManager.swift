//
//  ConnectionManager.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//  Adapted from Open Source Selfie Stick project
//

import Foundation
import MultipeerConnectivity
import Observation

/// MultipeerConnectivity 连接管理器
/// 负责设备发现、配对和通信
@Observable
final class ConnectionManager: NSObject {
    // MARK: - Published State
    var connectionState: ConnectionState = .disconnected
    var connectedPartnerName: String?

    // MARK: - Private Properties
    private let serviceType = "ioo-game"  // Service type identifier
    private let myPeerId: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    private var messageContinuation: AsyncStream<GameMessage>.Continuation?
    private var session: MCSession

    // MARK: - Initialization
    override init() {
        self.myPeerId = MCPeerID(displayName: UIDevice.current.name)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: myPeerId,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        self.serviceBrowser = MCNearbyServiceBrowser(
            peer: myPeerId,
            serviceType: serviceType
        )
        self.session = MCSession(
            peer: myPeerId,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        super.init()

        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
    }

    // MARK: - Public Methods
    func startSearching() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
        connectionState = .searching
        print("🔍 Started searching for peers")
    }

    func stopSearching() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        print("⏹️ Stopped searching for peers")
    }

    func sendMessage(_ message: GameMessage) async throws {
        guard !session.connectedPeers.isEmpty else {
            throw AppError.peerDisconnected
        }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("📤 Sent message: \(message.description)")
        } catch is EncodingError {
            throw AppError.encodingFailed
        } catch {
            throw AppError.messageSendFailed
        }
    }

    func observeMessages() -> AsyncStream<GameMessage> {
        AsyncStream { continuation in
            self.messageContinuation = continuation
        }
    }

    func disconnect() {
        session.disconnect()
        connectionState = .disconnected
        connectedPartnerName = nil
        print("🔌 Disconnected")
    }

    deinit {
        stopSearching()
        disconnect()
        messageContinuation?.finish()
    }
}

// MARK: - MCSessionDelegate
extension ConnectionManager: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        Task { @MainActor in
            switch state {
            case .connected:
                connectionState = .connected
                connectedPartnerName = peerID.displayName
                print("✅ Connected to: \(peerID.displayName)")

            case .connecting:
                connectionState = .connecting
                print("⏳ Connecting to: \(peerID.displayName)")

            case .notConnected:
                connectionState = .disconnected
                connectedPartnerName = nil
                print("❌ Disconnected from: \(peerID.displayName)")

            @unknown default:
                break
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            do {
                let message = try JSONDecoder().decode(GameMessage.self, from: data)
                messageContinuation?.yield(message)
                print("📥 Received message: \(message.description) from \(peerID.displayName)")
            } catch let error as DecodingError {
                print("❌ Failed to decode message: \(error)")
                // 通知上层数据损坏
                connectionState = .error(AppError.decodingFailed.localizedDescription)
            } catch {
                print("❌ Unexpected error receiving message: \(error)")
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // Not implemented in Phase 1
    }

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // Will be implemented in Phase 3 for photo transfer
        print("📊 Started receiving resource: \(resourceName)")
    }

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // Will be implemented in Phase 3 for photo transfer
        if let error = error {
            print("❌ Error receiving resource: \(error)")
        } else {
            print("✅ Finished receiving resource: \(resourceName)")
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension ConnectionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        Task { @MainActor in
            let appError = AppError.connectionFailed(reason: error.localizedDescription)
            connectionState = .error(appError.localizedDescription)
            print("❌ Did not start advertising: \(error)")
        }
    }

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        print("📨 Received invitation from: \(peerID.displayName)")
        // Auto-accept invitation (can be made user-confirmable later)
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension ConnectionManager: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        Task { @MainActor in
            let appError = AppError.connectionFailed(reason: error.localizedDescription)
            connectionState = .error(appError.localizedDescription)
            print("❌ Did not start browsing: \(error)")
        }
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        print("🔍 Found peer: \(peerID.displayName)")
        // Auto-invite peer (can be made user-selectable later)
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        Task { @MainActor in
            // 如果当前连接的对等方丢失，更新状态
            if connectedPartnerName == peerID.displayName {
                connectionState = .error(AppError.connectionLost.localizedDescription)
            }
            print("📡 Lost peer: \(peerID.displayName)")
        }
    }
}
