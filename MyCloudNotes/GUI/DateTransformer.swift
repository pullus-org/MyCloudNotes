import Foundation

///
/// A date transformer used for notes in a table.
///
/// - SeeAlso: 'Modified Field' of 'Notes Table' of 'Main View'
///
@objc(DateTransformer)
class DateTransformer: ValueTransformer {
	
	///
	/// A formatter with the 'medium' date style and 'no' time style.
	///
	static let formatter: DateFormatter = {
		let formatter = DateFormatter()
		
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		formatter.doesRelativeDateFormatting = true
		
		return formatter
	}()
	
	override func transformedValue(_ value: Any?) -> Any? {
		guard let date = value as? Date else {
			return value
			
		}
		
		return DateTransformer.formatter.string(from: date)
	}
}
