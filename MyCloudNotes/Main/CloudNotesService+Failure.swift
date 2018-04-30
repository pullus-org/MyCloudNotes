import Foundation

extension CloudNotesService {
	
	///
	/// Errors of the CloudNotesService.
	///
	public enum Failure: Error {
		
		///
		/// The response doesn't contain a RemoteNote.
		///
		case missingRemoteNoteInResponse
		
		///
		/// The local note doesn't contain an id of a remote note.
		///
		case missingRemoteNoteIdInLocalNote
	}
}
