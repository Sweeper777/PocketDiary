import UIKit
import FSCalendar
import CoreData
import EZSwiftExtensions

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var entries: [NSDate: Entry] = [:]
    var dateToPass: NSDate!
    @IBOutlet var calendar: FSCalendar!
    
    override func viewDidLoad() {
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)
        let request = NSFetchRequest()
        request.entity = entity
        let anyObjs = try? dataContext.executeFetchRequest(request)
        if anyObjs != nil {
            anyObjs!.forEach { entries[($0 as! Entry).date!] = ($0 as! Entry) }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if calendar.selectedDates.count > 0 {
            calendar.deselectDate(calendar.selectedDate)
        }
    }
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        dateToPass = date
        performSegueWithIdentifier("showEditor", sender: self)
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
            vc.entry = entries[dateToPass]
        }
    }
    
    @IBAction func unwindFromEditor(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? DiaryEditorController {
            if !entries.keys.contains(vc.date) {
                entries[vc.date] = vc.entry
                calendar.reloadData()
            }
            
            if vc.userDeletedEntry {
                entries.removeValueForKey(vc.date)
                calendar.reloadData()
            }
        }
    }
    
    @IBAction func search(sender: UIBarButtonItem) {
        performSegueWithIdentifier("showSearch", sender: self)
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