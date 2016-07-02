import Foundation
import CoreData
import MMMarkdown
import Emoji
import Base64nl

class Entry: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext, title: String, content: String, date: NSDate) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.content = content
        self.date = date
        self.title = title
        self.imagePositionTop = true
    }
    
    func getDescription() -> String {
        return "\(date)\n\(title)\n\(content)"
    }
    
    override var hashValue: Int {
        return date!.hashValue
    }
    
    func htmlDescriptionForSearchMode(mode: SearchRange) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date!)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.HTMLStringWithMarkdown(content!, extensions: .GitHubFlavored)) ?? content!
        
        let displayTitle = mode == .TitleOnly ? "<span id=\"searchtext\">\(title!)</span>" : title!
        let displayContent = mode == .ContentOnly ? "<span id=\"searchtext\">\(contentHtml)</span>" : contentHtml
        let displayTitleAndContent = mode == .TitleAndContent ? "<span id=\"searchtext\"><h1>\(displayTitle)</h1>\(displayContent)</span>" : "<h1>\(displayTitle)</h1>\(displayContent)"
        var displayHtml = "\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        if image != nil {
            let base64 = image!.base64EncodedString()!
            if imagePositionTop!.boolValue {
                displayHtml = "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/> \(displayHtml)"
            } else {
                displayHtml += "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/>"
            }
        }
        
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        bgColor?.toColor().getRed(&r, green: &g, blue: &b, alpha: nil)
        let _r = Int(r * 255)
        let _g = Int(g * 255)
        let _b = Int(b * 255)
        
        displayHtml = bgColor == nil ? displayHtml : "<body style=\"background: rgb(\(_r), \(_g), \(_b))\">\(displayHtml)</body>"
        
        let ret = "<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)"
        return ret
    }
    
    var htmlDescription: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date!)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.HTMLStringWithMarkdown(content!, extensions: .GitHubFlavored)) ?? content!
        let displayTitleAndContent = "<h1>\(title!)</h1>\(contentHtml)"
        var displayHtml = "\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        if image != nil {
            let base64 = image!.base64EncodedString()!
            if imagePositionTop!.boolValue {
                displayHtml = "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/> \(displayHtml)"
            } else {
                displayHtml += "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/>"
            }
        }
        
        displayHtml = bgColor == nil ? displayHtml : "<body style=\"background: rgb(\(self.bgColor!.toColor().redComponent), \(self.bgColor!.toColor().greenComponent), \(self.bgColor!.toColor().blueComponent))\">\(displayHtml)</body>"
        
        let ret = "<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)"
        return ret
    }
}

extension NSNumber {
    func toColor() -> UIColor {
        let rgbValue = self.intValue
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}