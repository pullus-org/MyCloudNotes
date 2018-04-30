import os.log

extension CloudNotesService {
	
	///
	/// Notification Center.
	///
	var notificationCenter: NotificationCenter { get { return NotificationCenter.default } }
	
	///
	/// Sends notification
	/// - 'BeginRequest' and
	/// - 'BeginRequests' if no request is running.
	///
	func sendBeginRequest() {
		lock.perform {
			notificationCenter.post(name: Notification.Name.CloudeNotesService.beginRequest, object: self)
			
			if numberOfRunningRequests == 0 {
				notificationCenter.post(name: Notification.Name.CloudeNotesService.beginRequests, object: self)
			}
			numberOfRunningRequests = numberOfRunningRequests + 1
		}
	}
	
	///
	/// Sends notification
	/// - 'FinishRequest' and
	/// - 'FinishRequests' if no more request is running.
	///
	func sendFinishRequest() {
		lock.perform {
			guard numberOfRunningRequests > 0 else {
				os_log("Did not notify observers. All requests are finished.", type: .error)
				return
			}
			
			notificationCenter.post(name: Notification.Name.CloudeNotesService.finishRequest, object: self)
			
			numberOfRunningRequests = numberOfRunningRequests - 1
			
			if numberOfRunningRequests == 0 {
				notificationCenter.post(name: Notification.Name.CloudeNotesService.finishRequests, object: self)
			}
		}
	}
	
	///
	/// Sends notification 'RequestSucceeded'.
	///
	func sendRequestSucceeded() {
		notificationCenter.post(name: Notification.Name.CloudeNotesService.requestSucceeded, object: self)
	}
	
	///
	/// Sends notification 'RequestFailed'.
	///
	func sendRequestFailed(errorMessage: String? = nil) {
		var userInfo: [AnyHashable: Any] = [:]
		
		if let errorMessage = errorMessage { userInfo[Notification.UserInfo.CloudNoteService.errorMessage] = errorMessage }
		
		notificationCenter.post(name: Notification.Name.CloudeNotesService.requestFailed, object: self, userInfo: userInfo)
	}
}
