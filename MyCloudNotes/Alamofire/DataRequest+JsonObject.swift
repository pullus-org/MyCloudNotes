import Alamofire
import os.log

extension DataRequest {
	
	///
	/// Extension to handle responses with JSON and decode them into objects.
	///
	public struct JsonObject {
		
		///
		/// Possible errors when evaluating the HTTP/JSON response and decode it
		/// into an object.
		///
		enum Failure: String, Error  {
			
			///
			/// The HTTP reponse contains no data.
			///
			case missingData = "Can't evaluate the response. The HTTP response has no data."
			
			///
			/// The JSON reponse can't be build.
			///
			case cantDecode = "Cant' evaluate the repsonse. The decoding of the HTTP/JSON response to an object failed."
			
			///
			/// The log message to the error.
			///
			var message: String { get { return rawValue } }
		}
	}
	
	///
	/// Handle a HTML response as JSON.
	///
	/// The data of the HTML reponse is interpreted as JSON and decoded into
	/// an insance of the generic type (Result).
	///
	/// The completionHandler can access the result at 'response.value'.
	///
	@discardableResult
	public func responseJsonObject<Result: Decodable>(_ resultType: Result.Type, completionHandler: @escaping (_ response: DataResponse<Result>) -> Void) -> Self {
		
		// Custom serializer to calculate the 'DataResponse.result.value' alias 'DataResponse.value'.
		let responseSerializer = DataResponseSerializer<Result> { request, response, data, error in
			guard let data = data else {
				os_log("%{public}@", type: .error, JsonObject.Failure.missingData.message)
				return .failure(JsonObject.Failure.missingData)
			}
			
			guard let result = try? JSONDecoder().decode(Result.self, from: data) else {
				os_log("%{public}@", type: .error, JsonObject.Failure.cantDecode.message)
				return .failure(JsonObject.Failure.cantDecode)
			}
			
			return .success(result)
		}
		
		return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
	}
}
