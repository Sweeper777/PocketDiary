import UIKit
import FSCalendar

class DateRangeSelectorController: UITableViewController {
    @IBOutlet var startPicker: UIDatePicker!
    @IBOutlet var endPicker: UIDatePicker!
    
    var dateRange: ClosedRange<Date>!

    override func viewDidLoad() {
        super.viewDidLoad()
        startPicker.date = FSCalendar().date(byAddingDays: -30, to: endPicker.date)
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dateRange = FSCalendar().date(byIgnoringTimeComponentsOf: startPicker.date)...FSCalendar().date(byIgnoringTimeComponentsOf: endPicker.date)
        performSegue(withIdentifier: "unwindDone", sender: self)
    }
    
    @IBAction func startChanged(_ sender: UIDatePicker) {
        endPicker.minimumDate = startPicker.date
    }
    
    @IBAction func endChanged(_ sender: UIDatePicker) {
        startPicker.maximumDate = endPicker.date
    }
}
