import Foundation

/// All actions that can be assigned to a tap gesture.
enum ActionType: String, CaseIterable, Codable, Identifiable {
    case none              = "None"

    // Media
    case playPause         = "Play / Pause"
    case mute              = "Mute"

    // Volume
    case volumeUp          = "Volume Up"
    case volumeDown        = "Volume Down"

    // Screen / system
    case lockScreen        = "Lock Screen"
    case sleepMac          = "Sleep Mac"
    case screenshot        = "Screenshot with Crop"

    // Navigation
    case nextTab           = "Next Tab"
    case previousTab       = "Previous Tab"
    case nextDesktop       = "Next Desktop"
    case previousDesktop   = "Previous Desktop"
    case missionControl    = "Mission Control"
    case appSwitcher       = "App Switcher"

    // Apps
    case openApp           = "Open App..."
    case openFinder        = "Open Finder"
    case openTerminal      = "Open Terminal"

    // Editing
    case copy              = "Copy"
    case paste             = "Paste"
    case undo              = "Undo"
    case redo              = "Redo"

    // System UI
    case spotlight         = "Spotlight"
    case closeWindow       = "Close Window"

    // Custom
    case runShortcut       = "Run Shortcut..."
    case runCustomCommand  = "Run Custom Command..."

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .none:             return "minus.circle"
        case .playPause:        return "playpause.fill"
        case .mute:             return "speaker.slash.fill"
        case .volumeUp:         return "speaker.wave.3.fill"
        case .volumeDown:       return "speaker.wave.1.fill"
        case .lockScreen:       return "lock.fill"
        case .sleepMac:         return "moon.fill"
        case .screenshot:       return "camera.viewfinder"
        case .nextTab:          return "arrow.right.to.line"
        case .previousTab:      return "arrow.left.to.line"
        case .nextDesktop:      return "rectangle.righthalf.inset.filled.arrow.right"
        case .previousDesktop:  return "rectangle.lefthalf.inset.filled.arrow.left"
        case .missionControl:   return "rectangle.3.group.fill"
        case .appSwitcher:      return "square.grid.2x2.fill"
        case .openApp:          return "app.badge"
        case .openFinder:       return "folder.fill"
        case .openTerminal:     return "terminal.fill"
        case .copy:             return "doc.on.doc.fill"
        case .paste:            return "clipboard.fill"
        case .undo:             return "arrow.uturn.backward"
        case .redo:             return "arrow.uturn.forward"
        case .spotlight:        return "magnifyingglass"
        case .closeWindow:      return "xmark.rectangle.fill"
        case .runShortcut:      return "wand.and.stars"
        case .runCustomCommand: return "terminal"
        }
    }

    var shortName: String {
        switch self {
        case .none:             return "None"
        case .playPause:        return "Play/Pause"
        case .mute:             return "Mute"
        case .volumeUp:         return "Volume Up"
        case .volumeDown:       return "Volume Down"
        case .lockScreen:       return "Lock Screen"
        case .sleepMac:         return "Sleep Mac"
        case .screenshot:       return "Screenshot"
        case .nextTab:          return "Next Tab"
        case .previousTab:      return "Previous Tab"
        case .nextDesktop:      return "Next Desktop"
        case .previousDesktop:  return "Previous Desktop"
        case .missionControl:   return "Mission Control"
        case .appSwitcher:      return "App Switcher"
        case .openApp:          return "Open App"
        case .openFinder:       return "Open Finder"
        case .openTerminal:     return "Open Terminal"
        case .copy:             return "Copy"
        case .paste:            return "Paste"
        case .undo:             return "Undo"
        case .redo:             return "Redo"
        case .spotlight:        return "Spotlight"
        case .closeWindow:      return "Close Window"
        case .runShortcut:      return "Run Shortcut"
        case .runCustomCommand: return "Custom Command"
        }
    }
}
