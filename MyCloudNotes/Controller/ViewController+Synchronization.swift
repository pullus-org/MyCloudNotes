import Cocoa

///
/// The synchronization indicator is controlled by observing the
/// CloudNotesService.
///
/// It is not controlled by the 'synchronize' action of the synchronize button
/// or the synchronize menu entry.
///
extension ViewController {
	
	// MARK: - Key Value Object
	
	///
	/// Add observer to control synchronizationIndicator.
	///
	func addObserverForSynchronizationAnimation() {
		notificationCenter.addObserver(self, selector: #selector(startSynchronizationAnimation), name: Notification.Name.CloudeNotesService.beginRequests, object: nil)
		notificationCenter.addObserver(self, selector: #selector(stopSynchronizationAnimation), name: Notification.Name.CloudeNotesService.finishRequests, object: nil)
	}
	
	///
	/// Remove observers.
	///
	func removeObserverForSynchronizationAnimation() {
		notificationCenter.removeObserver(self, name: Notification.Name.CloudeNotesService.beginRequests, object: nil)
		notificationCenter.removeObserver(self, name: Notification.Name.CloudeNotesService.finishRequests, object: nil)
	}
	
	// MARK: - Synchronization Indicator

	@objc private func startSynchronizationAnimation() {
		self.synchronizationButton.isEnabled = false
		synchronizationIndicator.startAnimation(nil)
	}
	
	@objc private func stopSynchronizationAnimation() {
		synchronizationIndicator.stopAnimation(nil)
		self.synchronizationButton.isEnabled = true
	}
}
