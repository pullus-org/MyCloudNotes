import Alamofire
import os.log

extension CloudNotesService {
	
	///
	/// Adds the basic authentication header to an Alamofire request with the
	/// user name from the user defaults and the password from the keychain.
	///
	class AuthenticationAdapter: RequestAdapter {
		
		func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
			guard let username = UserDefaults.standard.string(forKey: UserDefaults.MyCloudNotes.Key.username) else {
				os_log("Can't set authorization header. The username is not accessible.", type: .error)
				return urlRequest
			}
			
			guard let password = PDKeychainBindings.shared().string(forKey: PDKeychainBindings.MyCloudNotes.Key.Password) else {
				os_log("Can't set authorization header. The password is not accessible.", type: .error)
				return urlRequest
			}
			
			guard let header = Alamofire.Request.authorizationHeader(user: username, password: password)  else {
				os_log("Can't set authorization header. Encoding the username and password failed.", type: .error)
				return urlRequest
			}
			
			var urlRequest = urlRequest
			
			urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
			
			return urlRequest
		}
	}
	
	///
	/// A ServerTrustPolicyManager controlled by the user defaults.
	///
	/// The manager disables the 'evaluation of the server trust', if the
	/// user default 'DisableSSLCertificateValidation' is true.
	/// In the other case, the manager behaves like a normal
	/// ServerTrustPolicyManager.
	///
	/// HINT: The server trust policy manager is only used at the start of a
	///       session. Running sessions are not affected by a change of the
	///       user defaults/behavior of the manager.
	///
	class ServerTrustPolicyManagerAdapter: Alamofire.ServerTrustPolicyManager {
		
		///
		/// Create a new instance with no policies.
		///
		init() {
			super.init(policies: [:])
		}
		
		///
		/// Returns .disableEvaluation, if the user defaults
		/// 'DisableSSLCertificateValidation' is true. Otherwise
		/// ServerTrustPolicyManager.serverTrustPolicy().
		///
		override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
			if UserDefaults.standard.bool(forKey: UserDefaults.MyCloudNotes.Key.disableSSLCertificateValidation) {
				return .disableEvaluation
			} else {
				return super.serverTrustPolicy(forHost: host)
			}
		}
	}
	
	// MARK: - Notifications
	
	///
	/// Adds an observer to update the session manager, if the security settings
	/// are changing.
	///
	func addObserverForPolicy() {
		userDefaults.addObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.disableSSLCertificateValidation, context: nil)
	}
	
	///
	/// Removes observers.
	///
	func removeObserverForPolicy() {
		userDefaults.removeObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.disableSSLCertificateValidation)
	}
	
	///
	/// Exchanges the session manager if the security settings has changed.
	///
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		invalidateSessionManager()
	}

	///
	/// Creates a new session manager with an authentification and a policy
	/// manager adapting the user defaults.
	///
	/// HINT: The policy manager is questioned only once at the beginning of a
	///       session. If the policy (behaviour of the policy manager) is
	///       changing, this has no effect on the active sessions.
	///
	func newSessionManagerWithAuthentication() -> SessionManager {
		let manager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManagerAdapter())
		
		manager.adapter = AuthenticationAdapter()
		
		return manager
	}
}
