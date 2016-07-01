import UIKit
import DTModelStorage
import DTCollectionViewManager

class ColorCell: UICollectionViewCell, ModelTransfer {
    func updateWithModel(model: UIColor) {
        layer.cornerRadius = self.w / 2
        layer.borderWidth = 3
        self.backgroundColor = model
    }
}
