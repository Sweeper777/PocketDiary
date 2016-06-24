import UIKit
import CoreData
import EZLoadingActivity
import LLSwitch
import Emoji

class DiarySearchController: UITableViewController, LLSwitchDelegate {
    var cells: [[UITableViewCell]] = [[], []]
    
    @IBOutlet var searchText: UITextField!
    @IBOutlet var searchRangeLbl: UILabel!
    @IBOutlet var dateRangeLbl: UILabel!
    @IBOutlet var sortModeLbl: UILabel!
    
    var resultsToPass: [Entry]!
    
    func animationDidStopForLLSwitch(llSwitch: LLSwitch!) {
        UserSettings.exactMatch = llSwitch.on
    }
    
    @IBAction func selectSearchRange(sender: UIButton) {
    }
    
    @IBAction func selectDateRange(sender: UIButton) {
    }
    
    @IBAction func selectSortMode(sender: UIButton) {
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
