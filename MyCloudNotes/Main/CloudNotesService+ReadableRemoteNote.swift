import Foundation

extension CloudNotesService {
	
	///
	/// An adapter to use a JSON-dictionary like a readable remote note .
	///
	class ReadableRemoteNote {
		
		///
		/// The JSON-dictionary.
		///
		private let json: Dictionary<String, Any>
		
		///
		/// Return the server id.
		///
		var id: NSNumber? {
			get { return json.value(forKey: CloudNotesService.JsonKey.id) }
		}
		
		///
		/// Return the title.
		///
		var title: String? {
			get { return json.value(forKey: CloudNotesService.JsonKey.title) }
		}
		
		///
		/// Return the content.
		///
		var content: String? {
			get { return json.value(forKey: CloudNotesService.JsonKey.content) }
		}
		
		///
		/// Return the category.
		///
		var category: String? {
			get { return json.value(forKey: CloudNotesService.JsonKey.category) }
		}
		
		///
		/// Return if favorite.
		///
		var favorite: Bool? {
			get { return json.value(forKey: CloudNotesService.JsonKey.favorite) }
		}
		
		///
		/// Return modified.
		///
		var modified: Date? {
			get {
				guard let number: NSNumber = json.value(forKey: CloudNotesService.JsonKey.modified) else {
					return nil
				}
				
				return Date(timeIntervalSince1970: number.doubleValue)
			}
		}
		
		// MARK: -
		
		///
		/// Creates a new instance to adapt a JSON-dictionary.
		///
		init(_ aJson: Dictionary<String, Any>) {
			json = aJson
		}
	}
}
