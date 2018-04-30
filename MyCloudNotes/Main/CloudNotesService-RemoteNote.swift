import Foundation

extension RemoteNote: Decodable {
	
	enum CodingKeys: CodingKey {
		case id
		case title
		case content
		case category
		case favorite
		case modified
	}
	
	///
	/// Creates a note with values from a decoder.
	///
	/// Reads and sets the 'id', 'title', 'content', 'category', 'favorite' and
	/// 'modified'.
	///
	/// If 'favorite' is missing, it will be set to 'false'.
	/// If the 'id' is missing init will fail.
	///
	convenience init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		self.init(
			id: try NSNumber(value: values.decode(Int64.self, forKey: .id)),
			title: try values.decodeIfPresent(String.self, forKey: .title),
			content: try values.decodeIfPresent(String.self, forKey: .content),
			category: try values.decodeIfPresent(String.self, forKey: .category),
			favorite: try values.decodeIfPresent(Bool.self, forKey: .favorite),
			
			modified: try Date(timeIntervalSince1970: values.decode(Double.self, forKey: .modified))
		)
	}
}
