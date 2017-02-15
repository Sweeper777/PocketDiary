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
    
    var selectedText: String {
        return text(in: selectedTextRange!)!
    }
    
    var isSelectingWholeLines: Bool {
        if selectedRange!.location == 0 {
            return true
        }
        
        var pos = position(from: selectedTextRange!.start, offset: -1)!
        while CharacterSet.whitespaces.contains(text(in: textRange(from: pos, to: position(from: pos, offset: 1)!)!)!.unicodeScalars.first!) {
            pos = position(from: pos, offset: -1)!
        }
        return text(in: textRange(from: pos, to: position(from: pos, offset: 1)!)!)! == "\n"
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
        return text.line(at: cursorPosition).trimmingCharacters(in: CharacterSet.whitespaces) == ""
    }
}

extension String {
    func insertLinePrefixes(_ prefix: [Character]) -> String {
        var str = self
        str.insert(contentsOf: prefix, at: str.startIndex)
        
        var index = str.startIndex
        while index != str.endIndex {
            if str.characters[index] == "\n" {
                str.insert(contentsOf: prefix, at: str.index(after: index))
            }
            index = str.index(after: index)
        }
        return str
    }
    
    func line(at position: Int) -> String {
        if characters.count == 0 {
            return ""
        }
        
        if position == 0 {
            return String(characters.split(separator: "\n").first!)
        }
        
        if position == characters.count {
            return line(at: position - 1)
        }
        
        if self.characters[self.characters.index(self.characters.startIndex, offsetBy: position)] == "\n" {
            if self.characters[self.characters.index(self.characters.startIndex, offsetBy: position - 1)] == "\n" {
                return ""
            }
            return line(at: position - 1)
        }
        
        let lines = self.characters.split(separator: "\n")
        var i = 0
        for line in lines {
            for _ in line {
                if i == position {
                    return String(line)
                }
                
                i += 1
            }
            i += 1
        }
        
        fatalError()
    }
}
