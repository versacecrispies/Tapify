import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Core components

    private let settings = AppSettings()
    private var reader:   AccelerometerReader!
    private var detector: TapDetector!
    private var executor: ActionExecutor!

    // MARK: - UI

    private var statusItem:       NSStatusItem?
    private var windowController: MainWindowController?

    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app appears in Dock and Cmd+Tab with its icon
        NSApp.setActivationPolicy(.regular)

        // Build object graph
        reader   = AccelerometerReader()
        detector = TapDetector(reader: reader, settings: settings)
        executor = ActionExecutor(settings: settings)
        executor.bind(to: detector)

        // Menu bar status item
        setupStatusItem()

        // Main window — show it immediately on first launch
        windowController = MainWindowController(settings: settings, detector: detector)
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Re-show window when display wakes from sleep / user unlocks
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )

        // Start accelerometer after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.detector.start()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication,
                                        hasVisibleWindows flag: Bool) -> Bool {
        windowController?.toggle()
        return false
    }

    // MARK: - Status item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            if let img = NSImage(systemSymbolName: "waveform",
                                 accessibilityDescription: "Tapify") {
                img.isTemplate = true
                button.image   = img
            } else {
                // Fallback text if SF Symbol unavailable
                button.title = "K"
            }
            button.action = #selector(statusItemClicked)
            button.target = self
        }
    }

    @objc private func statusItemClicked() {
        if NSEvent.modifierFlags.contains(.option) {
            showMenu()
        } else {
            windowController?.toggle()
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        let toggleTitle = settings.isEnabled
            ? "Pause Knock Detection"
            : "Resume Knock Detection"
        menu.addItem(NSMenuItem(title: toggleTitle,
                                action: #selector(toggleEnabled),
                                keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Open Tapify…",
                                action: #selector(openMainWindow),
                                keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: "q"))

        for item in menu.items { item.target = self }
        statusItem?.popUpMenu(menu)
    }

    @objc private func toggleEnabled()  { settings.isEnabled.toggle() }
    @objc private func openMainWindow() { windowController?.toggle() }

    @objc private func systemDidWake() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.windowController?.showWindow(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
