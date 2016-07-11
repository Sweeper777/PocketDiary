import UIKit
import FSCalendar

class DateRangeSelectorController: UITableViewController {
    @IBOutlet var startPicker: UIDatePicker!
    @IBOutlet var endPicker: UIDatePicker!
    
    var dateRange: ClosedInterval<NSDate>!

    override func viewDidLoad() {
        super.viewDidLoad()
        startPicker.date = FSCalendar().dateByAddingDays(-30, toDate: endPicker.date)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dateRange = FSCalendar().dateByIgnoringTimeComponentsOfDate(startPicker.date)...FSCalendar().dateByIgnoringTimeComponentsOfDate(endPicker.date)
        performSegueWithIdentifier("unwindDone", sender: self)
    }
    
    @IBAction func startChanged(sender: UIDatePicker) {
        endPicker.minimumDate = startPicker.date
    }
    
    @IBAction func endChanged(sender: UIDatePicker) {
        startPicker.maximumDate = endPicker.date
    }
}
