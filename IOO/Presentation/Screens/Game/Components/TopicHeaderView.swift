//
//  TopicHeaderView.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

/// 题目头部视图
/// 显示当前题目和倒计时
struct TopicHeaderView: View {
    let topic: String
    let countdown: Int

    var body: some View {
        VStack(spacing: 12) {
            // 题目
            Text("画出这个：")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(topic)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("绘画题目：\(topic)")

            // 倒计时
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.callout)
                    .accessibilityHidden(true)

                Text("\(countdown)秒")
                    .font(.headline)
                    .monospacedDigit()
            }
            .foregroundStyle(countdown <= 10 ? .red : .secondary)
            .animation(.easeInOut, value: countdown)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("剩余时间")
            .accessibilityValue("\(countdown) 秒")
            .accessibilityHint(countdown <= 10 ? "时间即将用尽" : "")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
    }
}
