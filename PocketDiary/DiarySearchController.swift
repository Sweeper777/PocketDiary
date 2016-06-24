import UIKit
import CoreData
import EZLoadingActivity
import LLSwitch
import Emoji
import ActionSheetPicker

class DiarySearchController: UITableViewController, LLSwitchDelegate {
    var cells: [[UITableViewCell]] = [[], []]
    
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchRangeLbl: UILabel!
    @IBOutlet var dateRangeLbl: UILabel!
    @IBOutlet var sortModeLbl: UILabel!
    @IBOutlet var exactMatch: LLSwitch!
    
    var resultsToPass: [Entry]!
    
    func animationDidStopForLLSwitch(llSwitch: LLSwitch!) {
        UserSettings.exactMatch = llSwitch.on
    }
    
    override func viewDidLoad() {
        exactMatch.on = UserSettings.exactMatch
    }
    
    @IBAction func selectSearchRange(sender: UIButton) {
        let strs = ["Title and Content", "Content only", "Title only"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.searchRange.rawValue, doneBlock: { (picker, index, value) in
            //self.searchRangeLbl.text = NSLocalizedString("Search in: ", comment: "") + (value! as! String)
            UserSettings.searchRange = SearchRange(rawValue: index)!
            }, cancelBlock: nil, origin: sender)
        picker.showActionSheetPicker()
    }
    
    @IBAction func selectDateRange(sender: UIButton) {
        let strs = ["All", "Previous 365 days", "Previous 30 days", "Previous 7 days"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.timeRange.rawValue, doneBlock: { (picker, index, value) in
            //self.dateRangeLbl.text = NSLocalizedString("Date Range: ", comment: "") + (value! as! String)
            UserSettings.timeRange = TimeRange(rawValue: index)!
            }, cancelBlock: nil, origin: sender)
        picker.showActionSheetPicker()
    }
    
    @IBAction func selectSortMode(sender: UIButton) {
        let strs = ["Earlier → Later", "Later → Earlier", "Title A → Z", "Title Z → A"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.sortMode.rawValue, doneBlock: { (picker, index, value) in
            //self.sortModeLbl.text = NSLocalizedString("Sort: ", comment: "") + (value! as! String)
            UserSettings.sortMode = SortMode(rawValue: index)!
            }, cancelBlock: nil, origin: sender)
        picker.showActionSheetPicker()
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissVC(completion: nil)
    }
    
    @IBAction func search(sender: UIButton) {
        let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let text = searchText.text!.emojiEscapedString
        print(text)
        let searcher = DiarySearcher(searchText: text,
                                     exactMatch: UserSettings.exactMatch,
                                     searchRange: UserSettings.searchRange,
                                     timeRange: UserSettings.timeRange,
                                     sortMode: UserSettings.sortMode)
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? SearchResultsController {
            vc.entries = resultsToPass
            vc.searchText = searchText.text!
            vc.searchMode = UserSettings.searchRange
            vc.exactMatch = UserSettings.exactMatch
        }
    }
}
