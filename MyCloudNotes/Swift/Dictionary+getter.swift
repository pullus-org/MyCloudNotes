import Foundation

extension Dictionary where Value == Any {
	
	///
	/// Returns the value as a specific type.
	///
	/// Returns nil, if no value is given or the value is not the specific type.
	///
	public func value<V>(forKey aKey: Key) -> V? {
		return self[aKey] as? V
	}
}
