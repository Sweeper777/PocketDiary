import UIKit
import FSCalendar

class DiaryEditorController: UITableViewController {
    var date: NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        title = formatter.stringFromDate(date)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIApplication.sharedApplication().delegate!.window!!.frame.height - 100
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
