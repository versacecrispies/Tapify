import Foundation

/// How many taps were detected in a gesture window.
enum TapCount: Int, Codable, CaseIterable {
    case single = 1
    case double = 2
    case triple = 3

    var label: String {
        switch self {
        case .single: return "Single Tap"
        case .double: return "Double Tap"
        case .triple: return "Triple Tap"
        }
    }

    var dotSymbol: String {
        switch self {
        case .single: return "1.circle.fill"
        case .double: return "2.circle.fill"
        case .triple: return "3.circle.fill"
        }
    }
}

/// A completed tap gesture ready to be dispatched to an action.
struct TapEvent {
    let count: TapCount
    let timestamp: Date
    let peakAcceleration: Double   // peak delta-g value detected during the gesture
}
