import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register Apple Event handler so clicking the app in Spotlight/Finder
        // will open the Welcome/Dashboard window even when running as an Input Method
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleOpenAppEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kCoreEventClass),
            andEventID: AEEventID(kAEOpenApplication)
        )
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleOpenAppEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kCoreEventClass),
            andEventID: AEEventID(kAEReopenApplication)
        )

        WelcomeWindowController.shared.showWindow()
    }

    @objc func handleOpenAppEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        WelcomeWindowController.shared.showWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        WelcomeWindowController.shared.showWindow()
        return true
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        WelcomeWindowController.shared.showWindow()
        return true
    }
}
