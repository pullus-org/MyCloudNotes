extension Note {

	///
	/// Returns a dictionary with 'content', 'category' and 'favorite'.
	///
	/// HINT: The usage of 'Encodable' with Swift 4 is not useful.
	///       The method is used for parameters of HTTP requests with Alamofire.
	///       The parameters can be inserted into an URL or the HTTP-body which
	///       require different encodings. (URLEncoding, JSONEncoding,
	///       PropertyListEncoding)
	///
	public func toJson() -> [String: Any] {
		return [ CloudNotesService.JsonKey.content: contentOrEmpty,
		         CloudNotesService.JsonKey.category: category ?? "",
		         CloudNotesService.JsonKey.favorite: favorite ? "true" : "false" ]
	}
}
