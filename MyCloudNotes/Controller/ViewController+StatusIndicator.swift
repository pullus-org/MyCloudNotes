import Cocoa

///
/// The status indicator is controlled by observing the
/// CloudNotesService.
///
extension ViewController {
	
	// MARK: - Key Value Object
	
	///
	/// Add observer to control statusIndicator.
	///
	func addObserverForStatusIndicator() {
		notificationCenter.addObserver(self, selector: #selector(indicateStatusOk(notification:)), name: Notification.Name.CloudeNotesService.requestSucceeded, object: nil)
		notificationCenter.addObserver(self, selector: #selector(indicateStatusError(notification:)), name: Notification.Name.CloudeNotesService.requestFailed, object: nil)
	}
	
	///
	/// Remove observers
	///
	func removeObserverForStatusIndicator() {
		notificationCenter.removeObserver(self, name: Notification.Name.CloudeNotesService.requestSucceeded, object: nil)
		notificationCenter.removeObserver(self, name: Notification.Name.CloudeNotesService.requestFailed, object: nil)
	}
	
	// MARK: - Status Indicator
	
	///
	/// Display a status error with a message as a tooltip.
	///
	@objc private func indicateStatusError(notification: NSNotification) {
		if let errorMessage = notification.userInfo?[Notification.UserInfo.CloudNoteService.errorMessage] as? String {
			statusIndicator.toolTip = errorMessage
		}
		
		statusIndicator.isHidden = false
	}
	
	///
	/// Remove the 'status error display' and its message.
	///
	@objc private func indicateStatusOk(notification: NSNotification) {
		statusIndicator.toolTip = nil
		statusIndicator.isHidden = true
	}
}
