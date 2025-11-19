//
//  HistoryView.swift
//  IOO
//
//  Created by Vincent WANG on 2025/11/18.
//

import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel

    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(message: "加载历史记录...")
            } else if let error = viewModel.errorMessage {
                ErrorView(error: error) {
                    Task {
                        await viewModel.loadHistory()
                    }
                }
            } else if viewModel.gameSessions.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "还没有游戏记录",
                    message: "开始一局游戏吧！",
                    actionTitle: "开始游戏",
                    action: {
                        // TODO: Navigate to game
                    }
                )
            } else {
                historyList
            }
        }
        .navigationTitle("历史记录")
        .task {
            await viewModel.loadHistory()
        }
    }

    // MARK: - History List
    @ViewBuilder
    private var historyList: some View {
        List {
            ForEach(viewModel.gameSessions) { session in
                NavigationLink {
                    SessionDetailView(session: session)
                } label: {
                    SessionRowView(session: session)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .opacity
                ))
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        let session = viewModel.gameSessions[index]
                        await viewModel.deleteSession(id: session.id)
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.gameSessions)
        .refreshable {
            await viewModel.loadHistory()
        }
    }
}

// MARK: - Session Row View
struct SessionRowView: View {
    let session: GameSession

    var body: some View {
        HStack(spacing: 12) {
            // 缩略图
            if let uiImage = UIImage(data: session.myDrawing.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(session.topic)
                    .font(.headline)

                Text("与 \(session.partnerName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // 默契度（如果有）
            if let score = session.matchScore {
                VStack {
                    Text("\(score)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentColor)

                    Text("默契度")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Session Detail View
struct SessionDetailView: View {
    let session: GameSession
    @State private var isVisible: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 题目
                VStack(spacing: 8) {
                    Text("题目")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(session.topic)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -20)

                // 游戏信息
                infoSection
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)

                // 绘画对比
                drawingsSection
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
            }
            .padding()
        }
        .navigationTitle("游戏详情")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                isVisible = true
            }
        }
    }

    @ViewBuilder
    private var infoSection: some View {
        VStack(spacing: 12) {
            infoRow(label: "对手", value: session.partnerName)
            infoRow(label: "时间", value: session.createdAt.formatted(date: .long, time: .shortened))

            if let score = session.matchScore {
                infoRow(label: "默契度", value: "\(score)%")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    @ViewBuilder
    private var drawingsSection: some View {
        VStack(spacing: 16) {
            Text("作品对比")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 我的画
            drawingCard(title: "我的画", drawing: session.myDrawing)

            // 对方的画
            if let partnerDrawing = session.partnerDrawing {
                drawingCard(title: "\(session.partnerName) 的画", drawing: partnerDrawing)
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
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
