import UIKit
import FSCalendar
import CoreData

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var entries: [NSDate: Entry] = [:]
    var dateToPass: NSDate!
    
    override func viewDidLoad() {
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)
        let request = NSFetchRequest()
        request.entity = entity
        let anyObjs = try? dataContext.executeFetchRequest(request)
        if anyObjs != nil {
            anyObjs!.forEach { entries[($0 as! Entry).date!] = ($0 as! Entry) }
        }
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(editEntry) || action == #selector(viewEntry) || action == #selector(deleteEntry)
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        dateToPass = date
        
        self.becomeFirstResponder()
        if self.calendar(calendar, hasEventForDate: date) {
            let menu = UIMenuController.sharedMenuController()
            let item1 = UIMenuItem(title: NSLocalizedString("View", comment: ""), action: #selector(viewEntry))
            let item2 = UIMenuItem(title: NSLocalizedString("Edit", comment: ""), action: #selector(editEntry))
            let item3 = UIMenuItem(title: NSLocalizedString("Delete", comment: ""), action: #selector(deleteEntry))
            menu.menuItems = [item1, item2, item3]
            menu.setTargetRect(calendar.convertRect(calendar.frameForDate(date), toView: calendar), inView: view)
            menu.arrowDirection = .Down
            menu.update()
            menu.setMenuVisible(true, animated: true)
        } else {
            let menu = UIMenuController.sharedMenuController()
            let item1 = UIMenuItem(title: NSLocalizedString("Compose", comment: ""), action: #selector(editEntry))
            menu.menuItems = [item1]
            menu.setTargetRect(calendar.convertRect(calendar.frameForDate(date), toView: calendar), inView: view)
            menu.arrowDirection = .Down
            menu.update()
            menu.setMenuVisible(true, animated: true)
        }
        
    }
    
    func viewEntry() {
        // TODO: link to ViewEntryController
    }
    
    func editEntry() {
        performSegueWithIdentifier("showEditor", sender: self)
    }
    
    func deleteEntry() {
        let alert = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("Are you sure you want to delete this diary entry?", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .Destructive) {
            _ in
            self.dataContext.deleteObject(self.entries[self.dateToPass]!)
            self.entries[self.dateToPass] = nil
            self.dataContext.saveData()
        })
    }
    
    func calendar(calendar: FSCalendar, hasEventForDate date: NSDate) -> Bool {
        return entries[date] != nil
    }
    
    func calendar(calendar: FSCalendar, subtitleForDate date: NSDate) -> String? {
        return nil
    }
    
    func calendar(calendar: FSCalendar, numberOfEventsForDate date: NSDate) -> Int {
        return entries[date] != nil ? 1 : 0
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEditor" {
            let vc = segue.destinationViewController as! DataPasserController
            vc.date = dateToPass
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
}

extension NSManagedObjectContext {
    func saveData() -> Bool {
        do {
            try self.save()
            return true
        } catch let error as NSError {
            print(error)
            return false;
        }
    }
}