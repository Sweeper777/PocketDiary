import UIKit

extension UITextInput {
    var selectedRange: NSRange? {
        guard let range = self.selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
    
    func moveCursor(by x: Int) {
        selectedTextRange = NSRange(location: selectedRange!.location + x, length: 0).toTextRange(textInput: self)
    }
    
    var cursorPosition: Int {
        return selectedRange!.location
    }
    
    func selectTextBehind(offset: Int) {
        selectedTextRange = NSRange(location: cursorPosition - offset, length: offset).toTextRange(textInput: self)
    }
}

extension NSRange {
    func toTextRange(textInput:UITextInput) -> UITextRange? {
        if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
            let rangeEnd = textInput.position(from: rangeStart, offset: length) {
            return textInput.textRange(from: rangeStart, to: rangeEnd)
        }
        return nil
    }
}

extension UITextView {
    func moveCursorToStartOfLine() {
        let range: UITextRange? = selectedTextRange
        let rect: CGRect? = caretRect(for: (range?.start)!)
        let halfLineHeight: CGFloat = font!.lineHeight / 2.0
        let start: UITextPosition? = closestPosition(to: CGPoint(x: CGFloat(0), y: CGFloat(rect!.origin.y + halfLineHeight)))
        selectedTextRange = textRange(from: start!, to: start!)
    }
    
    var isCurrentLineEmpty: Bool {
        if text.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
            return true
        }
        
        var i = 1
        while CharacterSet.whitespacesAndNewlines.contains(text.unicodeScalars[text.unicodeScalars.index(text.unicodeScalars.startIndex, offsetBy: cursorPosition - i)]) {
            i -= 1
        }
        
        if text[cursorPosition - i] == "\n" {
            return true
        }

        return false
    }
}
