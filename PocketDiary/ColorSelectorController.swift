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
        manager.memoryStorage.addItems(["f4f5fb", "ffebeb", "fed1d1", "fe9e9e", "e4bcbc", "cba7a7", "fbffeb", "fafed1", "f5fe9e", "e1e4bc", "c8cba7", "ebfff0", "d1fed3", "9efea3", "bce4be", "a7cba9", "ebf9ff", "d1fdfe", "9efdfe", "bce4e4", "a7cacb", "faebff", "ead1fe", "d49efe", "d2bce4", "bba7cb", "ffffff", "f3f3f3", "dadada", "c0c0c0"].map { UIColor(hexString: $0)! })
        
        manager.cellSelection(ColorSelectorController.selectedColor)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismissVC(completion: nil)
    }
    
    func selectedColor(_ cell: ColorCell, color: UIColor, indexPath: IndexPath) {
        let anim = CABasicAnimation(keyPath: "borderWidth")
        anim.fromValue = 1.5
        anim.toValue = 5
        anim.isRemovedOnCompletion = false
        anim.duration = 0.1
        cell.layer.add(anim, forKey: nil)
        Timer.runThisAfterDelay(seconds: 0.1) {
            cell.layer.borderWidth = 5
        }
        
        Timer.runThisAfterDelay(seconds: 0.3) {
            self.selectedColor = color
            self.performSegueWithIdentifier("unwindFromColorSelector", sender: self)
        }
    }
}
