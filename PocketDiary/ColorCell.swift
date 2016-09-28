import UIKit
import DTModelStorage
import DTCollectionViewManager

class ColorCell: UICollectionViewCell, ModelTransfer {
    typealias ModelType = UIColor

    func update(with model: UIColor) {
        layer.cornerRadius = self.w / 2
        layer.borderWidth = 1.5
        self.backgroundColor = model
    }
}
