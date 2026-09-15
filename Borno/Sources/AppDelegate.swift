import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        WelcomeWindowController.shared.showWindow()
    }

    // Called when user clicks the app icon while it's already running
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WelcomeWindowController.shared.showWindow()
        return true
    }
}
