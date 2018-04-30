import Cocoa
import Marklight

///
/// The View Controller of the main view.
///
class ViewController: NSViewController {
	
	typealias SELF = ViewController
	
	// MARK: - Application
	
	///
	/// The main application.
	///
	private var myCloudNotes: MyCloudNotes { get { return MyCloudNotes.shared } }
	
	// MARK: - Notifications
	
	///
	/// Notification Center.
	///
	let notificationCenter = NotificationCenter.default
	
	// MARK: -
	
	var userDefaults:UserDefaults { get { return UserDefaults.standard } }
	
	// MARK: - Core Data
	
	///
	/// The Core Data Context.
	///
	/// HINT: The 'Notes Controller' binds this context.
	///
	@objc
	public let context = MyCloudNotes.shared.context
	
	// MARK: - Views
	
	///
	/// The TextStorage of noteText.
	///
	/// Used to hold a default TextStorage or a Marklight-TextStorage.
	///
	/// HINT: It seems that a TextView only keeps a weak reference, so the
	///       TextStorage is keept her.
	///
	var textStorage = NSTextStorage()
	
	// MARK: - Outlets
	
	///
	/// Displays the content of a note.
	///
	@IBOutlet var noteText: NSTextView!
	
	///
	/// The 'Notes Controller'.
	///
	@IBOutlet var notesController: NSArrayController!
	
	///
	/// Status indicator of the CloudNotesService.
	///
	@IBOutlet weak var statusIndicator: NSImageView!

	///
	/// Search field for notes.
	///
	@IBOutlet weak var searchField: NSSearchField!

	///
	/// Button to trigger the synchronization.
	///
	@IBOutlet weak var synchronizationButton: NSButton!
	
	///
	/// Spinner to indicate a running synchronization
	///
	@IBOutlet weak var synchronizationIndicator: NSProgressIndicator!
	
	// MARK: -
	
	///
	/// Remove all observers
	///
	deinit {
		removeObserverForVisualisation()
		removeObserverForStatusIndicator()
		removeObserverForSynchronizationAnimation()
	}
	
	// MARK: - ViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Initial sort by 'modified'
		// TODO: Update order after changing a note
		notesController.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: false)]
		notesController.rearrangeObjects()
		
		// HINT: Check if this can be done with the interface builder. Setting
		//       manually 'left', 'right', ... of the 'ClipView Content insets'
		//       doesn't work.
		noteText.textContainerInset = NSSize(width: 20, height: 20)

		addObserverForVisualisation()
		addObserverForStatusIndicator()
		addObserverForSynchronizationAnimation()
		
		// Inject this instance to the AppDelegate instance.
		//
		// HINT: Is this the right approach to connect controllers? Use the
		//       NotificationCenter?
		(NSApplication.shared.delegate as? AppDelegate)?.viewController = self
	}
	
	// HINT: Not used, not called
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	// MARK: - Actions
		
	@IBAction func synchronizeNotes(_ sender: Any?) {
		myCloudNotes.synchronizeNotes(
			success: {
				self.synchronizationButton.isEnabled = true
		})
	}
}
