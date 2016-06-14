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
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)
        for i in 0...365 {
            let thatDate = NSDate().fs_dateByIgnoringTimeComponents.fs_dateByAddingDays(i)
            let entry = Entry(entity: entity!, insertIntoManagedObjectContext: dataContext, title: "abcdefghijiklmnopq", content: "ieewhfwefuhwlfnihghfonguehrognrufhgnrgikrfgoinrfhoinergohfingoedhneusfhocncihsfonsifhowfwhrfrghoenrgoeijgjehoirgnhgoengheojgnjehgonoghiegioenghogneoiehfhdifhdhgjernginerglehoigjingoiejgijgiogiejoijgiojijg", date: thatDate)
            entries[thatDate] = entry
        }
        dataContext.saveData()
        print("dataSaved")
        calendar.reloadData()
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