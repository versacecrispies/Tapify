import SwiftUI

@main
struct TapifyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Window management is handled entirely by AppDelegate / MainWindowController.
        // We use Settings scene as an empty placeholder so SwiftUI doesn't create
        // its own window, keeping the app a pure menu-bar app.
        Settings {
            EmptyView()
        }
    }
}
