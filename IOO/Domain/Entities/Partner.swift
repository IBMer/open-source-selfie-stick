//
//  Partner.swift
//  IOO
//
//  Created on 2025-11-18.
//

import Foundation

/// 配对伙伴模型
/// 记录常用的游戏伙伴
struct Partner: Identifiable, Sendable {
    let id: UUID
    let name: String
    let lastConnectedAt: Date
    let totalGames: Int

    init(
        id: UUID = UUID(),
        name: String,
        lastConnectedAt: Date = Date(),
        totalGames: Int = 0
    ) {
        self.id = id
        self.name = name
        self.lastConnectedAt = lastConnectedAt
        self.totalGames = totalGames
    }
}

// MARK: - Helper Methods
extension Partner {
    /// 创建新伙伴
    static func create(name: String) -> Partner {
        Partner(name: name, totalGames: 1)
    }

    /// 更新连接时间和游戏次数
    func updateConnection() -> Partner {
        Partner(
            id: id,
            name: name,
            lastConnectedAt: Date(),
            totalGames: totalGames + 1
        )
    }

    /// 格式化的最后连接时间
    var formattedLastConnected: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastConnectedAt, relativeTo: Date())
    }
}

// MARK: - Equatable
extension Partner: Equatable {
    static func == (lhs: Partner, rhs: Partner) -> Bool {
        lhs.id == rhs.id
    }
}
