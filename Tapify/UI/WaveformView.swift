import SwiftUI

/// Live scrolling waveform that shows Z-axis delta from gravity baseline.
struct WaveformView: View {
    @ObservedObject var detector: TapDetector

    /// Number of samples kept in the rolling buffer
    private let capacity = 240

    @State private var samples: [Double] = Array(repeating: 0, count: 240)
    @State private var peaks:   [Bool]   = Array(repeating: false, count: 240)

    var threshold: Double

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.cardBorder, lineWidth: 1)
                )

            // Threshold guide line
            GeometryReader { geo in
                let yCenter = geo.size.height / 2
                let yThreshold = yCenter - CGFloat(threshold / 0.6) * (geo.size.height * 0.44)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: yThreshold))
                    p.addLine(to: CGPoint(x: geo.size.width, y: yThreshold))
                }
                .stroke(Theme.accent.opacity(0.30),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                Path { p in
                    p.move(to: CGPoint(x: 0, y: -yThreshold + geo.size.height))
                    p.addLine(to: CGPoint(x: geo.size.width, y: -yThreshold + geo.size.height))
                }
                .stroke(Theme.accent.opacity(0.30),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))

            // Waveform canvas
            TimelineView(.animation(minimumInterval: 1.0/30.0)) { _ in
                Canvas { ctx, size in
                    let count  = samples.count
                    let scaleY = size.height * 0.44 / 0.6   // 0.6g fills half-height
                    let midY   = size.height / 2.0
                    let stepX  = size.width / CGFloat(count - 1)

                    // Build waveform path
                    var path = Path()
                    for i in 0 ..< count {
                        let x = CGFloat(i) * stepX
                        let y = midY - CGFloat(samples[i]) * scaleY
                        if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else      { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    ctx.stroke(path,
                               with: .color(Theme.waveformLine),
                               style: StrokeStyle(lineWidth: 1.5,
                                                  lineCap: .round,
                                                  lineJoin: .round))

                    // Draw orange dots at peak positions
                    for i in 0 ..< count where peaks[i] {
                        let x = CGFloat(i) * stepX
                        let y = midY - CGFloat(samples[i]) * scaleY
                        let r = CGFloat(3)
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: x - r, y: y - r,
                                                   width: r*2, height: r*2)),
                            with: .color(Theme.waveformPeak)
                        )
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .onReceive(detector.$currentSample) { sample in
            let baseline = detector.currentBaseline
            let delta    = sample.z - baseline
            let isPeak   = abs(delta) >= threshold

            samples.append(delta)
            peaks.append(isPeak)
            if samples.count > capacity { samples.removeFirst() }
            if peaks.count   > capacity { peaks.removeFirst() }
        }
    }
}
