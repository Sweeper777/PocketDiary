import UIKit
import DTModelStorage
import DTCollectionViewManager

class ColorCell: UICollectionViewCell, ModelTransfer {
    func updateWithModel(_ model: UIColor) {
        layer.cornerRadius = self.w / 2
        layer.borderWidth = 1.5
        self.backgroundColor = model
    }
}
