import AppKit

/**
 ScreenshotCropCoordinator

 Uses macOS's built-in interactive screencapture (-i) which shows
 the native crosshair selection UI. The user drags to select a region,
 presses Escape to cancel — all handled natively by screencapture itself.
 The result is saved to ~/Pictures and opened in Preview.
 */
final class ScreenshotCropCoordinator {

    private var activeTask: Process?

    func beginCrop() {
        // Don't start a second capture if one is already running
        guard activeTask == nil else { return }

        let outputURL = outputFileURL()

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        // -i  interactive selection mode (crosshair drag-to-select, Esc to cancel)
        // -s  force area-selection mode (skip the window-click step)
        task.arguments = ["-i", "-s", outputURL.path]

        task.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                self?.activeTask = nil
                // Only open if the user actually made a selection (file was created)
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    NSWorkspace.shared.open(outputURL)
                }
            }
        }

        do {
            try task.run()
            activeTask = task
        } catch {
            NSLog("[Tapify] screencapture failed to launch: %@",
                  error.localizedDescription)
            activeTask = nil
        }
    }

    private func outputFileURL() -> URL {
        let pictures = FileManager.default
            .urls(for: .picturesDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let name = "KnockShot_\(formatter.string(from: Date())).png"
        return pictures.appendingPathComponent(name)
    }
}
