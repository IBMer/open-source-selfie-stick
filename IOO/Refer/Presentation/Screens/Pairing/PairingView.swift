//
//  PairingView.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

struct PairingView: View {
    @State private var viewModel: PairingViewModel

    init(viewModel: PairingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 24) {
            // Logo/Title
            VStack(spacing: 8) {
                Text("IOO")
                    .font(.system(size: 60, weight: .bold))
                Text("找个人一起玩")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 60)

            Spacer()

            // Connection Status
            connectionStatusView

            Spacer()

            // Action Buttons
            actionButtons
                .padding(.bottom, 40)
        }
        .padding()
        .navigationTitle("配对")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    @ViewBuilder
    private var connectionStatusView: some View {
        VStack(spacing: 16) {
            switch viewModel.connectionState {
            case .disconnected:
                Image(systemName: "link.badge.plus")
                    .font(.system(size: 80))
                    .foregroundStyle(.gray)
                    .transition(.scale.combined(with: .opacity))
                Text("未连接")
                    .font(.title2)
                    .transition(.opacity)

            case .searching:
                ProgressView()
                    .scaleEffect(2)
                    .transition(.scale.combined(with: .opacity))
                Text("搜索中...")
                    .font(.title3)
                    .transition(.opacity)

            case .connecting:
                ProgressView()
                    .scaleEffect(2)
                    .transition(.scale.combined(with: .opacity))
                Text("连接中...")
                    .font(.title3)
                    .transition(.opacity)

            case .connected:
                Image(systemName: "link.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
                    .symbolEffect(.bounce, value: viewModel.connectionState)
                if let partnerName = viewModel.connectedPartnerName {
                    Text("已连接到")
                        .font(.title3)
                        .transition(.opacity)
                    Text(partnerName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .transition(.scale.combined(with: .opacity))
                }

            case .error(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)
                    .transition(.scale.combined(with: .opacity))
                    .symbolEffect(.pulse, value: viewModel.connectionState)
                Text("连接失败")
                    .font(.title2)
                    .transition(.opacity)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.connectionState)
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if viewModel.connectionState == .connected {
                // TODO: Navigate to Game Screen
                Button {
                    // Navigate to game
                } label: {
                    Text("开始游戏")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .buttonStyle(.plain)

                Button {
                    Task {
                        await viewModel.disconnect()
                    }
                } label: {
                    Text("断开连接")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .buttonStyle(.plain)
            } else {
                if viewModel.isSearching {
                    Button {
                        Task {
                            await viewModel.stopPairing()
                        }
                    } label: {
                        Text("停止搜索")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .buttonStyle(.plain)
                } else {
                    Button {
                        Task {
                            await viewModel.startPairing()
                        }
                    } label: {
                        Text("开始配对")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .transition(.scale.combined(with: .opacity))
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.connectionState)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isSearching)
    }
}
