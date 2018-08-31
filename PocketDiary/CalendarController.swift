import UIKit
import FSCalendar
import RealmSwift
import LTHPasscodeViewController
import GoogleMobileAds
import FTPopOverMenu_Swift

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var entries: [LocalDate: Entry] = [:]
    var dateToPass: LocalDate!
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var ad: GADBannerView!
    
//    let passcodeMenu = DropDown()
    
    override func viewDidLoad() {
        LTHPasscodeViewController.sharedUser().navigationBarTintColor = UIColor(hex: "5abb5a")
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
        calendar.appearance.titleFont = UIFont.preferredFont(forTextStyle: .body)
        calendar.appearance.headerTitleFont = UIFont.preferredFont(forTextStyle: .headline)
        calendar.appearance.weekdayFont = UIFont.preferredFont(forTextStyle: .caption1)
        
        ad.adUnitID = AdUtility.ad1ID
        ad.rootViewController = self
        ad.load(AdUtility.getRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if calendar.selectedDates.count > 0 {
            calendar.deselect(calendar.selectedDate!)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
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
        var menuItems = [String]()
        var images = [String]()
        if LTHPasscodeViewController.doesPasscodeExist() {
            menuItems.append(contentsOf: ["Change Passcode", "Disable Passcode"])
            images.append(contentsOf: ["change", "remove"])
        } else {
            menuItems.append("Set Passcode")
            images.append("key_colored")
        }
        
        let widths = menuItems.map { (NSLocalizedString($0, comment: "") as NSString).size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]).width }
        let menuWidth = widths.max()! + 70
        let config = FTConfiguration.shared
        config.menuWidth = menuWidth
        config.backgoundTintColor = #colorLiteral(red: 0.8242458767, green: 0.8242458767, blue: 0.8242458767, alpha: 1)
        FTPopOverMenu.showForSender(sender: sender.value(forKey: "view") as! UIView, with: menuItems.map { NSLocalizedString($0, comment: "") }, menuImageArray: images, done: { index in
            let item = menuItems[index]
            switch item {
            case "Change Passcode":
                LTHPasscodeViewController.sharedUser().showForChangingPasscode(in: self, asModal: true)
            case "Disable Passcode":
                LTHPasscodeViewController.sharedUser().showForDisablingPasscode(in: self, asModal: true)
            case "Set Passcode":
                LTHPasscodeViewController.sharedUser().showForEnablingPasscode(in: self, asModal: true)
            default:
                break
            }
        }, cancel: {})
    }
}
