import UIKit
import FSCalendar
import CoreData
import LTHPasscodeViewController
import GoogleMobileAds

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var entries: [Date: Entry] = [:]
    var dateToPass: Date!
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
        if LTHPasscodeViewController.doesPasscodeExist() {
            menuItems.append(contentsOf: ["Change Passcode", "Disable Passcode"])
        } else {
            menuItems.append("Set Passcode")
        }
        
        let widths = menuItems.map { (NSLocalizedString($0, comment: "") as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width }
        let menuWidth = widths.max()! + 70
        
//        passcodeMenu.anchorView = sender
//        passcodeMenu.dataSource = menuItems
//        passcodeMenu.width = menuWidth as CGFloat?
//        passcodeMenu.cellNib = UINib(nibName: "MoreMenuItem", bundle: nil)
//        passcodeMenu.customCellConfiguration = {
//            _, item, cell in
//            guard let menuItemCell = cell as? MoreMenuItem else { return }
//            menuItemCell.optionLabel.text = NSLocalizedString(item, comment: "")
//            switch item {
//            case "Change Passcode":
//                menuItemCell.icon.image = UIImage(named: "change")
//            case "Disable Passcode":
//                menuItemCell.icon.image = UIImage(named: "remove")
//            case "Set Passcode":
//                menuItemCell.icon.image = UIImage(named: "key_colored")
//            default:
//                break
//            }
//        }
//        
//        passcodeMenu.selectionAction = {
//            [unowned self] index, item in
//            switch item {
//            case "Change Passcode":
//                LTHPasscodeViewController.sharedUser().showForChangingPasscode(in: self, asModal: true)
//            case "Disable Passcode":
//                LTHPasscodeViewController.sharedUser().showForDisablingPasscode(in: self, asModal: true)
//            case "Set Passcode":
//                LTHPasscodeViewController.sharedUser().showForEnablingPasscode(in: self, asModal: true)
//            default:
//                break
//            }
//        }
//        
//        passcodeMenu.show()
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
