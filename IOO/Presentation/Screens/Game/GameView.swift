//
//  GameView.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

struct GameView: View {
    @State private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            // 主内容
            mainContent

            // 等待对方的遮罩
            if viewModel.gameState == .waitingForPartner {
                waitingOverlay
            }
        }
        .navigationTitle("画画猜猜")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.gameState != .waiting)
        .toolbar {
            if viewModel.gameState == .drawing || viewModel.gameState == .timeUp {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("退出") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            startNewGame()
        }
    }

    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.gameState {
        case .waiting:
            waitingView

        case .drawing, .timeUp:
            drawingView

        case .waitingForPartner:
            drawingView // 继续显示画布，但禁用

        case .showingResult:
            resultPlaceholder
        }
    }

    // MARK: - Waiting View
    @ViewBuilder
    private var waitingView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accentColor)

            Text("准备开始游戏")
                .font(.title2)
                .fontWeight(.semibold)

            Text("等待游戏开始...")
                .foregroundStyle(.secondary)

            Spacer()

            PrimaryButton.primary("开始游戏") {
                startNewGame()
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Drawing View
    @ViewBuilder
    private var drawingView: some View {
        VStack(spacing: 0) {
            // 题目头部
            TopicHeaderView(
                topic: viewModel.currentTopic,
                countdown: viewModel.countdown
            )

            // 绘画画布
            DrawingCanvasView(
                isEnabled: viewModel.gameState == .drawing,
                onDrawingComplete: { drawing in
                    Task {
                        await viewModel.submitDrawing(drawing)
                    }
                }
            )
        }
    }

    // MARK: - Waiting Overlay
    @ViewBuilder
    private var waitingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)

                Text("等待对方完成绘画...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
    }

    // MARK: - Result Placeholder
    @ViewBuilder
    private var resultPlaceholder: some View {
        VStack {
            Text("游戏完成！")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("跳转到结果页面...")
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .onAppear {
            // TODO: Navigate to ResultView
            // 这里应该导航到 ResultView，显示对比结果
        }
    }

    // MARK: - Actions
    private func startNewGame() {
        // 生成题目
        let generator = TopicGenerator.default
        if let topic = generator.randomTopic() {
            viewModel.startGame(topic: topic.text)
        }
    }
}
