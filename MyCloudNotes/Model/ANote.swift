import Foundation

///
/// ANote is used to decouple the development of the server application and the
/// client application. ANote is implemented by Note and RemoteNote.
///
protocol ANote {
	
	///
	/// The title of the note.
	///
	/// It should be the first line of the content.
	///
	var title: String? { get set }
	
	///
	/// The main content of the note.
	///
	var content: String? { get set }
	
	///
	/// The category of a note.
	///
	var category: String? { get set }
	
	///
	/// Return if this note is a favorite.
	///
	var favorite: Bool { get set }
	
	///
	/// The last modification time.
	///
	var modified: Date? { get set }
}
