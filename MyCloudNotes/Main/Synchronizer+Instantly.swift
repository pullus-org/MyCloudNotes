import CoreData

///
/// Extensions to handle notes changed by the user instantly.
///
extension Synchronizer {

	///
	/// Adds an observer of Core Data to handle changed notes.
	///
	func addObserverForInstantChanges() {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(Synchronizer.contextObjectsDidChange),
			name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
			object: context)
	}
	
	///
	/// Remove the observer of Core Data.
	///
	func removeObserverForInstantChanges() {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
	}
	
	///
	/// Handles notifications about inserted, updated and deleted notes in the
	/// local persistent context.
	///
	/// # Actions
	///
	/// If the notification was triggered by a user:
	/// - new local notes are inserted into the server instantly
	/// - deleted local notes are removed from the server instantly
	/// - updated local notes are updated on the server (not implemented)
	///
	/// If the server/CloudNoteService is not available, the operations are
	/// queued for the next synchronization.
	///
	/// # Conditions
	///
	/// Instead of distinguish the source of the notification, the following
	/// conditions are used.
	///
	/// # Inserts and Updates
	///
	/// The actions for inserts and updates are executed, if the modify time is
	/// after the synchronize time. See Note.hasChangedAfterSynchronization.
	///
	/// This also avoids unnecessary requests. If a new note is posted to the
	/// server, the server returns this note or an update of this note. A
	/// difference between the original note and the returned note would
	/// instantly trigger an updateRemoteNote action. This second request is
	/// unnecessary.
	///
	/// # Deletions
	///
	/// The remote note is delete, if the local not has a valid remote note. The
	/// modification and synchronize time are insignificant.
	///
	@objc
	func contextObjectsDidChange(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		
		if let insertedObjects = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> {
			insertedObjects
				.flatMap { $0 as? Note}
				.filter  { $0.hasChangedAfterSynchronization }
				.forEach { localNoteHasBeenInserted(localNote: $0) }
		}

		if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
			updatedObjects
				.flatMap { $0 as? Note}
				.filter  { $0.hasChangedAfterSynchronization }
				.forEach { localNoteHasBeenUpdated(localNote: $0) }
		}
		
		if let deletedObjects = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> {
			deletedObjects
				.flatMap { $0 as? Note}
				.filter  { $0.hasValidRemoteId }
				.forEach { localNoteHasBeenDeleted(localNote: $0) }
		}
	}
	
	///
	/// Handles an instantly inserted local note.
	///
	private func localNoteHasBeenInserted(localNote: Note) {
		createRemoteNote(localNote: localNote)
	}
	
	///
	/// Handles an instantly upadated local note.
	///
	/// TODO: Implement a smart update policy. Not every keystork should trigger
	///       a remote access.
	///
	private func localNoteHasBeenUpdated(localNote: Note) {
	}
	
	///
	/// Handles an deleted local note.
	///
	/// Deletes a remote note identified by their local counterpart.
	///
	/// If the CloudNotesService can not delete the remote service, the
	/// remote id is stored to delete the remote note later.
	///
	private func localNoteHasBeenDeleted(localNote: Note) {
		guard let remoteId = localNote.remoteId, localNote.hasValidRemoteId else { return }
		
		addDeletion(remoteId: remoteId)
		deleteRemoteNote(noteId: remoteId)
	}
	
	///
	/// Creates and saves a deletion.
	///
	private func addDeletion(remoteId: NSNumber) {
		let _ = Deletion(context: context, remoteId: remoteId)
		
		context.trySave()
	}
}
