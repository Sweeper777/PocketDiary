import UIKit
import CoreData
import EZLoadingActivity
import LLSwitch
import Emoji
import ActionSheetPicker
import GoogleMobileAds

class DiarySearchController: UITableViewController, LLSwitchDelegate, UITextFieldDelegate {
    var cells: [[UITableViewCell]] = [[], []]
    
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchRangeLbl: UILabel!
    @IBOutlet var dateRangeLbl: UILabel!
    @IBOutlet var sortModeLbl: UILabel!
    @IBOutlet var exactMatch: LLSwitch!
    
    var customDateRange: ClosedRange<Date>?
    
    var resultsToPass: [Entry]!
    
    func valueDidChanged(_ llSwitch: LLSwitch!, on: Bool) {
        UserSettings.exactMatch = on
    }
    
    override func viewDidLoad() {
        exactMatch.on = UserSettings.exactMatch
        searchRangeLbl.text = NSLocalizedString("Search in: ", comment: "") + UserSettings.searchRangeDesc
        dateRangeLbl.text = NSLocalizedString("Date Range: ", comment: "") + UserSettings.timeRangeDesc
        sortModeLbl.text = NSLocalizedString("Sort: ", comment: "") + UserSettings.sortModeDesc
        searchText.delegate = self
    }
    
    @IBAction func selectSearchRange(_ sender: UIButton) {
        view.endEditing(true)
        let strs = ["Title and Content", "Content only", "Title only"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.searchRange.rawValue, doneBlock: { (picker, index, value) in
            self.searchRangeLbl.text = NSLocalizedString("Search in: ", comment: "") + (value! as! String)
            UserSettings.searchRange = SearchRange(rawValue: index)!
            }, cancel: nil, origin: sender)
        picker?.setDoneButton(getDoneBtn())
        picker?.setCancelButton(getCancelBtn())
        picker?.show()
    }
    
    @IBAction func selectDateRange(_ sender: UIButton) {
        view.endEditing(true)
        let strs = ["All", "Previous 365 days", "Previous 30 days", "Previous 7 days", "Custom"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.timeRange.rawValue, doneBlock: { (picker, index, value) in
            if index == 4 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.performSegue(withIdentifier: "showDateRangeSelector", sender: self)
                }
                return
            }
            self.dateRangeLbl.text = NSLocalizedString("Date Range: ", comment: "") + (value! as! String)
            UserSettings.timeRange = TimeRange(rawValue: index)!
            }, cancel: nil, origin: sender)
        picker?.setDoneButton(getDoneBtn())
        picker?.setCancelButton(getCancelBtn())
        picker?.show()
    }
    
    @IBAction func selectSortMode(_ sender: UIButton) {
        view.endEditing(true)
        let strs = ["Relevance", "Earlier → Later", "Later → Earlier", "Title A → Z", "Title Z → A"]
        let localizedStrs = strs.map { NSLocalizedString($0, comment: "") }
        
        let picker = ActionSheetStringPicker(title: nil, rows: localizedStrs, initialSelection: UserSettings.sortMode.rawValue, doneBlock: { (picker, index, value) in
            self.sortModeLbl.text = NSLocalizedString("Sort: ", comment: "") + (value! as! String)
            UserSettings.sortMode = SortMode(rawValue: index)!
            }, cancel: nil, origin: sender)
        picker?.setDoneButton(getDoneBtn())
        picker?.setCancelButton(getCancelBtn())
        picker?.show()
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {
        let dataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
        let text = searchText.text!.emojiEscapedString
        let searcher = DiarySearcher(searchText: text.emojiUnescapedString,
                                     exactMatch: UserSettings.exactMatch,
                                     searchRange: UserSettings.searchRange,
                                     timeRange: customDateRange == nil ? UserSettings.timeRange : .custom,
                                     sortMode: UserSettings.sortMode,
                                     customDateRange: self.customDateRange)
        
        let overlay: UIView = UIView(frame: ((UIApplication.shared.delegate as! AppDelegate).window?.frame)!)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.parent!.view.addSubview(overlay)
        UIView.animate(withDuration: 0.2, animations: {overlay.backgroundColor = overlay.backgroundColor?.withAlphaComponent(0.5)}, completion: nil)
        
        EZLoadingActivity.show(NSLocalizedString("Searching...", comment: ""), disableUI: true);
        
        { searcher.search(dataContext) } ~> {
            EZLoadingActivity.hide()
            self.resultsToPass = $0
            UIView.animate(withDuration: 0.2, animations: {overlay.backgroundColor = overlay.backgroundColor?.withAlphaComponent(0)}, completion: nil)
            overlay.removeFromSuperview()
            self.performSegue(withIdentifier: "showResults", sender: self)
        };
    }
    
    @IBAction func unwindCancel(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindDone(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? DateRangeSelectorController {
            self.customDateRange = vc.dateRange
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            dateRangeLbl.text = "\(NSLocalizedString("Date Range: ", comment: ""))\(dateFormatter.string(from: customDateRange!.lowerBound)) - \(dateFormatter.string(from: customDateRange!.upperBound))"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SearchResultsController {
            vc.entries = resultsToPass
            vc.searchText = searchText.text!
            vc.searchMode = UserSettings.searchRange
            vc.exactMatch = UserSettings.exactMatch
        }
    }
    
    func getCancelBtn() -> UIBarButtonItem {
        let btn = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        btn.tintColor = UIColor(hex: "3b7b3b")
        return btn
    }
    
    func getDoneBtn() -> UIBarButtonItem{
        let btn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        btn.tintColor = UIColor(hex: "3b7b3b")
        return btn
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search(self.navigationItem.rightBarButtonItem!)
        return true
    }
}
