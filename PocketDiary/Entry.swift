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
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date!)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.HTMLStringWithMarkdown(content!, extensions: .GitHubFlavored)) ?? content!
        
        let displayTitle = mode == .TitleOnly ? "<span id=\"searchtext\">\(title!)</span>" : title!
        let displayContent = mode == .ContentOnly ? "<span id=\"searchtext\">\(contentHtml)</span>" : contentHtml
        let displayTitleAndContent = mode == .TitleAndContent ? "<span id=\"searchtext\"><h1>\(displayTitle)</h1>\(displayContent)</span>" : "<h1>\(displayTitle)</h1>\(displayContent)"
        let displayHtml = "\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        let ret = "<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)"
        return ret
    }
}