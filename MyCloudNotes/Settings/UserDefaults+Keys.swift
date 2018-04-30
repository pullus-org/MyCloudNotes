extension UserDefaults {
	
	///
	/// User defaults for the MyCloudNotes application
	///
	struct MyCloudNotes {
		
		///
		/// Keys for user defaults.
		///
		class Key {
			
			///
			/// The key for the 'server address' in the user defaults.
			///
			static let server = "Server"
			
			///
			/// The key for the 'user name' in the user defaults.
			///
			static let username = "Username"
			
			///
			/// The key for 'DisableSSLCertificateValidation' in the user
			/// defaults.
			///
			static let disableSSLCertificateValidation = "DisableSSLCertificateValidation"
			
			///
			/// The key for 'synchronize on start' in the user defaults.
			///
			static let synchronizeOnStartAndQuit = "SynchronizeOnStartAndQuit"
			
			///
			/// The key for the 'synchronize' period.
			///
			static let synchronizePeriod = "SynchronizePeriod"
			
			///
			/// The key for 'enable markdown' in the user defaults.
			///
			static let enableMarkdown = "EnableMarkdown"
			
			///
			/// The key for 'hide syntax' in the user defaults.
			///
			static let hideSyntax = "HideSyntax"
		}
		
		///
		/// Values for user defaults.
		///
		class Value {
			///
			/// No automatic synchronization. Value for 'synchronizePeriod'.
			///
			static let manually: NSNumber = 0
			
			///
			/// Automatic synchronization every minute. Value for
			/// 'synchronizePeriod'.
			///
			static let everyMinute: NSNumber = 60
			
			///
			/// Automatic synchronization every 5 minutes. Value for
			/// 'synchronizePeriod'.
			///
			static let every5Minutes: NSNumber = 300
			
			///
			/// Automatic synchronization every 15 minutes. Value for
			/// 'synchronizePeriod'.
			///
			static let every15Minutes: NSNumber = 900
			
			///
			/// Automatic synchronization every hour. Value for
			/// 'synchronizePeriod'.
			///
			static let everyHour: NSNumber = 3600
		}
	}
}
