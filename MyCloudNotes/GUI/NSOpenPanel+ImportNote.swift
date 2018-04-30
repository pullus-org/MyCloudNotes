import Cocoa

extension NSOpenPanel {
	
	///
	/// Creates a new panel to load notes.
	///
	static func forNotes() -> NSOpenPanel {
		let panel = NSOpenPanel()
		
		panel.title = "Select text file(s) to import"
		
		panel.allowedFileTypes = [ "txt" ]
		
		panel.showsResizeIndicator = true
		panel.showsHiddenFiles = false
		panel.canCreateDirectories = true
		panel.canChooseDirectories = false
		panel.allowsMultipleSelection = true
		
		return panel
	}
}
