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
        
        title = NSLocalizedString("Options", comment: "")
        
        form +++ ColorPickerRow(tagBackgroundColor) {
            row in
            row.title = NSLocalizedString("Background Color", comment: "")
            row.value = options.backgroundColor
            
            }
            .cellSetup {
                cell, row in
                let palette1 = ColorPalette(name: NSLocalizedString("Recommended", comment: ""), palette: [
                    ColorSpec(hex: "#f4f5fb", name: "")
                    ])
                let palette2 = ColorPalette(name: NSLocalizedString("Reds", comment: ""), palette: [
                    ColorSpec(hex: "#ffebeb", name: ""),
                    ColorSpec(hex: "#fed1d1", name: ""),
                    ColorSpec(hex: "#fe9e9e", name: ""),
                    ColorSpec(hex: "#e4bcbc", name: ""),
                    ColorSpec(hex: "#cba7a7", name: "")
                    ])
                let palette3 = ColorPalette(name: NSLocalizedString("Yellows", comment: ""), palette: [
                    ColorSpec(hex: "#fbffeb", name: ""),
                    ColorSpec(hex: "#fafed1", name: ""),
                    ColorSpec(hex: "#f5fe9e", name: ""),
                    ColorSpec(hex: "#e1e4bc", name: ""),
                    ColorSpec(hex: "#c8cba7", name: "")
                    ])
                let palette4 = ColorPalette(name: NSLocalizedString("Greens", comment: ""), palette: [
                    ColorSpec(hex: "#ebfff0", name: ""),
                    ColorSpec(hex: "#d1fed3", name: ""),
                    ColorSpec(hex: "#9efea3", name: ""),
                    ColorSpec(hex: "#bce4be", name: ""),
                    ColorSpec(hex: "#a7cba9", name: "")
                    ])
                let palette5 = ColorPalette(name: NSLocalizedString("Blues", comment: ""), palette: [
                    ColorSpec(hex: "#ebf9ff", name: ""),
                    ColorSpec(hex: "#d1fdfe", name: ""),
                    ColorSpec(hex: "#9efdfe", name: ""),
                    ColorSpec(hex: "#bce4e4", name: ""),
                    ColorSpec(hex: "#a7cacb", name: "")
                    ])
                let palette6 = ColorPalette(name: NSLocalizedString("Purples", comment: ""), palette: [
                    ColorSpec(hex: "#faebff", name: ""),
                    ColorSpec(hex: "#ead1fe", name: ""),
                    ColorSpec(hex: "#d49efe", name: ""),
                    ColorSpec(hex: "#d2bce4", name: ""),
                    ColorSpec(hex: "#bba7cb", name: "")
                    ])
                let palette7 = ColorPalette(name:  NSLocalizedString("Grayscale", comment: ""), palette: [
                    ColorSpec(hex: "#ffffff", name: ""),
                    ColorSpec(hex: "#f3f3f3", name: ""),
                    ColorSpec(hex: "#dadada", name: ""),
                    ColorSpec(hex: "#c0c0c0", name: "")
                    ])
                cell.palettes = [palette1, palette2, palette3, palette4, palette5, palette6, palette7]
        }
        
        form +++ ImageRow(tagImage) {
            row in
            row.title = NSLocalizedString("Image (Tap to select)", comment: "")
            row.value = options.image
        }
        
            <<< SegmentedRow<String>(tagImagePositionTop) {
                row in
                row.title = NSLocalizedString("Image Position", comment: "")
                row.options = ["Top", "Bottom"].map { NSLocalizedString($0, comment: "") }
                if let imagePositionTop = options.imagePositionTop {
                    row.value = imagePositionTop ? NSLocalizedString("Top", comment: "") : NSLocalizedString("Bottom", comment: "")
                } else {
                    row.value = NSLocalizedString("Bottom", comment: "")
                }
                row.hidden = Condition.function([tagImage], { (form) -> Bool in
                    return (form.rowBy(tag: tagImage) as! ImageRow).value == nil
                })
        }
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
