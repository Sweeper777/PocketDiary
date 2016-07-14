import UIKit
import CoreData
import EZLoadingActivity
import LLSwitch
import Emoji
import ActionSheetPicker
import EZSwiftExtensions

class DiarySearchController: UITableViewController, LLSwitchDelegate, UITextFieldDelegate {
    var cells: [[UITableViewCell]] = [[], []]
    
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchRangeLbl: UILabel!
    @IBOutlet var dateRangeLbl: UILabel!
    @IBOutlet var sortModeLbl: UILabel!
    @IBOutlet var exactMatch: LLSwitch!
    
    var customDateRange: ClosedInterval<NSDate>?
    
    var resultsToPass: [Entry]!
    
    func valueDidChanged(llSwitch: LLSwitch!, on: Bool) {
        UserSettings.exactMatch = on
    }
    
    override func viewDidLoad() {
        exactMatch.on = UserSettings.exactMatch
        searchRangeLbl.text = NSLocalizedString("Search in: ", comment: "") + UserSettings.searchRangeDesc
        dateRangeLbl.text = NSLocalizedString("Date Range: ", comment: "") + UserSettings.timeRangeDesc
        sortModeLbl.text = NSLocalizedString("Sort: ", comment: "") + UserSettings.sortModeDesc
        searchText.delegate = self
    }
    
    @IBAction func selectSearchRange(sender: UIButton) {
        view.endEditing(true)
        let strs = ["Title and Content", "Content only", "Title only"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.searchRange.rawValue, doneBlock: { (picker, index, value) in
            self.searchRangeLbl.text = NSLocalizedString("Search in: ", comment: "") + (value! as! String)
            UserSettings.searchRange = SearchRange(rawValue: index)!
            }, cancelBlock: nil, origin: sender)
        picker.setDoneButton(getDoneBtn())
        picker.setCancelButton(getCancelBtn())
        picker.showActionSheetPicker()
    }
    
    @IBAction func selectDateRange(sender: UIButton) {
        view.endEditing(true)
        let strs = ["All", "Previous 365 days", "Previous 30 days", "Previous 7 days", "Custom"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.timeRange.rawValue, doneBlock: { (picker, index, value) in
            if index == 4 {
                dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("showDateRangeSelector", sender: self)
                }
                return
            }
            self.dateRangeLbl.text = NSLocalizedString("Date Range: ", comment: "") + (value! as! String)
            UserSettings.timeRange = TimeRange(rawValue: index)!
            }, cancelBlock: nil, origin: sender)
        picker.setDoneButton(getDoneBtn())
        picker.setCancelButton(getCancelBtn())
        picker.showActionSheetPicker()
    }
    
    @IBAction func selectSortMode(sender: UIButton) {
        view.endEditing(true)
        let strs = ["Relevance", "Earlier → Later", "Later → Earlier", "Title A → Z", "Title Z → A"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.sortMode.rawValue, doneBlock: { (picker, index, value) in
            self.sortModeLbl.text = NSLocalizedString("Sort: ", comment: "") + (value! as! String)
            UserSettings.sortMode = SortMode(rawValue: index)!
            }, cancelBlock: nil, origin: sender)
        picker.setDoneButton(getDoneBtn())
        picker.setCancelButton(getCancelBtn())
        picker.showActionSheetPicker()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissVC(completion: nil)
    }
    
    @IBAction func search(sender: UIBarButtonItem) {
        let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let text = searchText.text!.emojiEscapedString
        let searcher = DiarySearcher(searchText: text.emojiUnescapedString,
                                     exactMatch: UserSettings.exactMatch,
                                     searchRange: UserSettings.searchRange,
                                     timeRange: customDateRange == nil ? UserSettings.timeRange : .Custom,
                                     sortMode: UserSettings.sortMode,
                                     customDateRange: self.customDateRange)
        
        let overlay: UIView = UIView(frame: ((UIApplication.sharedApplication().delegate as! AppDelegate).window?.frame)!)
        overlay.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        self.parentViewController!.view.addSubview(overlay)
        overlay.animate(duration: 0.2, animations: {overlay.backgroundColor = overlay.backgroundColor?.colorWithAlphaComponent(0.5)}, completion: nil)
        
        EZLoadingActivity.show(NSLocalizedString("Searching...", comment: ""), disableUI: true);
        
        { searcher.search(dataContext) } ~> {
            EZLoadingActivity.hide()
            self.resultsToPass = $0
            overlay.animate(duration: 0.2, animations: {overlay.backgroundColor = overlay.backgroundColor?.colorWithAlphaComponent(0)}, completion: nil)
            overlay.removeFromSuperview()
            self.performSegueWithIdentifier("showResults", sender: self)
        };
    }
    
    @IBAction func unwindCancel(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindDone(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? DateRangeSelectorController {
            self.customDateRange = vc.dateRange
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .NoStyle
            dateRangeLbl.text = "\(NSLocalizedString("Date Range: ", comment: ""))\(dateFormatter.stringFromDate(customDateRange!.start)) - \(dateFormatter.stringFromDate(customDateRange!.end))"
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SearchResultsController {
            vc.entries = resultsToPass
            vc.searchText = searchText.text!
            vc.searchMode = UserSettings.searchRange
            vc.exactMatch = UserSettings.exactMatch
        }
    }
    
    func getCancelBtn() -> UIBarButtonItem {
        let btn = UIBarButtonItem(barButtonSystemItem: .Cancel, target: nil, action: nil)
        btn.tintColor = UIColor(hexString: "3b7b3b")
        return btn
    }
    
    func getDoneBtn() -> UIBarButtonItem{
        let btn = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: nil)
        btn.tintColor = UIColor(hexString: "3b7b3b")
        return btn
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
