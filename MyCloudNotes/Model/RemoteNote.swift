import Foundation

///
/// To decouple the development of the server application and the client
/// application, this class is exclusive for remote notes.
///
final class RemoteNote: ANote, Hashable {
	
	// MARK: - Hashable, Equatable
	
	var hashValue: Int
	
	static func ==(lhs: RemoteNote, rhs: RemoteNote) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}
	
	// MARK: -
	
	///
	/// The id of the remote note.
	///
	/// The id is not optional because a remote note without an id is useless.
	///
	var id: NSNumber
	
	///
	/// The title of the note.
	///
	/// It should be the first line of the content.
	///
	var title: String?
	
	///
	/// The main content of the note.
	///
	var content: String?
	
	/// Return the category.
	///
	var category: String?
	
	///
	/// Return if favorite.
	///
	var favorite: Bool
	
	///
	/// The last modification time.
	///
	var modified: Date?
	
	// MARK: -
	
	///
	/// Creates a new instance.
	///
	init(id anId: NSNumber, title aTitle: String?, content aContent: String?, category aCategory: String?, favorite aFavorite: Bool?, modified aModified: Date?) {
		hashValue = anId.intValue
		
		id = anId
		
		title = aTitle
		content = aContent
		category = aCategory
		favorite = aFavorite ?? false
		
		modified = aModified
	}
}
