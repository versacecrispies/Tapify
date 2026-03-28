import Foundation
import AppKit
import CoreAudio
import AudioToolbox
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
        case .none:        break
        case .playPause:   triggerPlayPause()
        case .lockScreen:  triggerLockScreen()
        case .screenshot:  screenshotCoordinator.beginCrop()
        case .openApp:     triggerOpenApp()
        case .volumeUp:    adjustVolume(by: +0.07)
        case .volumeDown:  adjustVolume(by: -0.07)
        }
    }

    // MARK: - Action Implementations

    private func triggerPlayPause() {
        // Simulate the media Play/Pause key (NX_KEYTYPE_PLAY = 16)
        // using NSEvent system-defined events — the most reliable cross-app method.
        func sendMediaKey(keyDown: Bool) {
            let event = NSEvent.otherEvent(
                with: .systemDefined,
                location: .zero,
                modifierFlags: keyDown ? .init(rawValue: 0xa00) : .init(rawValue: 0xb00),
                timestamp: 0,
                windowNumber: 0,
                context: nil,
                subtype: 8,           // NX_SUBTYPE_AUX_CONTROL_BUTTONS
                data1: (16 << 16) | ((keyDown ? 0xa : 0xb) << 8),
                data2: -1
            )
            event?.cgEvent?.post(tap: .cgSessionEventTap)
        }
        sendMediaKey(keyDown: true)
        sendMediaKey(keyDown: false)
    }

    private func triggerLockScreen() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments  = ["displaysleepnow"]
        try? task.run()
    }

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
}
