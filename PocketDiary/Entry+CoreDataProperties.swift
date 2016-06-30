import Foundation
import CoreData

extension Entry {

    @NSManaged var content: String?
    @NSManaged var date: NSDate?
    @NSManaged var title: String?
    @NSManaged var bgColor: NSNumber?
    @NSManaged var image: NSData?

}
