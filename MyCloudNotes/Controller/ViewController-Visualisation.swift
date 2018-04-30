import Cocoa
import Marklight
import os.log

///
/// Extension to manage the visualisation of the note view.
///
extension ViewController {
	
	///
	/// Possible visualisations.
	///
	enum Visualisation {
		
		///
		/// The standard visualisation/TextStorage.
		///
		case standard
		
		///
		/// The Marklight visualisation/TextStorage.
		///
		case markdown(hideSyntax: Bool)
		
		///
		/// Updates or creates an appropriate TextStorage.
		///
		/// Returns the 'old updated' or a 'new initialized" text storage.
		///
		func createOrUpdate(textStorage: NSTextStorage) -> NSTextStorage {
			switch self {
				
			case .standard:
				guard textStorage is MarklightTextStorage else {
					os_log("Did not create a standard text storage. The storage is already a NSTextStorage.", type: .info)
					return textStorage
				}
				os_log("Create a new NSTextStorage.", type: .info)
				return NSTextStorage()
				
			case .markdown(let hideSyntax):
				if let storage = textStorage as? MarklightTextStorage {
					os_log("Update the current MarklightTextStorage.", type: .info)
					
					storage.marklightTextProcessor.set(hideSyntax: hideSyntax)
					
					return storage
				} else {
					os_log("Create a new MarklightTextStorage", type: .info)

					let storage = MarklightTextStorage()
					storage.marklightTextProcessor.set(hideSyntax: hideSyntax)

					return storage
				}
			}
		}
	}
	
	// MARK: - Key Value Object
	
	///
	/// Starts to observe the user defaults to update the visualisation.
	///
	/// HINT: This call triggers a notification. No initial updateVisualisation
	///       is necessary
	func addObserverForVisualisation() {
		userDefaults.addObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.enableMarkdown, context: nil)
		userDefaults.addObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.hideSyntax, context: nil)
	}
	
	///
	/// Remove observers.
	///
	func removeObserverForVisualisation() {
		userDefaults.removeObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.enableMarkdown)
		userDefaults.removeObserver(self, forKeyPath: UserDefaults.MyCloudNotes.Key.hideSyntax)
	}
	
	///
	/// Observes user defaults to update the visualisation.
	///
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		switch keyPath {
		case .some(UserDefaults.MyCloudNotes.Key.enableMarkdown):
			updateVisualisation()
		case .some(UserDefaults.MyCloudNotes.Key.hideSyntax):
			updateVisualisation()
		default:
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
		}
	}
	
	// MARK: - Visualisation
	
	///
	/// Update the visualisation with the user defaults.
	///
	public func updateVisualisation() {
		set(visualisation: userDefaults.bool(forKey: UserDefaults.MyCloudNotes.Key.enableMarkdown)
			? .markdown(hideSyntax: userDefaults.bool(forKey: UserDefaults.MyCloudNotes.Key.hideSyntax))
			: .standard
		)
	}
	
	///
	/// Set a visualisation for the note view.
	///
	public func set(visualisation: Visualisation) {
		textStorage = visualisation.createOrUpdate(textStorage: textStorage)
		noteText.layoutManager?.replaceTextStorage(textStorage)
		
		redrawSelectedNote()
	}
	
	///
	/// Redraw the selected note/visible note content.
	///
	/// FIXME: Redraw the selected note in a clean solution.
	/// HINT: This is a workaround to redraw the active note text view.
	///       'noteText.needsDisplay', 'display()', using the main-thread
	///       doesn't work.
	private func redrawSelectedNote() {
		guard let selectedObjects = notesController.selectedObjects else {
			os_log("No note to redraw.", type: .info)
			return
		}
		
		notesController.setSelectedObjects([])
		notesController.setSelectedObjects(selectedObjects)
	}
}
