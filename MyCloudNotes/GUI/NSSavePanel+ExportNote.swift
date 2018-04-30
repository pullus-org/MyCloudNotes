import Cocoa

extension NSSavePanel {
	
	///
	/// Creates a new panel to save a single note.
	///
	convenience init(note: Note) {
		self.init()
		
		title = "Export note as..."
		nameFieldStringValue = note.titleOrEmpty
		
		allowedFileTypes = [ "txt" ]
		
		showsResizeIndicator = true
		showsHiddenFiles = false;
		canCreateDirectories = true
	}
}
