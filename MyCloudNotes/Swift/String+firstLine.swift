import Foundation

extension String {
	
	///
	/// Returns the first line of a string.
	///
	public var firstLine: String  {
		get { return components(separatedBy: .newlines)[0] }
	}
}
