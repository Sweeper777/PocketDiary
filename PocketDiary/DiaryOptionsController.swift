import UIKit
import Eureka
import ImageRow

struct DiaryOptions {
    let backgroundColor: UIColor
    let image: UIImage?
    let imagePositionTop: Bool?
}

class DiaryOptionsController: FormViewController {
    var options: DiaryOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ ColorPickerRow(tagBackgroundColor) {
            row in
            row.title = NSLocalizedString("Background Color", comment: "")
            row.value = options.backgroundColor
            
            }
    }
    
}
