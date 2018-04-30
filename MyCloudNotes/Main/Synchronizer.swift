import Foundation
import CoreData
import Alamofire
import os.log

///
/// The synchronizer for local and remote notes.
///
/// # Synchronization (Sync)
///
/// The actions to synchronize local and remote notes are based on four
/// criteria:
/// - the local note *exists* or is *missing*
/// - the remote note *exists* or is *missing*
/// - the local note *knows* or *doesn't know* its remote note -- has a remote
///   note id
/// - the local note was *deleted* or not
////
/// ## Detecting the state of a note
///
/// An *existing* note is easy to detect. It is simply included in the
/// local or remote storage.
///
/// It is more difficult to classify a missing remote note.
///
/// A missing remote note
/// - is *deleted*, if the local note knows this remote note
/// - is *not added*, if the local note doesn't know a remote note
///
/// A *missing* local note can only be classfied as 'deleted' or 'not added'
/// with an additional information. This is done with a 'has been deleted
/// locally' list. The list is only necessary if a note was deleted locally and
/// could not deleted simultaneously from the server.
///
/// ## States and Actions
///
/// Possible states and the necessary actions to sychronize the notes.
///
/// ````
///     |         | knows   |         |         |         |         |
///     |  Local  | Remote  | Deleted | Remote  | Local   | Remote  |
///     |  Note   | Note    | Locally | Note    | Action  | Action  | Comment
/// ----+---------+---------+---------+---------+---------+---------+----------------
///     |   x     |    x    |    x    |    x    |         |         | NOT POSSIBLE
///     |   x     |    x    |    x    |    -    |         |         | NOT POSSIBLE
///   3 |   x     |    x    |    -    |    x    | Update OR  Update | (See below)
///   4 |   x     |    x    |    -    |    -    | Delete  |         |
/// ----+---------+---------+---------+---------+---------+---------+----------------
///     |   x     |    -    |    x    |    x    |         |         | NOT POSSIBLE
///     |   x     |    -    |    x    |    -    |         |         | NOT POSSIBLE
///     |   x     |    -    |    -    |    x    |         |         | NOT POSSIBLE
///   8 |   x     |    -    |    -    |    -    |         |   Add   |
/// ----+---------+---------+---------+---------+---------+---------+----------------
///     |   -     |    x    |    x    |    x    |         |         | NOT POSSIBLE
///     |   -     |    x    |    x    |    -    |         |         | NOT POSSIBLE
///     |   -     |    x    |    -    |    x    |         |         | NOT POSSIBLE
///     |   -     |    x    |    -    |    -    |         |         | NOT POSSIBLE
/// ----+---------+---------+---------+---------+---------+---------+----------------
///  13 |   -     |    -    |    x    |    x    |   Add  OR  Delete | (See below)
///  14 |   -     |    -    |    x    |    -    |         |         | Delete Deletion
///  15 |   -     |    -    |    -    |    x    |   Add   |         |
///     |   -     |    -    |    -    |    -    |         |         | NOT POSSIBLE
/// ----+---------+---------+---------+---------+---------+---------+----------------
///
/// 'x' is present, '-' is missing,
/// ````
/// (3)   The local and remote action depend on the last modification time. The
///       older one is updated.
///
/// (13a) Add the note to the local storage, if the deletion is older than the
///       modification time of the remote note.
///
/// (13b) Otherwise delete the remote note.
///
/// HINT: (13) is not implemented. The remote note is always deleted.
///
///
/// # Automatic Synchronization (Auto)
///
/// The automatic synchronization use a timer to trigger the synchronization on
/// selectable intervals.
///
///
/// # Instant Synchronization (Instant)
///
/// If a user changes (insertes, updates or deletes) a note the note can be
/// instantly synchronized with the server.
///
class Synchronizer: NSObject {
	
	///
	/// The Core Data context (main thread) of the local notes and the
	/// deletions.
	///
	let context: NSManagedObjectContext
	
	///
	/// The timer for automatic synchronizations.
	///
	var timer: Timer?
	
	// MARK: -
	
	init(context aContext: NSManagedObjectContext) {
		context = aContext

		super.init()

		addObserverForInstantChanges()
		addObserverForSynchronizePeriod()
	}
	
	///
	/// Remove observers.
	///
	deinit {
		removeObserverForInstantChanges()
		removeObserverForSynchronizePeriod()
	}

	// MARK: -
	
	///
	/// Dispatch notification.
	/// - Updates the timer for automatic synchronization.
	///
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard let keyPath = keyPath else {
			os_log("Ignore notification. Missing key path.", type: .error)
			return
		}
		
		switch keyPath {
		case UserDefaults.MyCloudNotes.Key.synchronizePeriod:
			synchronizePeriodHasChanged(of: object, change: change, context: context)
		default:
			os_log("Ignore notification. Unexpected key path '%{public}@'.", type: .error, keyPath)
		}
	}
}
