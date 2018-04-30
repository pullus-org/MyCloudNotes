import Foundation

extension Synchronizer {
	
	///
	/// Errors of the Synchronizer
	///
	enum Failure: Error {
		
		///
		/// The Synchronizer can't load the local notes from Core Data.
		///
		case cannotLoadLocalNotes
		
		///
		/// The Synchronizer can't load the deletions from Core Data.
		///
		case cannotLoadDeletions
	}
}
