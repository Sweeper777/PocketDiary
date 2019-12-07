import Foundation
import RealmSwift
import MMMarkdown
import Emoji
import Base64nl

class Entry: Object {

    @objc dynamic var content = ""
    @objc dynamic var date: LocalDate? {
        didSet {
            id = date?.toInt() ?? 0
        }
    }
    @objc dynamic var title = ""
    let bgColor = RealmOptional<Int>()
    @objc dynamic var image: Data? = nil
    @objc dynamic var imagePositionTop = false
    
    @objc dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var hash: Int {
        return id
    }
    
    func htmlDescriptionForSearchMode(_ mode: SearchRange) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let dateFormatted = formatter.string(from: date!.toDate())
        
        let stylesheet = try! String(contentsOfFile: Bundle.main.path(forResource: "modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.htmlString(withMarkdown: content, extensions: .gitHubFlavored)) ?? content
        
        let displayTitle = mode == .titleOnly ? "<span id=\"searchtext\">\(title)</span>" : title
        let displayContent = mode == .contentOnly ? "<span id=\"searchtext\">\(contentHtml)</span>" : contentHtml
        let displayTitleAndContent = mode == .titleAndContent ? "<span id=\"searchtext\"><h1>\(displayTitle)</h1>\(displayContent)</span>" : "<h1>\(displayTitle)</h1>\(displayContent)"
        var displayHtml = "&nbsp;&nbsp;&nbsp;&nbsp;\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        if image != nil {
            let base64 = (image! as NSData).base64EncodedString()!
            if imagePositionTop {
                displayHtml = "<img src=\"data:image/jpg;base64,\(base64)\"/> \(displayHtml)"
            } else {
                displayHtml += "<img src=\"data:image/jpg;base64,\(base64)\"/>"
            }
        }
        
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        bgColor.value?.toColor().getRed(&r, green: &g, blue: &b, alpha: nil)
        let _r = Int(r * 255)
        let _g = Int(g * 255)
        let _b = Int(b * 255)
        
        displayHtml = bgColor.value == nil ? displayHtml : "<body style=\"background: rgb(\(_r), \(_g), \(_b))\">\(displayHtml)</body>"
        
        let ret = "<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)"
        return ret
    }
    
    var htmlDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let dateFormatted = formatter.string(from: date!.toDate())
        
        let stylesheet = try! String(contentsOfFile: Bundle.main.path(forResource: "modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.htmlString(withMarkdown: content, extensions: .gitHubFlavored)) ?? content
        let displayTitleAndContent = "<h1>\(title)</h1>\(contentHtml)"
        var displayHtml = "&nbsp;&nbsp;&nbsp;&nbsp;\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        if image != nil {
            let base64 = (image! as NSData).base64EncodedString()!
            if imagePositionTop {
                displayHtml = "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/> \(displayHtml)"
            } else {
                displayHtml += "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/>"
            }
        }
        
        displayHtml = bgColor.value == nil ? displayHtml : "<body style=\"background: rgb(\(self.bgColor.value!.toColor().redComponent), \(self.bgColor.value!.toColor().greenComponent), \(self.bgColor.value!.toColor().blueComponent))\">\(displayHtml)</body>"
        
        let ret = "<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)"
        return ret
    }
}

extension Int {
    func toColor() -> UIColor {
        let rgbValue = Int32(self)
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
