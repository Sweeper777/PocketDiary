import Foundation
import RealmSwift

class LocalDate: Object {
    @objc dynamic var year = 0
    @objc dynamic var month = 0
    @objc dynamic var day = 0
    
    func toDate() -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return Calendar(identifier: .gregorian).date(from: dateComponents)!
    }
}
