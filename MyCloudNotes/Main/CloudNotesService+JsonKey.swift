
import Foundation

extension CloudNotesService {
	
	///
	/// Namespace for keys used in JSON-dictionaries for requests or responses.
	///
	class JsonKey {
		
		///
		/// The id-key of a note.
		///
		static let id = "id"
		
		///
		/// The title-key of a note.
		///
		static let title = "title"
		
		///
		/// The content-key of a note.
		///
		static let content = "content"
		
		///
		/// The category-key of a note.
		///
		static let category = "category"
		
		///
		/// The favorite-key of a note.
		///
		static let favorite = "favorite"
		
		///
		/// The modified-key of a note.
		///
		static let modified = "modified"
	}
}
