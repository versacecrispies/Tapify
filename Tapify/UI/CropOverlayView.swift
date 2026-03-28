import SwiftUI
import AppKit

/// Full-screen transparent overlay for crop selection.
/// Installed in a borderless .screenSaver-level NSWindow by ScreenshotCropCoordinator.
struct CropOverlayView: View {
    let onCropSelected: (CGRect) -> Void
    let onCancel: () -> Void

    @State private var startPoint:   CGPoint = .zero
    @State private var currentPoint: CGPoint = .zero
    @State private var isDragging:   Bool    = false

    private var selectionRect: CGRect {
        CGRect(
            x:      min(startPoint.x,   currentPoint.x),
            y:      min(startPoint.y,   currentPoint.y),
            width:  abs(currentPoint.x  - startPoint.x),
            height: abs(currentPoint.y  - startPoint.y)
        )
    }

    var body: some View {
        ZStack {
            // Dark scrim over whole screen
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            if isDragging && selectionRect.width > 4 && selectionRect.height > 4 {
                // Punch-through (clear) rect using blendMode
                Rectangle()
                    .fill(Color.clear)
                    .frame(width:  selectionRect.width,
                           height: selectionRect.height)
                    .overlay(
                        Rectangle()
                            .stroke(Theme.accent, lineWidth: 2)
                    )
                    .overlay(
                        // Corner handles
                        ZStack {
                            cornerHandle(at: .topLeft,     rect: selectionRect)
                            cornerHandle(at: .topRight,    rect: selectionRect)
                            cornerHandle(at: .bottomLeft,  rect: selectionRect)
                            cornerHandle(at: .bottomRight, rect: selectionRect)
                        }
                    )
                    .position(x: selectionRect.midX, y: selectionRect.midY)
                    .blendMode(.destinationOut)

                // Size label
                Text("\(Int(selectionRect.width)) × \(Int(selectionRect.height))")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(Theme.primaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.85))
                    .cornerRadius(5)
                    .position(
                        x: selectionRect.midX,
                        y: max(selectionRect.minY - 22, 16)
                    )
            }

            // Instructions when not dragging
            if !isDragging {
                VStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 36))
                        .foregroundColor(Theme.accent)
                    Text("Drag to select a region")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Press Esc to cancel")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .compositingGroup()
        .gesture(
            DragGesture(minimumDistance: 4, coordinateSpace: .local)
                .onChanged { value in
                    if !isDragging { isDragging = true }
                    startPoint   = value.startLocation
                    currentPoint = value.location
                }
                .onEnded { _ in
                    let rect = selectionRect
                    if rect.width > 10 && rect.height > 10 {
                        onCropSelected(rect)
                    } else {
                        onCancel()
                    }
                }
        )
        // Invisible escape-key button (works on macOS 13+)
        .background(
            Button("") { onCancel() }
                .keyboardShortcut(.escape, modifiers: [])
                .opacity(0)
        )
    }

    private enum Corner { case topLeft, topRight, bottomLeft, bottomRight }

    @ViewBuilder
    private func cornerHandle(at corner: Corner, rect: CGRect) -> some View {
        let size: CGFloat = 8
        let color = Theme.accent
        let offset: CGFloat = size / 2

        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .position(cornerPosition(corner, rect: rect, offset: offset))
    }

    private func cornerPosition(_ corner: Corner, rect: CGRect, offset: CGFloat) -> CGPoint {
        switch corner {
        case .topLeft:     return CGPoint(x: -rect.width/2, y: -rect.height/2)
        case .topRight:    return CGPoint(x:  rect.width/2, y: -rect.height/2)
        case .bottomLeft:  return CGPoint(x: -rect.width/2, y:  rect.height/2)
        case .bottomRight: return CGPoint(x:  rect.width/2, y:  rect.height/2)
        }
    }
}
