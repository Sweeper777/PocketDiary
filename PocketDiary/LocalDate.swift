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
    
    static func from(_ date: Date) -> LocalDate {
        let localDate = LocalDate()
        let components = Calendar(identifier: .gregorian).dateComponents(in: TimeZone.current, from: date)
        localDate.year = components.year!
        localDate.month = components.month!
        localDate.day = components.day!
        return localDate
    }
    
    func toInt() -> Int {
        return year * 10000 + month * 100 + day
    }
    
    override var hash: Int {
        return toInt()
    }
}
