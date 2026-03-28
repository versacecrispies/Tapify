import SwiftUI

struct DashboardView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var detector: TapDetector

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tap Test")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.primaryText)
                    Text("Tap the chassis or closed lid")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText)
                }

                // Live waveform
                WaveformView(detector: detector, threshold: settings.threshold)
                    .frame(height: 120)

                // Sensitivity
                Card {
                    SensitivitySlider(value: $settings.threshold)
                }

                // Tap Speed
                Card {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tap Speed")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.primaryText)
                        Text("How quickly taps must occur.")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.secondaryText)

                        Picker("", selection: $settings.tapSpeed) {
                            ForEach(TapSpeed.allCases) { speed in
                                Text(speed.displayName).tag(speed)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(Theme.primaryText)
                        .background(Theme.surfaceHover)
                        .cornerRadius(6)
                        .frame(maxWidth: 200)
                    }
                }

                // Enable toggle
                Card {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enabled")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.primaryText)
                            Text("Listen for tap gestures")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.secondaryText)
                        }
                        Spacer()
                        Toggle("", isOn: $settings.isEnabled)
                            .toggleStyle(.switch)
                            .accentColor(Theme.accent)
                            .labelsHidden()
                    }
                }

                // Status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(detector.isActive && settings.isEnabled
                              ? Theme.accent : Theme.secondaryText)
                        .frame(width: 7, height: 7)
                    Text(detector.isActive
                         ? (settings.isEnabled ? "Listening for taps" : "Paused")
                         : "Accelerometer not found")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.secondaryText)
                }
                .padding(.top, 2)

                Spacer(minLength: 8)
            }
            .padding(Theme.cardPadding)
        }
    }
}

// MARK: - Card container

struct Card<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding(Theme.cardPadding)
            .background(Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
            .cornerRadius(Theme.cornerRadius)
    }
}
