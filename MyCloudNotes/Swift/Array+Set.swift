import Foundation

extension Array where Element: Hashable {
	
	///
	/// Returns this array as a set.
	///
	public func toSet() -> Set<Element> {
		return Set(self)
	}
}
