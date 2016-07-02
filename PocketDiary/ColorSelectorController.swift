import UIKit
import DTCollectionViewManager
import DTModelStorage

class ColorSelectorController: UITableViewController, DTCollectionViewManageable {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    var selectedColor: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 400, height: 150)
        
        manager.startManagingWithDelegate(self)
        manager.registerCellClass(ColorCell)
        manager.memoryStorage.addItems(["f4f5fb", "fed1d1", "fe9e9e", "e4bcbc", "cba7a7", "fafed1", "f5fe9e", "e1e4bc", "c8cba7", "d1fed3", "9efea3", "bce4be", "a7cba9", "d1fdfe", "9efdfe", "bce4e4", "a7cacb", "ead1fe", "d49efe", "d2bce4", "bba7cb", "ffffff", "f3f3f3", "dadada", "c0c0c0"].map { UIColor(hexString: $0)! })
        
        manager.cellSelection(ColorSelectorController.selectedColor)
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissVC(completion: nil)
    }
    
    func selectedColor(cell: ColorCell, color: UIColor, indexPath: NSIndexPath) {
        let anim = CABasicAnimation(keyPath: "borderWidth")
        anim.fromValue = 1.5
        anim.toValue = 5
        anim.removedOnCompletion = false
        anim.duration = 0.1
        cell.layer.addAnimation(anim, forKey: nil)
        NSTimer.runThisAfterDelay(seconds: 0.1) {
            cell.layer.borderWidth = 5
        }
        
        NSTimer.runThisAfterDelay(seconds: 0.3) {
            self.selectedColor = color
            self.performSegueWithIdentifier("unwindFromColorSelector", sender: self)
        }
    }
}
