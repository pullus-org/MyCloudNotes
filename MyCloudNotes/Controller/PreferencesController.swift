import Cocoa

///
/// controller of the preferences window.
///
class PreferencesController: NSViewController {
	
	// MARK: - Outlets
	
	///
	/// The button to disable SLL certificate validation.
	///
	@IBOutlet weak var dissableSLLCertificateValidationButton: NSButton!
	
	///
	/// The test button which triggers the server test.
	///
	@IBOutlet weak var testButton: NSButton!
	
	///
	/// The spinner to indicate a running server test.
	///
	@IBOutlet weak var testIndicator: NSProgressIndicator!
	
	///
	/// The field to display results of a server test.
	///
	@IBOutlet weak var testStatus: NSTextField!
	
	// MARK: - Actions
	
	///
	/// Tests the connection with the current settings.
	///
	@IBAction func test(_ sender: NSButton) {
		CloudNotesService().test(
			prelude: {
				self.testButton.isEnabled = false
				self.testIndicator.startAnimation(sender) },
			finish: {
				self.testIndicator.stopAnimation(sender)
				self.testButton.isEnabled = true },
			success: {
				self.testStatus.stringValue = "The CloudNotes-server is available." },
			failure: { error in
				self.testStatus.stringValue = "The CloudNotes-server is not available.\n\(error.localizedDescription)" }
		)
	}
	
	override func viewDidLoad() {
		// Don't show the 'Disable SSL cerifcate validation' button, if the
		// Application Transport Security (ATS) is enabled.
		if
			let info = Bundle.main.infoDictionary,
			let transportSecurity = info["NSAppTransportSecurity"] as? [String: AnyObject],
			let allowsArbitraryLoads = transportSecurity["NSAllowsArbitraryLoads"] as? Bool, allowsArbitraryLoads {
			dissableSLLCertificateValidationButton.isHidden = false
		} else {
			dissableSLLCertificateValidationButton.isHidden = true
		}
	}
}
