//
//  AppCoordinator.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI
import Observation

/// 应用导航协调器
/// 管理整个应用的导航流程
@Observable
final class AppCoordinator {
    // MARK: - Navigation State
    var navigationPath = NavigationPath()
    var selectedTab: Tab = .pairing
    var isPresentingGame: Bool = false
    var isPresentingResult: Bool = false
    var currentGameSession: GameSession?

    // MARK: - Tab Definition
    enum Tab {
        case pairing
        case history
    }

    // MARK: - Navigation Actions

    /// 开始新游戏
    func startGame() {
        isPresentingGame = true
    }

    /// 显示游戏结果
    func showResult(session: GameSession) {
        currentGameSession = session
        isPresentingResult = true
    }

    /// 返回到配对界面
    func backToPairing() {
        isPresentingGame = false
        isPresentingResult = false
        currentGameSession = nil
        selectedTab = .pairing
    }

    /// 切换到历史记录
    func showHistory() {
        selectedTab = .history
    }

    /// 重新开始游戏
    func restartGame() {
        isPresentingResult = false
        currentGameSession = nil
        isPresentingGame = true
    }

    /// 从历史查看详情
    func showSessionDetail(session: GameSession) {
        navigationPath.append(session)
    }

    /// 返回
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// MARK: - Navigation Helpers
extension AppCoordinator {
    /// 清空导航栈
    func clearNavigationStack() {
        navigationPath = NavigationPath()
    }

    /// 完全重置导航状态
    func reset() {
        navigationPath = NavigationPath()
        selectedTab = .pairing
        isPresentingGame = false
        isPresentingResult = false
        currentGameSession = nil
    }
}
