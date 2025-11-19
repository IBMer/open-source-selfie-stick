//
//  MainTabView.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI

struct MainTabView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var coordinator = AppCoordinator()

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            // 配对 Tab
            pairingTab
                .tabItem {
                    Label("配对", systemImage: "link")
                }
                .tag(AppCoordinator.Tab.pairing)

            // 历史 Tab
            historyTab
                .tabItem {
                    Label("历史", systemImage: "clock")
                }
                .tag(AppCoordinator.Tab.history)
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.selectedTab)
        .environment(coordinator)
        .fullScreenCover(isPresented: $coordinator.isPresentingGame) {
            gameScreen
                .transition(.move(edge: .bottom))
        }
        .sheet(isPresented: $coordinator.isPresentingResult) {
            if let session = coordinator.currentGameSession {
                resultScreen(session: session)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    // MARK: - Tabs

    @ViewBuilder
    private var pairingTab: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            PairingView(viewModel: container.makePairingViewModel())
                .navigationDestination(for: GameSession.self) { session in
                    SessionDetailView(session: session)
                }
        }
    }

    @ViewBuilder
    private var historyTab: some View {
        NavigationStack {
            HistoryView(viewModel: container.makeHistoryViewModel())
                .navigationDestination(for: GameSession.self) { session in
                    SessionDetailView(session: session)
                }
        }
    }

    // MARK: - Full Screen Presentations

    @ViewBuilder
    private var gameScreen: some View {
        NavigationStack {
            GameView(viewModel: container.makeGameViewModel())
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("取消") {
                            coordinator.backToPairing()
                        }
                    }
                }
        }
    }

    @ViewBuilder
    private func resultScreen(session: GameSession) -> some View {
        NavigationStack {
            ResultView(viewModel: container.makeResultViewModel(session: session))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("完成") {
                            coordinator.backToPairing()
                        }
                    }
                }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}
