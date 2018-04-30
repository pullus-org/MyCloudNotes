import Foundation

extension Sequence {
	
	///
	/// Maps a Sequence to a dictionary.
	///
	/// If the key is missing the element (key, value) is not inserted to the
	/// resulting dictionary.
	///
	public func mapToDictionary<Key, Value>(format: (Element)->(Key?, Value)) -> Dictionary<Key, Value> {
		var dictionary = Dictionary<Key, Value>()
		
		map(format).forEach { optionalKey, value in
			if let key = optionalKey { dictionary[key] = value }
		}
		
		return dictionary
	}
}
