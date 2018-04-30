import Cocoa
import os.log

///
/// The Application Delegate of this application.
///
/// HINT: The application main class is MyCloudNotes. This class should only
///       handle GUI aspects of the application.
///
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	// MARK: - Application
	
	///
	/// The main application.
	///
	private var myCloudNotes: MyCloudNotes { get { return MyCloudNotes.shared } }

	// MARK: - Views
	
	///
	/// The ViewController.
	///
	/// Used to access the 'Notes Controller'. The value is injected by the
	/// ViewController.
	///
	/// HINT: What is the 'right' method to access another controller?
	///       In this case a menu entry is connected to an action in this class.
	///       The action redirects to the other controller and its
	///       NSArrayController (IBOutlet).
	///
	var viewController: ViewController?
	
	/// The main window
	///
	private var window: NSWindow { get { return NSApplication.shared.mainWindow! } }
	
	///
	/// The MenuItem to trigger a synchronization
	///
	@IBOutlet weak var synchronizationMenuItem: NSMenuItem!
	
	///
	/// Notification Center.
	///
	let notificationCenter = NotificationCenter.default
	
	// MARK: -
	
	///
	/// Remove all observers
	///
	deinit {
		removeObserverForStatusOfSynchronizationMenuItem()
	}
	
	// MARK: - NSApplicationDelegate
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		
		addObserverForStatusOfSynchronizationMenuItem()

		if UserDefaults.standard.bool(forKey: UserDefaults.MyCloudNotes.Key.synchronizeOnStartAndQuit) {
			// FIXME: Don't use a dummy request to skip the first failed request
			//
			// The first immediate request (Synchronize on start) of this
			// application always fails. To fix this:
			// - Fire a 'dummy' request like ping. Helps
			// - wait a second. Helps
			// - use SessionManager.default in CloudNoteService. Helps.
			//   But this blocks a custom trust policy. Copying and customizing
			//   the code of 'SessionManager.default' doesn't help
			//
			// Scenario: macOS 10.12.6, self signed server certificate from
			//           self signed trusted certificate authority
			//           ('always trusted' in macOS keychain)
			CloudNotesService.standard.sessionManager
				.request(CloudNotesService.Request.ping)
				.responseData { response in self.myCloudNotes.synchronizeNotes() }
		}
	}
	
	///
	/// Synchronize notes and saves changes in the application's managed object
	/// context before the application terminates.
	///
	func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
		
		///
		/// Saves the notes and notifies the application.
		///
		func finalSave() {
			let quitAnyway = self.myCloudNotes.save { error in
				return SaveAlert().selectedQuitAnyway()
			}
			
			NSApplication.shared.reply(toApplicationShouldTerminate: quitAnyway)
		}
		
		if UserDefaults.standard.bool(forKey: UserDefaults.MyCloudNotes.Key.synchronizeOnStartAndQuit) {
			myCloudNotes.synchronizeNotes(
				success: { finalSave() },
				failure: { error in finalSave() } )
		} else {
			finalSave()
		}

		return .terminateLater
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
	// MARK: - Actions
	
	///
	/// Create new note.
	///
	/// Called from menu entry 'New'.
	///
	@IBAction func newNote(_ sender: Any) {
		viewController?.notesController.add(sender)
	}
	
	///
	/// Import notes.
	///
	/// Called from menu entry 'Import…'.
	///
	@IBAction func importNote(_ sender: Any) {
		let panel = NSOpenPanel.forNotes()
		
		panel.beginSheetModal(for: window) { result in
			if result == NSApplication.ModalResponse.OK {
				self.myCloudNotes.importNotes(urls: panel.urls)
			}
		}
	}
	
	///
	/// Export notes.
	///
	/// Called from menu entry 'Export…'.
	///
	@IBAction func exportNote(_ sender: Any) {
		guard
			let selectedObjects = viewController?.notesController.selectedObjects, !selectedObjects.isEmpty,
			let note = selectedObjects[0] as? Note else {
				os_log("Can't export note. Can't find a selected note.", type: .error)
				return
		}
		
		let panel = NSSavePanel(note: note)
		
		panel.beginSheetModal(for: window, completionHandler: { result in
			if result == NSApplication.ModalResponse.OK {
				guard let url = panel.url else {
					os_log("Can't export note. The url is corrupt.", type: .error)
					return
				}

				self.myCloudNotes.exportNote(note: note, url: url)
			}
		})
	}
	
	///
	/// Synchronize notes.
	///
	/// Called from menu entry 'Synchronize'.
	///
	@IBAction func synchronizeNotes(_ sender: NSMenuItem) {
		myCloudNotes.synchronizeNotes()
	}
	
	///
	/// Move focus to search field.
	///
	/// Called from menu entry 'Find note…'
	///
	@IBAction func findNote(_ sender: NSMenuItem) {
		viewController?.searchField.selectText(sender)
	}
}
