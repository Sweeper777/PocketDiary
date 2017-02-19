import UIKit
import RFKeyboardToolbar

class CenterItemsToolbar: RFKeyboardToolbar {
    override func addButtons() {
        let buttons = self.buttons.map { $0 as! RFToolbarButton }
        let totalWidth = buttons.reduce(0) { $0 + $1.width + 8 } - 8
        if totalWidth > scrollView.width {
            super.addButtons()
            return
        }
        var originX = (scrollView.width - totalWidth) / 2
        for button in buttons {
            button.x = originX
            button.y = 0
            originX += button.width + 8
            scrollView.addSubview(button)
        }
    }
}
