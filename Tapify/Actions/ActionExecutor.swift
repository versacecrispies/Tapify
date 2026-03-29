import Foundation
import AppKit
import CoreAudio
import AudioToolbox
import CoreGraphics
import Combine

/**
 ActionExecutor

 Listens for TapEvents via Combine and executes the corresponding
 macOS action configured in AppSettings.
 */
final class ActionExecutor: ObservableObject {

    private let settings: AppSettings
    private let screenshotCoordinator: ScreenshotCropCoordinator
    private var cancellables = Set<AnyCancellable>()

    init(settings: AppSettings) {
        self.settings = settings
        self.screenshotCoordinator = ScreenshotCropCoordinator()
    }

    func bind(to detector: TapDetector) {
        detector.$lastEvent
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handle(event)
            }
            .store(in: &cancellables)
    }

    // MARK: - Dispatch

    func handle(_ event: TapEvent) {
        guard !settings.isTestMode else { return }
        let action = settings.action(for: event.count)
        execute(action)
    }

    func execute(_ action: ActionType) {
        switch action {
        case .none:             break
        case .playPause:        triggerPlayPause()
        case .mute:             triggerMute()
        case .volumeUp:         adjustVolume(by: +0.07)
        case .volumeDown:       adjustVolume(by: -0.07)
        case .lockScreen:       triggerLockScreen()
        case .sleepMac:         triggerSleepMac()
        case .screenshot:       screenshotCoordinator.beginCrop()
        case .nextTab:          sendKey(48, flags: .maskControl)
        case .previousTab:      sendKey(48, flags: [.maskControl, .maskShift])
        case .nextDesktop:      sendKey(124, flags: .maskControl)
        case .previousDesktop:  sendKey(123, flags: .maskControl)
        case .missionControl:   sendKey(126, flags: .maskControl)
        case .appSwitcher:      sendKey(48, flags: .maskCommand)
        case .openApp:          triggerOpenApp()
        case .openFinder:       triggerOpenFinder()
        case .openTerminal:     triggerOpenTerminal()
        case .copy:             sendKey(8, flags: .maskCommand)
        case .paste:            sendKey(9, flags: .maskCommand)
        case .undo:             sendKey(6, flags: .maskCommand)
        case .redo:             sendKey(6, flags: [.maskCommand, .maskShift])
        case .spotlight:        sendKey(49, flags: .maskCommand)
        case .closeWindow:      sendKey(13, flags: .maskCommand)
        case .runShortcut:      triggerRunShortcut()
        case .runCustomCommand: triggerRunCustomCommand()
        }
    }

    // MARK: - Keyboard helper

    private func sendKey(_ key: CGKeyCode, flags: CGEventFlags = []) {
        guard let src = CGEventSource(stateID: .hidSystemState) else { return }
        let down = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: true)
        let up   = CGEvent(keyboardEventSource: src, virtualKey: key, keyDown: false)
        down?.flags = flags
        up?.flags   = flags
        down?.post(tap: .cgSessionEventTap)
        up?.post(tap: .cgSessionEventTap)
    }

    // MARK: - Media

    private func triggerPlayPause() {
        func sendMediaKey(keyDown: Bool) {
            let event = NSEvent.otherEvent(
                with: .systemDefined,
                location: .zero,
                modifierFlags: keyDown ? .init(rawValue: 0xa00) : .init(rawValue: 0xb00),
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: 8,
                data1: (16 << 16) | ((keyDown ? 0xa : 0xb) << 8),
                data2: -1
            )
            event?.cgEvent?.post(tap: .cgSessionEventTap)
        }
        sendMediaKey(keyDown: true)
        sendMediaKey(keyDown: false)
    }

    // MARK: - System

    private func triggerLockScreen() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments  = ["displaysleepnow"]
        try? task.run()
    }

    private func triggerSleepMac() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments  = ["sleepnow"]
        try? task.run()
    }

    // MARK: - Apps

    private func triggerOpenApp() {
        guard let url = settings.openAppURL else {
            NSLog("[Tapify] Open App action: no app selected.")
            return
        }
        NSWorkspace.shared.openApplication(
            at: url,
            configuration: NSWorkspace.OpenConfiguration()
        ) { _, error in
            if let error = error {
                NSLog("[Tapify] Open App failed: %@", error.localizedDescription)
            }
        }
    }

    private func triggerOpenFinder() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app"))
    }

    private func triggerOpenTerminal() {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/Utilities/Terminal.app"))
    }

    // MARK: - Custom

    private func triggerRunShortcut() {
        let name = settings.shortcutName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else {
            NSLog("[Tapify] Run Shortcut: no shortcut name configured.")
            return
        }
        let task = Process()
        task.launchPath = "/usr/bin/shortcuts"
        task.arguments  = ["run", name]
        try? task.run()
    }

    private func triggerRunCustomCommand() {
        let cmd = settings.customCommand.trimmingCharacters(in: .whitespaces)
        guard !cmd.isEmpty else {
            NSLog("[Tapify] Run Custom Command: no command configured.")
            return
        }
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments  = ["-c", cmd]
        try? task.run()
    }

    // MARK: - Volume (CoreAudio)

    private func adjustVolume(by delta: Float) {
        var defaultOutput = AudioDeviceID(kAudioObjectUnknown)
        var propertySize  = UInt32(MemoryLayout<AudioDeviceID>.size)

        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope:    kAudioObjectPropertyScopeGlobal,
            mElement:  kAudioObjectPropertyElementMain
        )

        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                         &addr,
                                         0, nil,
                                         &propertySize,
                                         &defaultOutput) == noErr,
              defaultOutput != kAudioObjectUnknown else { return }

        var volumeAddr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope:    kAudioDevicePropertyScopeOutput,
            mElement:  kAudioObjectPropertyElementMain
        )

        var volume: Float32 = 0.5
        var volSize = UInt32(MemoryLayout<Float32>.size)

        guard AudioObjectGetPropertyData(defaultOutput,
                                         &volumeAddr,
                                         0, nil,
                                         &volSize,
                                         &volume) == noErr else { return }

        volume = max(0.0, min(1.0, volume + delta))
        AudioObjectSetPropertyData(defaultOutput,
                                   &volumeAddr,
                                   0, nil,
                                   volSize,
                                   &volume)
    }

    private func triggerMute() {
        var defaultOutput = AudioDeviceID(kAudioObjectUnknown)
        var propertySize  = UInt32(MemoryLayout<AudioDeviceID>.size)

        var addr = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope:    kAudioObjectPropertyScopeGlobal,
            mElement:  kAudioObjectPropertyElementMain
        )

        guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject),
                                         &addr,
                                         0, nil,
                                         &propertySize,
                                         &defaultOutput) == noErr,
              defaultOutput != kAudioObjectUnknown else { return }

        var muteAddr = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope:    kAudioDevicePropertyScopeOutput,
            mElement:  kAudioObjectPropertyElementMain
        )

        var muted: UInt32 = 0
        var muteSize = UInt32(MemoryLayout<UInt32>.size)

        guard AudioObjectGetPropertyData(defaultOutput,
                                         &muteAddr,
                                         0, nil,
                                         &muteSize,
                                         &muted) == noErr else { return }

        muted = muted == 0 ? 1 : 0
        AudioObjectSetPropertyData(defaultOutput,
                                   &muteAddr,
                                   0, nil,
                                   muteSize,
                                   &muted)
    }
}
