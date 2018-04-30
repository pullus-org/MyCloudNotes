import Foundation

extension URL {
	
	///
	/// Returns a human readable string.
	///
	/// If the percent encoding can't be removed, return the absolute string.
	///
	public var humanReadableString: String {
		get { return absoluteString.removingPercentEncoding ?? absoluteString }
	}
}
