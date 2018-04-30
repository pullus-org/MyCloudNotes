extension AppDelegate {
	
	// MARK: - Key Value Object
	
	///
	/// Add observer to control synchronizationIndicator.
	///
	func addObserverForStatusOfSynchronizationMenuItem() {
		notificationCenter.addObserver(self, selector: #selector(disableSynchronizationMenuItem), name: Notification.Name.CloudeNotesService.beginRequests, object: nil)
		notificationCenter.addObserver(self, selector: #selector(enableSynchronizationMenuItem), name: Notification.Name.CloudeNotesService.finishRequests, object: nil)
	}
	
	///
	/// Remove observers.
	///
	func removeObserverForStatusOfSynchronizationMenuItem() {
		notificationCenter.removeObserver(self, name: Notification.Name.CloudeNotesService.beginRequests, object: nil)
		notificationCenter.removeObserver(self, name: Notification.Name.CloudeNotesService.finishRequests, object: nil)
	}
	
	// MARK: - Synchronization Indicator
	
	@objc private func disableSynchronizationMenuItem() {
		synchronizationMenuItem.isEnabled = false
	}
	
	@objc private func enableSynchronizationMenuItem() {
		synchronizationMenuItem.isEnabled = true
	}
}
