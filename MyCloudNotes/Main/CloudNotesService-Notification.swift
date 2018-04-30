import Foundation

extension Notification.Name {
	
	///
	/// Notifications of the CloudNotesService
	///
	public struct CloudeNotesService {
		
		///
		/// The CloudNotesService begins a request.
		///
		/// Immediatly after sending this notification, the service will connect
		/// the server and send request.
		///
		public static let beginRequest = Notification.Name(rawValue: "BeginRequest")
		
		///
		/// The CloudNotesService finished a request.
		///
		/// The service receives a response and the result can be evaluated.
		///
		public static let finishRequest = Notification.Name(rawValue: "FinishRequest")
		
		///
		/// The CloudNotesService begins a series of requests.
		///
		/// Immediatly after sending this notification, the service will connect
		/// the server and send request.
		///
		public static let beginRequests = Notification.Name(rawValue: "BeginRequests")
		
		///
		/// The CloudNotesService finished a series of request. All requests
		/// are finished.
		///
		/// The service receives a response and the result can be evaluated.
		///
		public static let finishRequests = Notification.Name(rawValue: "FinishRequests")
		
		///
		/// The CloudNotesService detected a failed request.
		///
		public static let requestFailed = Notification.Name(rawValue: "RequestFailed")
		
		///
		/// The CloudNotesService performed a succeeded a request.
		///
		public static let requestSucceeded = Notification.Name(rawValue: "RequestSucceeded")
	}
}

extension Notification {
	
	///
	/// Special userinfos.
	///
	struct UserInfo {
		
		///
		/// Keys of the CloudNoteService for the user info of a notification.
		///
		struct CloudNoteService {
			
			///
			/// The key for the error message.
			///
			public static let errorMessage = "ErrorMessage"
		}
	}
}
