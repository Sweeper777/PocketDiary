import UIKit

class DataPasserController: UINavigationController {

    var date: NSDate!
    var entry: Entry!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = self.topViewController as? DiaryEditorController {
            vc.date = self.date
            vc.entry = self.entry
        }
    }
}
