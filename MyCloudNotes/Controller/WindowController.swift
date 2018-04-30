import Cocoa

class WindowController: NSWindowController {
	
	///
	/// Adds an observer to control auto deminiaturize of main window if
	/// application becomes active.
	///
	override func windowDidLoad() {
		NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: NSApplication.didBecomeActiveNotification, object: nil)
	}
	
	///
	/// Remove observer.
	///
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	///
	/// Deminiaturizes the window.
	///
	@objc func applicationDidBecomeActive(_ notification: Notification) {
		if let window = window, window.isMiniaturized {
			window.deminiaturize(self)
		}
	}
}
