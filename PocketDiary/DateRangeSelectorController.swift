import UIKit

class DateRangeSelectorController: UITableViewController {
    @IBOutlet var startPicker: UIDatePicker!
    @IBOutlet var endPicker: UIDatePicker!
    
    var dateRange: ClosedInterval<NSDate>!

    override func viewDidLoad() {
        super.viewDidLoad()
        startPicker.date = endPicker.date.fs_dateByAddingDays(-30)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dateRange = startPicker.date.fs_dateByIgnoringTimeComponents...endPicker.date.fs_dateByIgnoringTimeComponents
        performSegueWithIdentifier("unwindDone", sender: self)
    }
    
    @IBAction func startChanged(sender: UIDatePicker) {
        endPicker.minimumDate = startPicker.date
    }
    
    @IBAction func endChanged(sender: UIDatePicker) {
        startPicker.maximumDate = endPicker.date
    }
}
