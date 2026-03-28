import Foundation

/// How long after the first tap the detector waits for additional taps
/// before committing the gesture.
enum TapSpeed: String, CaseIterable, Codable, Identifiable {
    case fast     = "Fast"
    case balanced = "Balanced"
    case slow     = "Slow"

    var id: String { rawValue }

    var windowDuration: TimeInterval {
        switch self {
        case .fast:     return 0.600
        case .balanced: return 0.900
        case .slow:     return 1.200
        }
    }

    var milliseconds: Int {
        Int(windowDuration * 1000)
    }

    var displayName: String {
        "\(rawValue) (\(milliseconds)ms)"
    }
}
