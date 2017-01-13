import UIKit
import FSCalendar
import SwiftyUtils

class DateRangeSelectorController: UITableViewController {
    @IBOutlet var startPicker: UIDatePicker!
    @IBOutlet var endPicker: UIDatePicker!
    
    var dateRange: ClosedRange<Date>!

    override func viewDidLoad() {
        super.viewDidLoad()
        startPicker.date = endPicker.date.addingTimeInterval(60 * 60 * 24 * 30)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dateRange = startPicker.date.date...endPicker.date.date
        performSegue(withIdentifier: "unwindDone", sender: self)
    }
    
    @IBAction func startChanged(_ sender: UIDatePicker) {
        endPicker.minimumDate = startPicker.date
    }
    
    @IBAction func endChanged(_ sender: UIDatePicker) {
        startPicker.maximumDate = endPicker.date
    }
}
