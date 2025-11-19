//
//  ConnectionRepositoryProtocol.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import Foundation

/// 连接状态枚举
enum ConnectionState: Sendable, Equatable {
    case disconnected
    case searching
    case connecting
    case connected
    case error(String)
}

/// 设备连接仓储协议
/// 定义设备间连接和通信操作
protocol ConnectionRepositoryProtocol: Sendable {
    /// 当前连接状态
    var connectionState: ConnectionState { get }

    /// 已连接的伙伴名称
    var connectedPartnerName: String? { get }

    /// 开始搜索附近设备
    func startSearching() async

    /// 停止搜索
    func stopSearching() async

    /// 发送消息给连接的设备
    /// - Parameter message: 要发送的游戏消息
    func sendMessage(_ message: GameMessage) async throws

    /// 观察接收到的消息
    /// - Returns: 消息的异步流
    func observeMessages() -> AsyncStream<GameMessage>

    /// 断开连接
    func disconnect() async
}
