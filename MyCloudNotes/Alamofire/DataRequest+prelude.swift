import Alamofire

extension DataRequest {
	///
	/// Deposit a block which should be executed immediatly prior sending a
	/// request.
	///
	/// # Use cases
	///
	/// 1. Prelude can be used for symmetrical code/same level.
	/// 2. *NOT IMPLEMENTED*: Prelude can be used as a hook. A block can be
	/// associated with a request and can be executed later with .repsonse…
	///
	/// ````
	/// …request(…)
	///    .prelude  { os_log("start") }
	///    .response { os_log("stop") }
	/// ````
	///
	/// FIXME: The block is executed with this call (prelude). But it should
	///        delay the call until the request is initiated. This is done with
	///        Request.response...
	///
	public func prelude(_ block: Procedure? )  -> Self {
		block?()
		
		return self
	}
}
