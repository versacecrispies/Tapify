import Foundation

/// All actions that can be assigned to a tap gesture.
enum ActionType: String, CaseIterable, Codable, Identifiable {
    case none        = "None"
    case playPause   = "Play / Pause"
    case lockScreen  = "Lock Screen"
    case screenshot  = "Screenshot with Crop"
    case openApp     = "Open App..."
    case volumeUp    = "Volume Up"
    case volumeDown  = "Volume Down"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .none:       return "minus.circle"
        case .playPause:  return "playpause.fill"
        case .lockScreen: return "lock.fill"
        case .screenshot: return "camera.viewfinder"
        case .openApp:    return "app.badge"
        case .volumeUp:   return "speaker.wave.3.fill"
        case .volumeDown: return "speaker.wave.1.fill"
        }
    }

    var shortName: String {
        switch self {
        case .none:       return "None"
        case .playPause:  return "Play/Pause"
        case .lockScreen: return "Lock Screen"
        case .screenshot: return "Screenshot"
        case .openApp:    return "Open App"
        case .volumeUp:   return "Volume Up"
        case .volumeDown: return "Volume Down"
        }
    }
}
