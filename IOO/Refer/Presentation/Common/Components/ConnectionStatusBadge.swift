//
//  ConnectionStatusBadge.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

/// 连接状态标识组件
/// 显示当前设备连接状态
struct ConnectionStatusBadge: View {
    let state: ConnectionState

    var body: some View {
        HStack(spacing: 8) {
            statusIndicator
            statusText
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(16)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch state {
        case .disconnected:
            Image(systemName: "circle.fill")
                .font(.system(size: 8))

        case .searching:
            ProgressView()
                .scaleEffect(0.7)

        case .connecting:
            ProgressView()
                .scaleEffect(0.7)

        case .connected:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 12))

        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 12))
        }
    }

    @ViewBuilder
    private var statusText: some View {
        switch state {
        case .disconnected:
            Text("未连接")
        case .searching:
            Text("搜索中")
        case .connecting:
            Text("连接中")
        case .connected:
            Text("已连接")
        case .error:
            Text("连接失败")
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .disconnected:
            return Color.gray.opacity(0.2)
        case .searching, .connecting:
            return Color.blue.opacity(0.2)
        case .connected:
            return Color.green.opacity(0.2)
        case .error:
            return Color.red.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch state {
        case .disconnected:
            return .gray
        case .searching, .connecting:
            return .blue
        case .connected:
            return .green
        case .error:
            return .red
        }
    }
}
