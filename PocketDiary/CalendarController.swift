import UIKit
import FSCalendar
import CoreData
import EZSwiftExtensions
import DropDown
import LTHPasscodeViewController
import GoogleMobileAds

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var entries: [Date: Entry] = [:]
    var dateToPass: Date!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var ad: GADBannerView!
    
    override func viewDidLoad() {
        LTHPasscodeViewController.sharedUser().navigationBarTintColor = UIColor(hexString: "5abb5a")
        LTHPasscodeViewController.sharedUser().navigationTitleColor = UIColor.white
        LTHPasscodeViewController.sharedUser().hidesCancelButton = false
        LTHPasscodeViewController.sharedUser().navigationTintColor = UIColor.white
        
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in: dataContext)
        let request = NSFetchRequest<Entry>()
        request.entity = entity
        let anyObjs = try? dataContext.fetch(request)
        if anyObjs != nil {
            anyObjs!.forEach {
                self.entries[$0.date!] = $0
//                print(($0 as! Entry).date!)
            }
        }
        
        if LTHPasscodeViewController.doesPasscodeExist() {
            //if LTHPasscodeViewController.didPasscodeTimerEnd() {
            LTHPasscodeViewController.sharedUser().showLockScreen(withAnimation: true, withLogout: true, andLogoutTitle: nil)
            //}
        }
        
        ad.adUnitID = AdUtility.ad1ID
        ad.rootViewController = self
        ad.load(AdUtility.getRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if calendar.selectedDates.count > 0 {
            calendar.deselect(calendar.selectedDate)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {
        dateToPass = date.ignoreTimeComponents()
        performSegue(withIdentifier: "showEditor", sender: self)
    }
    
    func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
        return entries[date.ignoreTimeComponents()] != nil
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return entries[date.ignoreTimeComponents()] != nil ? 1 : 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditor" {
            let vc = segue.destination as! DataPasserController
            vc.date = dateToPass
            vc.entry = entries[dateToPass]
        }
    }
    
    @IBAction func unwindFromEditor(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? DiaryEditorController {
            if !entries.keys.contains(vc.date) {
                entries[vc.date] = vc.entry
                calendar.reloadData()
            }
            
            if vc.userDeletedEntry {
                entries.removeValue(forKey: vc.date as Date)
                calendar.reloadData()
            }
        }
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showSearch", sender: self)
    }
    
    @IBAction func passcodeSettings(_ sender: UIBarButtonItem) {
        var menuItems = [RWDropdownMenuItem]()
        if LTHPasscodeViewController.doesPasscodeExist() {
            menuItems.append(contentsOf: [
                RWDropdownMenuItem(text: NSLocalizedString("Change Passcode", comment: ""), image: UIImage(named: "change")) {
                        LTHPasscodeViewController.sharedUser().showForChangingPasscode(in: self, asModal: true)
                    },
                    RWDropdownMenuItem(text: NSLocalizedString("Disable Passcode", comment: ""), image: UIImage(named: "remove")) {
                        LTHPasscodeViewController.sharedUser().showForDisablingPasscode(in: self, asModal: true)
                    }
            ])
        } else {
            menuItems.append(
                RWDropdownMenuItem(text: NSLocalizedString("Set Passcode", comment: ""), image: UIImage(named: "key_colored")) {
                    LTHPasscodeViewController.sharedUser().showForEnablingPasscode(in: self, asModal: true)
                }
            )
        }
        
        RWDropdownMenu.present(from: self, withItems: menuItems, align: .left, style: .translucent, navBarImage: nil, completion: nil)
    }
}

extension NSManagedObjectContext {
    func saveData() -> Bool {
        if (try? self.save()) != nil {
            return true
        } else {
            return false
        }
    }
}
