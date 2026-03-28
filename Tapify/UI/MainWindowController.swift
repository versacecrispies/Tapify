import AppKit
import SwiftUI

final class MainWindowController: NSWindowController {

    convenience init(settings: AppSettings, detector: TapDetector) {
        let rootView = MainView(settings: settings, detector: detector)
        let hosting  = NSHostingView(rootView: rootView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0,
                                width:  Theme.windowWidth,
                                height: Theme.windowHeight),
            styleMask:   [.titled, .closable, .fullSizeContentView],
            backing:     .buffered,
            defer:       false
        )
        window.title                      = "Tapify"
        window.titlebarAppearsTransparent = true
        window.titleVisibility            = .hidden
        window.backgroundColor            = NSColor(Theme.background)
        window.isMovableByWindowBackground = true
        window.contentView                = hosting
        window.center()
        // Remember position between launches
        window.setFrameAutosaveName("MainWindow")

        self.init(window: window)
    }

    func toggle() {
        guard let window = window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
