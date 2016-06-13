import UIKit

class DataPasserController: UINavigationController {

    var date: NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let vc = self.topViewController as? DiaryEditorController {
            vc.date = self.date
        }
    }
}
