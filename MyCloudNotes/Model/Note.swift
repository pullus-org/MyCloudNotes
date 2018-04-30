import Foundation
import CoreData
import os.log

///
/// The class is defined in 'MyCloudNotes.xcdatamodeld'.
///
extension Note: ANote {
	
	///
	/// Creates a new instance with a given content.
	///
	convenience init(context: NSManagedObjectContext, content aContent: String) {
		self.init(context: context)
		
		initialize(content: aContent)
	}
	
	///
	/// Initializes this instance. Sets:
	/// - 'id' to an universally unique identifier
	/// - 'created' and 'modified' to 'now'
	/// - 'content' and 'category' to the given values or ""
	/// - 'favorite' to the given value or to false
	///
	private func initialize(content aContent: String? = nil, category aCategory: String? = nil, favorite aFavorite: Bool? = false) {
		created = Date()
		
		id = UUID().uuidString
		content = aContent ?? ""
		category = aCategory ?? ""
		favorite = aFavorite ?? false
		
		modified = created
	}
	
	// MARK: - Key Value Object
	
	///
	/// If the 'content' is set, the 'title' is changed to the first line
	/// of the 'content'.
	/// If the 'category', 'favorite' or 'title' is set, 'modified' is set to
	/// 'now'.
	///
	override public func didChangeValue(forKey key: String) {
		super.didChangeValue(forKey: key)
		
		switch key {
		case "category":	modified = Date()
		case "content":		title = content?.firstLine
		case "favorite":	modified = Date()
		case "title":		modified = Date()
		default:			break
		}
	}
	
	// MARK: - Core Data
	
	///
	/// Sets 'id' to an universally unique identifier and 'modified' to 'now'.
	///
	/// HINT:	This method is called, for example, if a note is created from
	///			the GUI with the '+' button and the
	///			'Notes Controller'/NSArrayController.
	///
	public override func awakeFromInsert() {
		os_log("Insert new Note.", type: .info)

		initialize()
	}
	
	// MARK: -
	
	///
	/// True, if a remoteId is set and it is valid.
	///
	/// A valid id is greater than zero.
	///
	var hasValidRemoteId: Bool {
		get {
			// HINT: Core Data transforms 'nil' to '0'
			return (remoteId?.int64Value ?? 0) > 0
		}
	}
	
	///
	/// True, if changed locally after synchronization.
	///
	/// ````
	/// modified |synchronized| Result
	/// ---------+------------+--------
	///    nil   |     nil    | false
	///    nil   |   not nil  | false
	///  not nil |     nil    | true
	///  not nil |   not nil  | synchronized < modified
	/// ````
	var hasChangedAfterSynchronization: Bool {
		get {
			guard let modified = modified else { return false }
			guard let synchronized = synchronized else { return true }
			
			return synchronized < modified
		}
	}
	
	///
	/// Compares if this note is modified earlier than an other note.
	/// ````
	///   This  | Other   |
	/// Modified|Modified | Result
	/// --------+---------+--------
	/// not nil | not nil | compare modified
	/// not nil | nil     | orderedDescending
	///   nil   | not nil | orderedAscending
	///   nil   |  nil    | orderedSame
	/// ````
	func compareModification(_ other: ANote) -> ComparisonResult {
		if  let selfModified = modified,
			let otherModified = other.modified {
			return selfModified.compare(otherModified)
		}
		
		if let _ = self.modified  { return ComparisonResult.orderedAscending }
		if let _ = other.modified { return ComparisonResult.orderedDescending }
		
		return ComparisonResult.orderedSame
	}
	
	///
	/// Return the title or an empty string.
	///
	/// Same as 'title ?? ""'.
	///
	var titleOrEmpty: String { get { return title ?? "" } }
	
	///
	/// Return the content or an empty string.
	///
	var contentOrEmpty: String { get { return content ?? "" } }
	
	///
	/// Updates this note with values from an other note.
	///
	/// Updates 'remoteId', 'title', 'content', 'category', 'favorite' and
	/// 'modified'.
	/// 'created' will not be set, because remote notes dont't support it.
	///
	func overwrite(note aRemoteNote: RemoteNote?) {
		guard let remoteNote = aRemoteNote else { return }
		
		remoteId = remoteNote.id
		title = remoteNote.title
		content = remoteNote.content
		category = remoteNote.category
		favorite = remoteNote.favorite
		
		// HINT:	Changing an attribute can update 'modified'
		//			automatically. So 'modified' is set after all other
		//			attributes. See didChangeValue.
		modified = remoteNote.modified
		
		synchronized = Date()
	}
}
