import CoreData

extension NSManagedObjectContext {
	
	///
	/// Try to save the context.
	///
	@discardableResult
	public func trySave(failure: ErrorHandler? = nil) -> Bool {
		do {
			try save()
			return true
		} catch {
			failure?(error)
			return false
		}
	}
}
