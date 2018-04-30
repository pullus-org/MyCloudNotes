import CoreData
import os.log

///
/// The main class of this application.
///
/// HINT: This class should be the core of GUI- and CLI-applications.
///
/// # User Inputs and Event Flow
///
/// ````
///     +-----IBActions--> NSArrayController ---IBActions--> TableView
///     |                         |
///     |                         |
///     |                         ˅
///  UI Inputs              Object Context
///     |                         |
///     |                    Notification
///     |                         |
///     |                         ˅
///     +-----IBActions-->  Synchronizer  ---> CloudNotesService ---REST--> OwnCloud-CloudNotes
///````
///````
///        New                             '+'   '-'
///         |                               |     |
///         |                               |     |
///         v                               v     v
///   +-----------+                     +--------------+
///   |AppDelegate|-------------------->|ViewController|
///   +-----------+            +--------|              |
///                            |        +--------------+
///                            |                ^
///                            |                |
///                            v                v
///                  +------------+     +---------------+
///                  |MyCloudNotes|     |NotesController|
///                  +------------+     +---------------+
///                        |                    ^
///                        |                    |
///  +----------+          v                    v
///  |CloudNotes|    +------------+         +-------+
///  | Service  |<---|Synchronizer|-------->|Context|
///  +----------+    +------------+         +-------+
///````
///
/// # Settings
///
/// The settings are stored in the 'User Defaults' and the 'Keychain'.
///
///		Setting                            | Storage       | Key or Keypath
/// 	-----------------------------------+---------------+--------------------------------------------
///		Server                             | User Defaults | 'values', 'Server'
///		Username                           | User Defaults | 'values', 'Username'
///		Synchronize On Start and Quit      | User Defaults | 'values', 'SynchronizeOnStartAndQuit'
///		Disable SSL Certificate Validation | User Defaults | 'values', 'DisableSSLCertificateValidation'
///		Password                           | Keychain      | 'values.Password'
///
class MyCloudNotes {
	
	typealias SELF = MyCloudNotes
	
	///
	/// The default (singleton) instance.
	///
	static var shared = MyCloudNotes()
	
	// MARK: - Core Data
	
	///
	/// Name of the application persistant container.
	///
	private static let containerName = "MyCloudNotes"
	
	///
	/// The persistent container for the application. This implementation
	/// creates and returns a container, having loaded the store for the
	/// application to it. This property is optional since there are legitimate
	/// error conditions that could cause the creation of the store to fail.
	///
	private lazy var container: NSPersistentContainer = {
		let container = NSPersistentContainer(name: SELF.containerName)
		
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error {
				// Replace this implementation with code to handle the error
				// appropriately. fatalError() causes the application to
				// generate a crash log and terminate. You should not use this
				// function in a shipping application, although it may be useful
				// during development.
				//
				// Typical reasons for an error here include:
				// - The parent directory does not exist, cannot be created, or
				//   disallows writing.
				// - The persistent store is not accessible, due to permissions
				//   or data protection when the device is locked.
				// - The device is out of space.
				// - The store could not be migrated to the current model
				//   version.
				// Check the error message to determine what the actual problem was.
				fatalError("Can't create persistent container '\(SELF.containerName)' and load persistent stores. \(error).")
			}
		}
		
		return container
	}()
	
	///
	/// The viewContext of the container.
	///
	var context: NSManagedObjectContext { return container.viewContext }
	
	// MARK: -
	
	///
	/// The synchronizer.
	///
	lazy var synchronizer = { return Synchronizer(context: context) }()
	
	///
	/// The default error handler of 'save()'.
	///
	private static let defaultErrorHandler: (Error?) -> Bool = { error in return false }
	
	// MARK: -

	init() {
		let _ = synchronizer
	}
	
	// MARK: -
	
	///
	/// Save the persistent context.
	///
	/// Returns true, if the context was successfully saved.
	/// Otherwise the result of the error handler will be returned. The default
	/// handler returns false.
	///
	@discardableResult
	func save(errorHandler: (Error?) -> Bool = SELF.defaultErrorHandler) -> Bool {
		os_log("Save persistent context '%{public}@'.", type: .info, SELF.containerName)
		
		return context.performAndReturn {
			guard context.commitEditing() else {
				os_log("Can't commit editings.", type: .error)
				
				return errorHandler(nil)
			}
			
			if !context.hasChanges {
				os_log("Nothing has changed. Nothing to save.", type: .info)
				
				return true
			}
			
			do {
				try context.save()
			} catch {
				os_log("Can't save the persistent context '%{public}@'. Error is '%{public}@'.", type: .error, SELF.containerName, String(describing: error))
				
				return errorHandler(error)
			}
			
			return true
		}
	}
	
	///
	/// Import one or more notes.
	///
	public func importNotes(urls: [URL], failure: ErrorHandler? = nil) {
		os_log("Import notes.", type: .info)
		
		context.performAndWait {
			urls.forEach { url in
				do {
					os_log("Import note from '%{public}@'.", type: .info, url.humanReadableString)
					
					let content: String = try String(contentsOf: url, encoding: .utf8)
					let _ = Note(context: context, content: content)
					
					context.trySave(failure: failure)
				} catch {
					os_log("Can't import note from '%{public}@'.", type: .error, url.humanReadableString)
					failure?(error)
				}
			}
		}
	}

	///
	/// Export a single note.
	///
	public func exportNote(note: Note, url: URL, failure: ErrorHandler? = nil) {
		do {
			try note.contentOrEmpty.write(to: url, atomically: true, encoding: String.Encoding.utf8)
		} catch {
			os_log("Can't export note '%{public}@' to '%{public}@'.", type: .error, note.id ?? "?", url.humanReadableString)
			failure?(error)
		}
	}

	///
	/// Synchronizes local and remote notes.
	///
	func synchronizeNotes(prelude: Procedure? = nil, success: Procedure? = nil, failure: ErrorHandler? = nil) {
		synchronizer.synchronizeNotes(prelude: prelude, success: success, failure: failure)
	}	
}
