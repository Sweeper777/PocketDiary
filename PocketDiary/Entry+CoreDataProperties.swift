import Foundation
import CoreData

extension Entry {

    @NSManaged var content: String?
    @NSManaged var date: Date?
    @NSManaged var title: String?
    @NSManaged var bgColor: NSNumber?
    @NSManaged var image: Data?
    @NSManaged var imagePositionTop: NSNumber?

}
