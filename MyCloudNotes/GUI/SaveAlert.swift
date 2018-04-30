import Cocoa

///
/// An alert to ask the user how to handle a failed persistent context save.
///
class SaveAlert : NSAlert {
	
	///
	/// Creates new instance.
	///
	override init() {
		super.init()
		
		messageText = NSLocalizedString(
			"Could not save changes while quitting. Quit anyway?",
			comment: "Quit without saves error question message"
		)
		informativeText = NSLocalizedString(
			"Quitting now will lose any changes you have made since the last successful save",
			comment: "Quit without saves error question info"
		)
		
		addButton(withTitle: NSLocalizedString("Quit anyway", comment: "Quit anyway button title"))
		addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel button title"))
	}
	
	///
	/// Return true, if the user wants to quit anyway -- after a failed save.
	///
	/// Open this dialog and ask the user how to handle the failed save.
	///
	func selectedQuitAnyway() -> Bool {
		return runModal() == NSApplication.ModalResponse.alertFirstButtonReturn
	}
}
