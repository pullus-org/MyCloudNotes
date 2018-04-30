import CoreData

extension NSManagedObjectContext {
	
	///
	/// Perform, wait and return a value.
	///
	public func performAndReturn<Result>(_ aBlock: () -> Result) -> Result {
		var result: Result?
		
		performAndWait { result = aBlock() }
		
		return result!
	}
}
