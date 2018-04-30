import Foundation

extension NSLock {

	///
	/// Aquires the lock, executes a closure and releases the lock.
	///
	@discardableResult
	public func perform<Result>(_ closure: () -> Result) -> Result {
		lock()
		defer { unlock() }
		
		return closure()
	}
}
