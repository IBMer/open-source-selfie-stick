//
//  ResultView.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI

struct ResultView: View {
    @State private var viewModel: ResultViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isVisible: Bool = false

    init(viewModel: ResultViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 标题
                header
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)

                // 题目
                topicSection
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)

                // 双人绘画对比
                drawingsComparison
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)

                // 操作按钮
                actionButtons
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
            }
            .padding()
        }
        .navigationTitle("游戏结果")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
        }
    }

    // MARK: - Header
    @ViewBuilder
    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
                .scaleEffect(isVisible ? 1 : 0.3)
                .rotationEffect(.degrees(isVisible ? 0 : 180))

            Text("完成！")
                .font(.largeTitle)
                .fontWeight(.bold)

            if let score = viewModel.session.matchScore {
                Text("默契度: \(score)%")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .opacity(isVisible ? 1 : 0)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Topic Section
    @ViewBuilder
    private var topicSection: some View {
        VStack(spacing: 8) {
            Text("题目")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(viewModel.session.topic)
                .font(.title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Drawings Comparison
    @ViewBuilder
    private var drawingsComparison: some View {
        VStack(spacing: 16) {
            Text("作品对比")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 自己的画
            drawingCard(
                title: "我的画",
                drawing: viewModel.session.myDrawing
            )

            // 对方的画
            if let partnerDrawing = viewModel.session.partnerDrawing {
                drawingCard(
                    title: "\(viewModel.session.partnerName) 的画",
                    drawing: partnerDrawing
                )
            }
        }
    }

    @ViewBuilder
    private func drawingCard(title: String, drawing: DrawingData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            if let uiImage = UIImage(data: drawing.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 2)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(Text("图片加载失败"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Action Buttons
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // 保存按钮
            if !viewModel.isSaved {
                PrimaryButton.primary(
                    "保存到历史记录",
                    isEnabled: !viewModel.isSaving
                ) {
                    Task {
                        await viewModel.saveSession()
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("已保存")
                        .foregroundStyle(.green)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            }

            // 再来一局
            PrimaryButton.secondary("再来一局") {
                // TODO: Start new game
                dismiss()
            }

            // 返回首页
            PrimaryButton.secondary("返回首页") {
                // TODO: Navigate to home
                dismiss()
            }
        }
        .padding(.vertical)
    }
}
