import Foundation
import CoreData
import MMMarkdown
import Emoji

class Entry: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext, title: String, content: String, date: NSDate) {
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.content = content
        self.date = date
        self.title = title
    }
    
    func getDescription() -> String {
        return "\(date)\n\(title)\n\(content)"
    }
    
    override var hashValue: Int {
        return date!.hashValue
    }
    
    func htmlDescriptionForSearchMode(mode: SearchRange) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date!)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        let displayTitle = mode != .ContentOnly ? "<span class=searchtext>\(title!)</span>" : title!
        let displayContent = mode != .TitleOnly ? "<span class=searchtext>\(content!)</span>" : content!
        
        let mdHtml = try? MMMarkdown.HTMLStringWithMarkdown("\(dateFormatted)\n<hr>\n# \(displayTitle)\n\n\(displayContent)", extensions: .GitHubFlavored) ?? "\(dateFormatted)\n\n\(displayTitle)\n\n\(displayContent)"
        
        let js = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("highlight", ofType: "js")!)
        
        return "<script>\(js)</script><style>\(stylesheet)</style> \(mdHtml!.emojiUnescapedString)"

    }
}