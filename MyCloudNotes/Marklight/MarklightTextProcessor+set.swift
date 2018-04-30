import Marklight
import AppKit

extension MarklightTextProcessor {
	
	///
	/// Set default values or custom values.
	///
	func set(textSize aTextSize: CGFloat = 18.0,
	         codeFontName aCodeFontName: String = "Courier",
	         codeColor aCodeColor: NSColor = NSColor.orange,
	         quoteIndendation aQuoteIndendation: CGFloat = 0.0,
	         quoteColor aQuoteColor: NSColor = NSColor.darkGray,
	         syntaxColor aSyntaxColor: NSColor = NSColor.blue,
	         hideSyntax aHideSyntax: Bool = false
		) {
		textSize = aTextSize
		codeFontName = aCodeFontName
		codeColor = aCodeColor
		quoteIndendation = aQuoteIndendation
		quoteColor = aQuoteColor
		syntaxColor = aSyntaxColor
		hideSyntax = aHideSyntax
	}
}

