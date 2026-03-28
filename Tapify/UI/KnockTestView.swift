import SwiftUI

struct KnockTestView: View {
    @ObservedObject var detector: TapDetector
    @ObservedObject var settings: AppSettings

    @State private var displayedEvent: TapEvent?
    @State private var showLabel = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tap Test")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.primaryText)
                    Text("Detected gestures highlight below.")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText)
                }
                Spacer()
                // Badge showing actions are suppressed in this tab
                HStack(spacing: 4) {
                    Image(systemName: "bolt.slash.fill")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Actions paused")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(Theme.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Theme.accentSoft)
                .cornerRadius(6)
            }
            .padding(.horizontal, Theme.cardPadding)
            .padding(.top, Theme.cardPadding)

            // Large waveform
            WaveformView(detector: detector, threshold: settings.threshold)
                .frame(height: 160)
                .padding(.horizontal, Theme.cardPadding)

            // Gesture feedback overlay
            ZStack {
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.cornerRadius)
                            .stroke(showLabel ? Theme.accent : Theme.cardBorder,
                                    lineWidth: showLabel ? 1.5 : 1)
                    )

                if let event = displayedEvent, showLabel {
                    VStack(spacing: 6) {
                        Image(systemName: event.count.dotSymbol)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Theme.accent)
                        Text(event.count.label.uppercased())
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(Theme.primaryText)
                        Text(String(format: "Peak: %.3f g", event.peakAcceleration))
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(Theme.secondaryText)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    Text("Knock to test")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .frame(height: 110)
            .padding(.horizontal, Theme.cardPadding)
            .animation(.spring(response: 0.3), value: showLabel)

            // Tap count indicators
            Card {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(TapCount.allCases, id: \.rawValue) { count in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(displayedEvent?.count == count && showLabel
                                      ? Theme.accent : Theme.secondaryText.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.2), value: showLabel)

                            Text(count.label)
                                .font(.system(size: 13))
                                .foregroundColor(
                                    displayedEvent?.count == count && showLabel
                                    ? Theme.primaryText : Theme.secondaryText
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, Theme.cardPadding)

            Spacer()
        }
        .onReceive(detector.$lastEvent) { event in
            guard let event = event else { return }
            displayedEvent = event
            withAnimation { showLabel = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { showLabel = false }
            }
        }
    }
}
