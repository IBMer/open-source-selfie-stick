//
//  DrawingCanvasView.swift
//  IOO
//
//  Created on 2025-11-18.
//

import SwiftUI

/// 绘画画布视图
/// 支持触摸绘画、颜色选择、清空等功能
struct DrawingCanvasView: View {
    @State private var currentStrokes: [DrawingStroke] = []
    @State private var currentColor: Color = .black
    @State private var strokeWidth: Double = 3.0
    @State private var isDrawing: Bool = false

    let isEnabled: Bool
    let onDrawingComplete: (DrawingData) -> Void

    init(
        isEnabled: Bool = true,
        onDrawingComplete: @escaping (DrawingData) -> Void
    ) {
        self.isEnabled = isEnabled
        self.onDrawingComplete = onDrawingComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            // 画布区域
            canvas

            // 工具栏
            toolbar
        }
    }

    // MARK: - Canvas
    @ViewBuilder
    private var canvas: some View {
        Canvas { context, size in
            // 绘制所有笔触
            for stroke in currentStrokes {
                var path = Path()

                guard let firstPoint = stroke.points.first else { continue }
                path.move(to: firstPoint)

                for point in stroke.points.dropFirst() {
                    path.addLine(to: point)
                }

                context.stroke(
                    path,
                    with: .color(Color(hex: stroke.color)),
                    lineWidth: stroke.width
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Theme.canvasBackground)
        .border(Color.Theme.canvasBorder, width: 2)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard isEnabled else { return }

                    if !isDrawing {
                        // 开始新笔触
                        isDrawing = true
                        let newStroke = DrawingStroke(
                            points: [value.location],
                            color: currentColor.toHex(),
                            width: strokeWidth
                        )
                        currentStrokes.append(newStroke)
                    } else {
                        // 继续当前笔触
                        if var lastStroke = currentStrokes.last {
                            var points = lastStroke.points
                            points.append(value.location)
                            currentStrokes[currentStrokes.count - 1] = DrawingStroke(
                                points: points,
                                color: lastStroke.color,
                                width: lastStroke.width
                            )
                        }
                    }
                }
                .onEnded { _ in
                    isDrawing = false
                }
        )
        .disabled(!isEnabled)
    }

    // MARK: - Toolbar
    @ViewBuilder
    private var toolbar: some View {
        VStack(spacing: 12) {
            // 颜色选择
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Color.DrawingColors.all, id: \.self) { color in
                        colorButton(color)
                    }
                }
                .padding(.horizontal)
            }

            // 操作按钮
            HStack(spacing: 12) {
                // 清空画布
                Button {
                    clearCanvas()
                } label: {
                    Label("清空", systemImage: "trash")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)

                Spacer()

                // 完成绘画
                Button {
                    finishDrawing()
                } label: {
                    Label("完成", systemImage: "checkmark")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(currentStrokes.isEmpty ? Color.gray : Color.accentColor)
                .cornerRadius(8)
                .disabled(currentStrokes.isEmpty || !isEnabled)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Color Button
    @ViewBuilder
    private func colorButton(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: 40, height: 40)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .shadow(color: .black.opacity(0.2), radius: 2)
            )
            .overlay(
                Circle()
                    .stroke(Color.accentColor, lineWidth: currentColor == color ? 3 : 0)
            )
            .onTapGesture {
                currentColor = color
            }
    }

    // MARK: - Actions
    private func clearCanvas() {
        withAnimation {
            currentStrokes.removeAll()
        }
    }

    private func finishDrawing() {
        guard !currentStrokes.isEmpty else { return }

        // 将画布渲染为图片
        let renderer = ImageRenderer(content: renderableCanvas)
        renderer.scale = 3.0 // 高分辨率

        guard let image = renderer.uiImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }

        let drawingData = DrawingData(
            imageData: imageData,
            strokes: currentStrokes
        )

        onDrawingComplete(drawingData)
    }

    @ViewBuilder
    private var renderableCanvas: some View {
        Canvas { context, size in
            for stroke in currentStrokes {
                var path = Path()
                guard let firstPoint = stroke.points.first else { continue }
                path.move(to: firstPoint)
                for point in stroke.points.dropFirst() {
                    path.addLine(to: point)
                }
                context.stroke(
                    path,
                    with: .color(Color(hex: stroke.color)),
                    lineWidth: stroke.width
                )
            }
        }
        .frame(width: 400, height: 400)
        .background(Color.white)
    }
}
