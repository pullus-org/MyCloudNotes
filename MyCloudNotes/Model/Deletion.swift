import Foundation
import CoreData

///
/// A deletion contains an id of a remote note which should be deleted.
///
/// This is necessary when a local note is deleted and the server is not
/// available and the remove not can't be deleted immediately.
///
/// The class is defined in 'MyCloudNotes.xcdatamodeld'.
///
extension Deletion {
	
	// MARK: -
	
	///
	/// Creates a new delection with an id of a remote note.
	///
	convenience init(context aContext: NSManagedObjectContext, remoteId aRemoteNoteId: NSNumber) {
		self.init(context: aContext)
		
		remoteNoteId = aRemoteNoteId
	}
}
