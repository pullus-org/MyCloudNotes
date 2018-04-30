import Foundation
import Alamofire
import os.log

///
/// The local CloudNotes service representative.
///
class CloudNotesService: NSObject {
	
	typealias SELF = CloudNotesService
	
	///
	/// The standard instance.
	///
	public static let standard = CloudNotesService()
	
	// MARK: -
	
	var userDefaults:UserDefaults { get { return UserDefaults.standard } }
	
	// MARK: - Alamofire
	
	///
	/// The active session manager with the installed authentication and policy
	/// adapter or nil.
	///
	private var activeSessionManager: SessionManager?

	///
	/// The session manager with the installed authentication and policy
	/// adapter.
	///
	/// HINT: The policy manager is questioned only once at the beginning of a
	///       session. If the policy (behaviour of the policy manager) is
	///       changing, this has no effect on the active sessions.
	///       Use invalidateSessionManager to request a new session manager.
	///       See: addObserverForPolicy
	///
	var sessionManager: SessionManager {
		get {
			if let manager = activeSessionManager { return manager }
			
			let manager = newSessionManagerWithAuthentication()
			
			activeSessionManager = manager
			return manager
		}
	}
	
	///
	/// Invalidate the session manager.
	///
	func invalidateSessionManager() {
		activeSessionManager = nil
	}

	// MARK: - Notifications
	
	///
	/// A lock to protect the access of 'numberOfRunningRequests'.
	///
	let lock = NSLock()
	
	///
	/// The number of running requests to control the notifications.
	///
	var numberOfRunningRequests = 0
	
	// MARK: -
	
	override init() {
		super.init()
		addObserverForPolicy()
	}
	
	deinit {
		removeObserverForPolicy()
	}
	
	// MARK: - Requests Helper

	///
	/// Handle prelude.
	///
	/// Post 'BeginRequest' with the NotificationCenter.
	///
	private func pre(_ logMessage: String? = nil, _ prelude: Procedure?) {
		if let logMessage = logMessage { os_log("%{public}@", type: .info, logMessage) }

		prelude?()
		sendBeginRequest()
	}
	
	///
	/// Handle finish.
	///
	/// Post 'FinishRequest' with the NotificationCenter.
	///
	private func finished(_ finish: Procedure?) {
		finish?()
		sendFinishRequest()
	}
	
	///
	/// Handle success.
	///
	/// Post 'requestSuccess' with the NotificationCenter.
	///
	private func succeeded(_ logMessage: String? = nil, _ success: Procedure?) {
		if let logMessage = logMessage { os_log("%{public}@", type: .info, logMessage) }

		sendRequestSucceeded()
		success?()
	}
	
	///
	/// Handle failure.
	///
	/// Post 'requestFailed' with the NotificationCenter.
	///
	private func failed(_ logMessage: String? = nil, _ error: Error, _ failure: ErrorHandler?) {
		if let logMessage = logMessage { os_log("%{public}@", type: .info, logMessage) }

		sendRequestFailed(errorMessage: logMessage)
		failure?(error)
	}
	
	// MARK: - Requests
	
	///
	/// Tests the connection of this instance to the CloudNotes-server.
	///
	func test(prelude: Procedure? = nil, finish: Procedure? = nil, success: Procedure? = nil, failure: ErrorHandler? = nil) {
		sessionManager
			.request(Request.test)
			.prelude { self.pre("Test if the CloudNotes-server is accessible.", prelude) }
			.validate()
			.responseData { response in
				self.finished(finish)

				switch response.result {
				
				case .success:
					self.succeeded("The CloudNotes-server is accessible.", success)
				
				case .failure(let error):
					self.failed("The CloudNotes-server is not accessible.", error, failure)
				}
		}
	}
	
	///
	/// Gets all notes.
	///
	func notes(prelude: Procedure? = nil, finish: Procedure? = nil, success: (([RemoteNote]) -> Void)?, failure: ErrorHandler? = nil) {
		sessionManager
			.request(Request.notes)
			.prelude { self.pre("Get all notes from the CloudNotes-server.", prelude) }
			.validate()
			.responseJsonObject([RemoteNote].self) { (response: DataResponse<[RemoteNote]>) in
				self.finished(finish)

				switch response.result {
				
				case .success:
					self.succeeded("All remote notes received from the CloudNotes-server.") { success?(response.value ?? []) }
				
				case .failure(let error):
					self.failed("Can't get the remote notes from the CloudNotes-server.", error, failure)
				}
		}
	}
	
	///
	/// Creates a remote note.
	///
	func create(localNote: Note, prelude: Procedure? = nil, finish: Procedure? = nil, success: ((RemoteNote)->Void)? = nil, failure: ErrorHandler? = nil) {
		guard let localNoteId = localNote.id else {
			os_log("Can't create a remote. The local note has no id.", type: .error)
			return
		}
		
		sessionManager
			.request(Request.post(localNote))
			.prelude { self.pre("Create a remote note from the local note '\(localNoteId)'.", prelude) }
			.validate()
			.responseJsonObject(RemoteNote.self) { (response: DataResponse<RemoteNote>) in
				self.finished(finish)

				switch response.result {
				
				case .success:
					guard let remoteNote = response.value  else {
						self.failed("Did not receive a remote note after creating a remote note for the local note '\(localNoteId)'. The response contains no remote note.", Failure.missingRemoteNoteInResponse, failure)
						return
					}
					self.succeeded("The remote note has been created from the local note '\(localNoteId)'.") { success?(remoteNote) }
			
				case .failure(let error):
					self.failed("Can't create the remote note from the local note '\(localNoteId)'. Server failure '\(String(describing: response.error))'.", error, failure)
				}
		}
	}
	
	///
	/// Updates a remote note
	///
	func update(localNote: Note, prelude: Procedure? = nil, finish: Procedure? = nil, success: ((RemoteNote)->Void)? = nil, failure: ErrorHandler? = nil) {
		guard let localNoteId = localNote.id else {
			os_log("Can't update the local note. The local note has no id.", type: .error)
			return
		}
		
		sessionManager
			.request(Request.put(localNote))
			.prelude { self.pre("Update a remote note with the local note '\(localNoteId)'.", prelude) }
			.validate()
			.responseJsonObject(RemoteNote.self) { (response: DataResponse<RemoteNote>) in
				self.finished(finish)

				switch response.result {
					
				case .success:
					guard let remoteNote = response.value  else {
						self.failed("Did not receive a remote note after updating a remote note for the local note '\(localNoteId)'. The response contains no remote note.", Failure.missingRemoteNoteInResponse, failure)
						return
					}
					self.succeeded(){  success?(remoteNote) }
					
				case .failure(let error):
					self.failed("Can't update the remote note from the local note '\(localNoteId)'. Server failure '\(String(describing: response.error))'.", error, failure)
				}
		}
	}
	
	///
	/// Deletes a note from the server.
	///
	func delete(remoteNoteId id: NSNumber, prelude: Procedure? = nil, finish: Procedure? = nil, success: Procedure? = nil, failure: ErrorHandler? = nil) {
		sessionManager
			.request(Request.delete(id))
			.prelude { self.pre("Delete remote note '\(id)' from the server.", prelude) }
			.validate()
			.responseData { response in
				self.finished(finish)

				switch response.result {
					
				case .success:
					self.succeeded("Deleted Remote note '\(id)' from the server.", success)
					
				case .failure(let error):
					if response.response?.statusCode == 404 {
						self.succeeded("Can't delete remote note '\(id)' from the server. The note is already deleted.", success)
					} else {
						self.failed("Can't delete remote note '\(id)' from the server.  '\(String(describing: response.error))'.", error, failure)
					}
				}
		}
	}
}
