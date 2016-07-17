import UIKit
import FSCalendar
import CoreData
import EZSwiftExtensions
import RWDropdownMenu
import LTHPasscodeViewController
import GoogleMobileAds

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var entries: [NSDate: Entry] = [:]
    var dateToPass: NSDate!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var ad: GADBannerView!
    
    override func viewDidLoad() {
        LTHPasscodeViewController.sharedUser().navigationBarTintColor = UIColor(hexString: "5abb5a")
        LTHPasscodeViewController.sharedUser().navigationTitleColor = UIColor.whiteColor()
        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
        LTHPasscodeViewController.sharedUser().navigationTintColor = UIColor.whiteColor()
        
        let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)
        let request = NSFetchRequest()
        request.entity = entity
        let anyObjs = try? dataContext.executeFetchRequest(request)
        if anyObjs != nil {
            anyObjs!.forEach { entries[($0 as! Entry).date!] = ($0 as! Entry) }
        }
        
        if LTHPasscodeViewController.doesPasscodeExist() {
            //if LTHPasscodeViewController.didPasscodeTimerEnd() {
            LTHPasscodeViewController.sharedUser().showLockScreenWithAnimation(true, withLogout: true, andLogoutTitle: nil)
            //}
        }
        
        ad.adUnitID = AdUtility.ad1ID
        ad.rootViewController = self
        ad.loadRequest(AdUtility.getRequest())
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
    
    @IBAction func passcodeSettings(sender: UIBarButtonItem) {
        var menuItems = [RWDropdownMenuItem]()
        if LTHPasscodeViewController.doesPasscodeExist() {
            menuItems.appendContentsOf([
                RWDropdownMenuItem(text: NSLocalizedString("Change Passcode", comment: ""), image: UIImage(named: "change")) {
                        LTHPasscodeViewController.sharedUser().showForChangingPasscodeInViewController(self, asModal: true)
                    },
                    RWDropdownMenuItem(text: NSLocalizedString("Disable Passcode", comment: ""), image: UIImage(named: "remove")) {
                        LTHPasscodeViewController.sharedUser().showForDisablingPasscodeInViewController(self, asModal: true)
                    }
            ])
        } else {
            menuItems.append(
                RWDropdownMenuItem(text: NSLocalizedString("Set Passcode", comment: ""), image: UIImage(named: "key_colored")) {
                    LTHPasscodeViewController.sharedUser().showForEnablingPasscodeInViewController(self, asModal: true)
                }
            )
        }
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Left, style: .Translucent, navBarImage: nil, completion: nil)
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