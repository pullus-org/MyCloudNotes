import Foundation

extension Set {
	
	///
	/// Returns a Boolean value that indicates whether the given element exists
	/// (true) in the set or not (false)
	///
	/// Returns false if the optional is nil.
	///
	public func includes(_ element: Element?) -> Bool {
		guard let element = element else { return false }
		
		return contains(element)
	}
}
