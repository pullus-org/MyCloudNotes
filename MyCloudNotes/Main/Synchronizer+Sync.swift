import Foundation
import os.log

extension Synchronizer {
	
	///
	/// Synchronizes local and remote notes.
	///
	func synchronizeNotes(prelude: Procedure? = nil, success: Procedure? = nil, failure: ErrorHandler? = nil) {
		CloudNotesService.standard.notes(
			prelude: {
				os_log("Synchronize notes.", type: .info)
				prelude?() },
			success: { notes in
				self.context.performAndWait {
					// Collect remote notes, local notes and deletions
					let remoteNotes = Set(notes)
					
					guard let localNotes = self.context.fetchAll(Note.self)?.toSet() else {
						os_log("Can't synchronize notes. The local notes are not available.", type: .error)
						failure?(Failure.cannotLoadLocalNotes)
						return
					}
					
					guard var deletions = self.context.fetchAll(Deletion.self)?.toSet() else {
						os_log("Can't synchronize notes. The deletions are not available.", type: .error)
						failure?(Failure.cannotLoadDeletions)
						return
					}
					
					// Update deletions
					deletions = self.updateDeletions(remoteNotes: remoteNotes, deletions: deletions)
					
					// Synchronize
					self.synchronize(localNotes: localNotes, remoteNotes: remoteNotes, deletions: deletions)
					
					success?()
				}
		}, failure: { error in
			os_log("Can't synchronize notes. The remote notes are not available. Error ist: '%{public}@'", type: .error, String(describing: error))
			failure?(error)
		})
	}
	
	///
	/// Update deletions.
	///
	/// Remove deletions which have no counterpart in remoteNotes and returns
	/// the deletions with existing remote notes.
	///
	private func updateDeletions(remoteNotes: Set<RemoteNote>, deletions: Set<Deletion>) -> Set<Deletion> {
		let remoteNotesIds = remoteNotes.map { $0.id }.toSet()
		
		deletions
			.filter  { !remoteNotesIds.includes($0.remoteNoteId) }
			.forEach { context.delete($0) }
		
		context.trySave { error in os_log("Can't save deletions to context. Error is '%{public}@'.", type: .error, String(describing: error)) }
		
		return deletions.filter { remoteNotesIds.includes($0.remoteNoteId) }
	}
	
	///
	/// Synchronizes the local and remote notes.
	///
	/// - Parameters:
	///   - localNotes: A list of local notes.
	///   - remoteNotes: A list of remote notes.
	///   - deletions: A list of local deletions
	///
	/// TODO: Add error handling for 'suberrors'
	/// TODO: Implement 13a and 13b
	private func synchronize(localNotes: Set<Note>, remoteNotes: Set<RemoteNote>, deletions: Set<Deletion>) {
		
		let remoteIdsOfDeletions = deletions.flatMap { $0.remoteNoteId }
		let remoteIdsOfRemoteNotes = remoteNotes.flatMap { $0.id }
		let remoteIdsToLocalNotes = localNotes.mapToDictionary { ($0.remoteId, $0) }
		
		// Case 8: Notes which are
		//
		//    'present in the local storage' and 'missing in the remote storage'.
		//
		// are added to the remote storage.
		localNotes
			.filter  { !$0.hasValidRemoteId }
			.forEach { createRemoteNote(localNote: $0) }
		
		//
		// Case 4: Notes which are
		//
		//    'present in the local storage' and 'deleted in the remote storage'.
		//
		// are deleted from the local storage.
		localNotes
			.filter  { $0.hasValidRemoteId }
			.filter  { !remoteIdsOfRemoteNotes.contains($0.remoteId!) }
			.forEach { deleteLocalNote(localNote: $0)}
		
		// Case 3, 13, 15
		remoteNotes.forEach { remoteNote in
			if let localNote = remoteIdsToLocalNotes[remoteNote.id] {
				// Case 3: Notes which are
				//
				//   'present in the local storage' and 'present in the remote storage'.
				//
				// are updated in both storages.
				updateNotes(localNote: localNote, remoteNote: remoteNote)
			} else {
				if remoteIdsOfDeletions.contains(remoteNote.id) {
					// Case 13: Notes which are
					//
					// 		'deleted in the local storage' and 'present in the remote storage'
					//
					// are deleted from the remote storage.
					//
					// The set of 'deletions' is not cleand up. Every deletion is kept. If
					// a note can't be removed from the server, it can be removed in a later
					// synchronization.
					deleteRemoteNote(noteId: remoteNote.id)
				} else {
					// Case 15: Notes which are
					//
					//   'missing in the local storage' and 'present in the remote storage'.
					//
					// are added to the local storage.
					createLocalNote(remoteNote: remoteNote)
				}
			}
		}
	}
	
	///
	/// Updates a local and a remote note.
	///
	private func updateNotes(localNote: Note, remoteNote: RemoteNote) {
		guard let localNoteId = localNote.id else {
			os_log("Can't update Notes. The local note has no id.", type: .error)
			return
		}
		
		switch localNote.compareModification(remoteNote) {
		case .orderedSame:
			os_log("Skip update local note '%{public}@' and remote note '%{public}@'. The modification time is equal.",
				type: .info, localNoteId, remoteNote.id)
			
		case .orderedDescending:
			updateRemoteNote(localNote: localNote)
			
		case .orderedAscending:
			updateLocalNote(localNote: localNote, remoteNote: remoteNote)
		}
	}
	
	///
	/// Updates a local note with a remote note.
	///
	private func updateLocalNote(localNote: Note, remoteNote: RemoteNote) {
		guard let localNoteId = localNote.id else {
			os_log("Can't update the local note. The note has no id.", type: .error)
			return
		}
		
		os_log("Update local note '%{public}@' with remote note '%{public}@'.", type: .info, localNoteId, remoteNote.id)
		
		localNote.overwrite(note: remoteNote)
		context.trySave()
	}
	
	///
	/// Updates a remote note with a local note.
	///
	private func updateRemoteNote(localNote: Note) {
		guard let remoteNoteId = localNote.remoteId else {
			os_log("Can't update remote note. The local note has no remote note id.", type: .error)
			return
		}
		
		guard let localNoteId = localNote.id else {
			os_log("Can't update remote note. The local note has no id.", type: .error)
			return
		}
		
		CloudNotesService.standard.update(
			localNote: localNote,
			prelude: {
				os_log("Update the remote note '%{public}@' with local note '%{public}@'.", type: .info, remoteNoteId, localNoteId) },
			success: { remoteNote in
				os_log("Update the local note '%{public}@' with the updated remote note '%{public}@'.", type: .info, localNoteId, remoteNote.id)
				
				localNote.overwrite(note: remoteNote)
				self.context.trySave()
		},
			failure: { error in
				os_log("Can't update the remote note from local note '%{public}@'. Error '%{public}@'.", type: .error, localNoteId, String(describing: error))
		})
	}
	
	///
	/// Creates a local note from a remote note.
	///
	private func createLocalNote(remoteNote: RemoteNote) {
		let localNote =  Note(context: context)
		
		localNote.overwrite(note: remoteNote)
		context.trySave()
	}
	
	///
	/// Deletes a local note.
	///
	private func deleteLocalNote(localNote: Note) {
		os_log("Delete local note '%{public}@'.", type: .info, localNote.id ?? "?")
		
		// Mark note as synchronized to avoid any further synchronization.
		// See contextObjectsDidChange.
		localNote.synchronized = Date()
		
		context.delete(localNote)
		context.trySave()
	}
	
	///
	/// Creates a remote note from a local note.
	///
	func createRemoteNote(localNote: Note) {
		context.performAndWait {
			guard let localNoteId = localNote.id else {
				os_log("Can't create the remote note. The local note has no id.", type: .error)
				return
			}
			
			CloudNotesService.standard.create(
				localNote: localNote,
				prelude: {
					os_log("Create remote note from local note '%{public}@'.", type: .info, localNoteId) },
				success: { remoteNote in
					os_log("Update the local note '%{public}@' with the created remote note '%{public}@'.", type: .info, localNoteId, remoteNote.id)
					
					localNote.overwrite(note: remoteNote)
					self.context.trySave()
			},
				failure: { error in
					os_log("Can't create remote note from local note '%{public}@'. Error: '%{public}@'.", type: .error, localNoteId, String(describing: error))
			})
		}
	}
	
	///
	/// Deletes a remote note.
	///
	func deleteRemoteNote(noteId: NSNumber) {
		CloudNotesService.standard.delete(
			remoteNoteId: noteId,
			prelude: {
				os_log("Delete remote note '%{public}@'.", type: .info, noteId) }
		)
	}
}
