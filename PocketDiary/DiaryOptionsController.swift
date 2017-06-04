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
        
    }
    
}
