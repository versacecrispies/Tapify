import Foundation
import Combine

/**
 TapDetector

 Wraps AccelerometerReader and runs a state machine that turns raw
 accelerometer samples into TapEvent values (single / double / triple tap).

 Algorithm:
  1. Maintain a slow exponential moving average (EMA) of Z-axis as the gravity
     baseline.  Alpha = 0.005 → ~20-second time constant.  This tracks slow
     tilts without reacting to fast transients.
  2. delta = |sample.z - baseline|.  A tap appears as a sharp spike in delta.
  3. When delta >= threshold (configurable, 0.05–0.50 g) and not in refractory:
       • Increment pendingTaps
       • Enter refractory mode for 150 ms to suppress mechanical echo/ringing
       • (Re)schedule the window timer for tapSpeed.windowDuration
  4. When the window timer fires with no new tap: commit the gesture.
  5. Committed gesture: clamp pendingTaps to 1–3, publish TapEvent on main.

 Thread-safety: samples arrive on the HID background thread; all state mutation
 runs on a dedicated serial DispatchQueue.  UI updates are dispatched to main.
 */
final class TapDetector: ObservableObject {

    // MARK: - Published state (main thread)

    /// The most recently detected event.  Cleared back to nil after 2 seconds.
    @Published var lastEvent: TapEvent?

    /// The latest raw sample, published for the waveform view.
    @Published var currentSample: AccelSample = AccelSample(x: 0, y: 0, z: 1, timestamp: 0)

    /// Whether the detector is actively processing samples.
    @Published var isActive: Bool = false

    /// Current gravity baseline (published for waveform display).
    @Published private(set) var currentBaseline: Double = 1.0

    // MARK: - Dependencies

    let reader: AccelerometerReader
    var settings: AppSettings

    // MARK: - Private state (detection queue)

    private let detectionQueue = DispatchQueue(label: "com.tapify.detection",
                                               qos: .userInteractive)
    private var baseline: Double = 1.0          // gravity EMA (~1g at rest)
    private var pendingTaps: Int = 0
    private var recentPeak: Double = 0.0
    private var inRefractory: Bool = false
    private var windowTimer: DispatchWorkItem?

    private let refractoryDuration: TimeInterval = 0.15  // seconds

    /// Number of samples received so far — used for warmup calibration.
    private var sampleCount: Int = 0
    /// Samples needed before detection begins (~3 seconds at 100Hz).
    private let warmupSamples: Int = 300
    /// Whether the baseline has been seeded from a real sample.
    private var baselineSeeded: Bool = false

    // MARK: - Init

    init(reader: AccelerometerReader, settings: AppSettings) {
        self.reader   = reader
        self.settings = settings
    }

    // MARK: - Lifecycle

    func start() {
        reader.sampleHandler = { [weak self] sample in
            self?.processSample(sample)
        }
        reader.start()
        DispatchQueue.main.async { self.isActive = true }
    }

    func stop() {
        reader.stop()
        reader.sampleHandler = nil
        DispatchQueue.main.async { self.isActive = false }
    }

    // MARK: - Core detection

    private func processSample(_ sample: AccelSample) {
        // Publish for UI on main (throttle is fine — Canvas redraws at ~30fps)
        DispatchQueue.main.async { self.currentSample = sample }

        detectionQueue.async { [weak self] in
            guard let self = self, self.settings.isEnabled else { return }

            self.sampleCount += 1

            // Seed baseline from first real sample to avoid startup false positives
            if !self.baselineSeeded {
                self.baseline       = sample.z
                self.baselineSeeded = true
            }

            // 1. Update slow baseline (gravity tracking)
            self.baseline = 0.995 * self.baseline + 0.005 * sample.z
            let snap = self.baseline
            DispatchQueue.main.async { self.currentBaseline = snap }

            // 2. Skip detection during warmup (first ~3 seconds)
            guard self.sampleCount > self.warmupSamples else { return }

            // 3. Delta from baseline
            let delta = abs(sample.z - self.baseline)

            // 4. Refractory guard
            guard !self.inRefractory else { return }

            // 5. Threshold check
            guard delta >= self.settings.threshold else { return }

            // --- TAP DETECTED ---
            self.recentPeak = max(self.recentPeak, delta)
            self.pendingTaps += 1
            self.inRefractory = true

            // Exit refractory after 150 ms
            self.detectionQueue.asyncAfter(deadline: .now() + self.refractoryDuration) {
                self.inRefractory = false
            }

            // (Re)start the gesture window timer
            self.rescheduleWindowTimer()
        }
    }

    private func rescheduleWindowTimer() {
        windowTimer?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.commitGesture()
        }
        windowTimer = item
        detectionQueue.asyncAfter(
            deadline: .now() + settings.tapSpeed.windowDuration,
            execute: item
        )
    }

    private func commitGesture() {
        let count   = min(pendingTaps, 3)
        let peak    = recentPeak
        pendingTaps = 0
        recentPeak  = 0.0
        windowTimer = nil

        guard let tapCount = TapCount(rawValue: count) else { return }
        let event = TapEvent(count: tapCount,
                               timestamp: Date(),
                               peakAcceleration: peak)

        DispatchQueue.main.async {
            self.lastEvent = event
            // Auto-clear the event label after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.lastEvent?.timestamp == event.timestamp {
                    self.lastEvent = nil
                }
            }
        }
    }
}
