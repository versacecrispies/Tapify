import SwiftUI

/// Styled sensitivity slider with orange accent and live g-value readout.
struct SensitivitySlider: View {
    @Binding var value: Double

    private let range = 0.05...0.50
    private let step  = 0.01

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Sensitivity")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.primaryText)
                Spacer()
                Text(String(format: "%.2f g", value))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(Theme.accent)
            }

            Text("Higher = lighter taps, lower = firmer.")
                .font(.system(size: 12))
                .foregroundColor(Theme.secondaryText)

            Slider(value: $value, in: range, step: step)
                .accentColor(Theme.accent)
                .padding(.top, 2)
        }
    }
}
