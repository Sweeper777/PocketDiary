import UIKit
import FSCalendar
import CoreData

class ViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var entries: [NSDate: Entry] = [:]
    
    override func viewDidLoad() {
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)
        let request = NSFetchRequest()
        request.entity = entity
        let anyObjs = try? dataContext.executeFetchRequest(request)
        if anyObjs != nil {
            anyObjs!.forEach { entries[($0 as! Entry).date!] = ($0 as! Entry) }
        }
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        
    }
    
    func calendar(calendar: FSCalendar, hasEventForDate date: NSDate) -> Bool {
        return entries[date] != nil
    }
    
    func calendar(calendar: FSCalendar, subtitleForDate date: NSDate) -> String? {
        return entries[date]?.title
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        return entries[date] != nil ? 1 : 0
    }
}

