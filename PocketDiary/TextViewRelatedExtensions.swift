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

