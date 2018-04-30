import Alamofire
import os.log

extension CloudNotesService {
	
	///
	/// Request types for CRUD and other operations for notes.
	///
	enum Request: URLRequestConvertible {
		
		private typealias SELF = Request
		
		///
		/// Used to fix 'the first request always fails'.
		/// See AppDelegate.applicationDidFinishLaunching/
		/// SynchronizeOnStartAndQuit
		///
		case ping
		
		///
		/// Tests the connection to the remote server.
		///
		case test
		
		///
		/// Gets all remote notes from the server.
		///
		case notes
		
		///
		/// Updates a remote note.
		///
		case put(Note)
		
		///
		/// Creates a remote note.
		///
		case post(Note)
		
		///
		/// Deletes a remote note from the server.
		///
		case delete(NSNumber)
		
		///
		/// The root path of the CloudNotes service.
		///
		private static let servicePath = "index.php/apps/notes/api/v0.2"
		
		///
		/// Fetches the server url from the user defaults.
		///
		private func serverUrl() throws -> URL {
			guard let server = UserDefaults.standard.string(forKey: UserDefaults.MyCloudNotes.Key.server) else {
				os_log("Can't access server url from user defaults.", type: .error)
				throw AFError.invalidURL(url: "nil")
			}
			
			return try server.asURL()
		}
		
		///
		/// Creates the service url with the server name, the service path and
		/// an optinal object identifier (id).
		///
		/// Example without an id:
		///
		///		http://www.owncloud.org/index.php/apps/notes/api/v0.2/notes
		///
		/// Example with an id:
		///
		///		http://www.owncloud.org/index.php/apps/notes/api/v0.2/notes/238
		///
		private func serviceUrl(id: NSNumber? = nil) throws -> URL {
			var url = try serverUrl()
				.appendingPathComponent(SELF.servicePath)
				.appendingPathComponent("notes")
			
			if let id = id {
				url.appendPathComponent("/\(id)")
			}
			
			return url
		}
		
		///
		/// Creates an URLRequest with a service url.
		///
		private func serviceUrlRequest(id: NSNumber? = nil, method: HTTPMethod = .get, parameters: Parameters? = nil) throws -> URLRequest {
			let url = try serviceUrl(id: id)
			var urlRequest = URLRequest(url: url)
			
			urlRequest.httpMethod = method.rawValue
			urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
			
			return urlRequest
		}
		
		func asURLRequest() throws -> URLRequest {
			switch self {
			
			case .ping:
				return try serviceUrlRequest(id: 0)
				
			case .test:
				return try serviceUrlRequest(parameters: ["exclude": "title,content,category,favorite,modified"])
				
			case .notes:
				return try serviceUrlRequest()
				
			case .delete(let id):
				return try serviceUrlRequest(id: id, method: .delete)
				
			case .put(let localNote):
				guard let id = localNote.remoteId else {
					throw CloudNotesService.Failure.missingRemoteNoteIdInLocalNote
				}
				
				return try serviceUrlRequest(id: id, method: .put, parameters: localNote.toJson())
				
			case .post(let localNote):
				return try serviceUrlRequest(method: .post, parameters: localNote.toJson()
				)
			}
		}
	}
}
