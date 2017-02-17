import UIKit
import FSCalendar
import SZTextView
import CoreData
import MMMarkdown
import Emoji
import Keyboardy
import DropDown
import GoogleMobileAds
import RFKeyboardToolbar
import SwiftyUtils

class DiaryEditorController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPrintInteractionControllerDelegate {
    let dataContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var date: Date!
    var bgColor: UIColor?
    var image: Data?
    var imagePositionTop: Bool?
    var entry: Entry!
    var userDeletedEntry = false
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtContent: SZTextView!
    @IBOutlet var preview: UIWebView!
    @IBOutlet var tabs: UISegmentedControl!
    @IBOutlet var deleteBtn: UIBarButtonItem!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var ad: GADBannerView!
    
    let moreMenu = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        title = formatter.string(from: date)
        
        if entry != nil {
            txtTitle.text = entry.title
            txtContent.text = entry.content
            bgColor = entry.bgColor?.toColor()
            txtContent.backgroundColor = bgColor ?? UIColor.white
            txtTitle.backgroundColor = bgColor ?? UIColor.white
            image = entry.image as Data?
            imagePositionTop = entry.imagePositionTop?.boolValue
            tabs.selectedSegmentIndex = 1
            txtContent.isHidden = true
            preview.isHidden = false
        } else {
            _ = self.navigationItem.leftBarButtonItems?.remove(object: deleteBtn)
        }
        
        txtContent.placeholder = NSLocalizedString("Write your diary here! (Markdown supported!)", comment: "")
        
        setUpInputAccessory()
        
        preview.scrollView.showsVerticalScrollIndicator = false
        preview.scrollView.showsHorizontalScrollIndicator = false
        preview.scrollView.bounces = true
        
        ad.adUnitID = AdUtility.ad2ID
        ad.rootViewController = self
        ad.load(AdUtility.getRequest())
        
        tabs.apportionsSegmentWidthsByContent = true
        updatePreview()
    }
    
    func setUpInputAccessory() {
        let codeButton = RFToolbarButton(title: "</>", andEventHandler: {
            if self.txtContent.isCurrentLineEmpty {
                self.txtContent.moveCursorToStartOfLine()
                let placeholder = NSLocalizedString("Enter code", comment: "")
                self.txtContent.insertText("    \(placeholder)")
                self.txtContent.selectTextBehind(offset: placeholder.characters.count)
            } else {
                if !self.txtContent.isSelectingWholeLines {
                    if !self.txtContent.selectedTextRange!.isEmpty {
                        let range = self.txtContent.selectedRange
                        self.txtContent.moveCursor(by: range.length)
                        self.txtContent.insertText("`")
                        self.txtContent.moveCursor(by: -1 - range.length)
                        self.txtContent.insertText("`")
                        self.txtContent.moveCursor(by: range.length + 1)
                    } else {
                        let placeholder = NSLocalizedString("Enter code", comment: "")
                        self.txtContent.insertText("`\(placeholder)`")
                        self.txtContent.moveCursor(by: -1)
                        self.txtContent.selectTextBehind(offset: placeholder.characters.count)
                    }
                } else {
                    self.txtContent.insertText(self.txtContent.selectedText.insertLinePrefixes([" ", " ", " ", " "]))
                }
            }
        }, for: .touchUpInside)!
        codeButton.titleLabel!.font = UIFont(name: "Courier-Bold", size: 10)
        
        let boldButton = RFToolbarButton(title: "B", andEventHandler: {
            if self.txtContent.selectedTextRange!.isEmpty {
                let placeholder = NSLocalizedString("Enter bold text", comment: "")
                self.txtContent.insertText("**\(placeholder)**")
                self.txtContent.moveCursor(by: -2)
                self.txtContent.selectTextBehind(offset: placeholder.characters.count)
            } else {
                let range = self.txtContent.selectedRange
                self.txtContent.moveCursor(by: range.length)
                self.txtContent.insertText("**")
                self.txtContent.moveCursor(by: -2 - range.length)
                self.txtContent.insertText("**")
                self.txtContent.moveCursor(by: range.length + 2)
            }
        }, for: .touchUpInside)!
        boldButton.titleLabel!.font = UIFont(name: "Baskerville-Bold", size: 14)
        boldButton.frame = boldButton.frame.with(width: codeButton.width)
        
        let italicButton = RFToolbarButton(title: "I", andEventHandler: {
            if self.txtContent.selectedTextRange!.isEmpty {
                let placeholder = NSLocalizedString("Enter italic text", comment: "")
                self.txtContent.insertText("*\(placeholder)*")
                self.txtContent.moveCursor(by: -1)
                self.txtContent.selectTextBehind(offset: placeholder.characters.count)
            } else {
                let range = self.txtContent.selectedRange
                self.txtContent.moveCursor(by: range.length)
                self.txtContent.insertText("*")
                self.txtContent.moveCursor(by: -1 - range.length)
                self.txtContent.insertText("*")
                self.txtContent.moveCursor(by: range.length + 1)
            }
        }, for: .touchUpInside)!
        italicButton.titleLabel!.font = UIFont(name: "Baskerville-SemiBoldItalic", size: 14)
        italicButton.frame = italicButton.frame.with(width: codeButton.width)
        
        let quoteButton = RFToolbarButton(title: "“", andEventHandler: {
            if self.txtContent.isCurrentLineEmpty {
                self.txtContent.moveCursorToStartOfLine()
                let placeholder = NSLocalizedString("Enter quote", comment: "")
                self.txtContent.insertText("> \(placeholder)")
                self.txtContent.selectTextBehind(offset: placeholder.characters.count)
            } else {
                if !self.txtContent.isSelectingWholeLines {
                    let cursorPosition = self.txtContent.cursorPosition
                    self.txtContent.moveCursorToStartOfLine()
                    self.txtContent.insertText("> ")
                    self.txtContent.selectedTextRange = NSRange(location: cursorPosition + 2, length: 0).toTextRange(textInput: self.txtContent)
                } else {
                    self.txtContent.insertText(self.txtContent.selectedText.insertLinePrefixes([">", " "]))
                }
            }
        }, for: .touchUpInside)!
        quoteButton.titleLabel!.font = UIFont(name: "Baskerville-Bold", size: 14)
        quoteButton.frame = quoteButton.frame.with(width: codeButton.width)
        
        let toolbar = RFKeyboardToolbar(buttons: [boldButton, italicButton, quoteButton, codeButton])
        txtContent.inputAccessoryView = toolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        registerForKeyboardNotifications(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        if txtContent.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" && txtTitle.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" && image == nil {
            
            if entry == nil {
                dismiss(animated: true, completion: nil)
            } else {
                dataContext.delete(entry)
                _ = dataContext.saveData()
                userDeletedEntry = true
                performSegue(withIdentifier: "unwindFromEditor", sender: self)
            }
            
            return
        }
        
        if entry != nil {
            entry.title = txtTitle.text
            entry.content = txtContent.text
            entry.bgColor = bgColor?.rgb() as NSNumber?
            entry.image = self.image
            entry.imagePositionTop = self.imagePositionTop as NSNumber?
            _ = dataContext.saveData()
        } else {
            entry = Entry(entity: NSEntityDescription.entity(forEntityName: "Entry", in: dataContext)!, insertIntoManagedObjectContext: dataContext, title: txtTitle.text!, content: txtContent.text, date: date)
            entry.bgColor = bgColor?.rgb() as NSNumber?
            entry.image = self.image
            entry.imagePositionTop = self.imagePositionTop as NSNumber?
            _ = dataContext.saveData()
        }
        
        performSegue(withIdentifier: "unwindFromEditor", sender: self)
    }
    
    @IBAction func changedTab(_ sender: UISegmentedControl) {
        view.endEditing(true)
        if sender.selectedSegmentIndex == 0 {
            txtContent.isHidden = false
            preview.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            txtContent.isHidden = true
            preview.isHidden = false
            updatePreview()
        }
    }
    
    @IBAction func textChanged(_ sender: AnyObject) {
        updatePreview()
    }
    
    @IBAction func deleteEntry(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: NSLocalizedString("Delete this?", comment: ""), message: NSLocalizedString("Do you really want to delete this entry?", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, delete it!", comment: ""), style: .destructive) {
            _ in
            if self.entry != nil {
                self.dataContext.delete(self.entry)
                _ = self.dataContext.saveData()
                self.userDeletedEntry = true
                self.performSegue(withIdentifier: "unwindFromEditor", sender: self)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showMore(_ sender: UIBarButtonItem) {
        
        var menuItems = ["Set Background Color"]
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            menuItems.append("Set Image From Camera")
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            menuItems.append("Set Image From Photo Library")
        }
        
        if image != nil {
            menuItems.append(contentsOf: ["Move Image to Top", "Move Image to Bottom", "Remove Image"])
        }
        
        menuItems.append("Print")
        
        let widths = menuItems.map { (NSLocalizedString($0, comment: "") as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)]).width }
        let menuWidth = widths.max()! + 70
        
        moreMenu.anchorView = self.navigationItem.rightBarButtonItems?.first!
        moreMenu.dataSource = menuItems
        moreMenu.width = menuWidth as CGFloat?
        moreMenu.cellNib = UINib(nibName: "MoreMenuItem", bundle: nil)
        moreMenu.customCellConfiguration = {
            _, item, cell in
            guard let menuItemCell = cell as? MoreMenuItem else { return }
            menuItemCell.optionLabel.text = NSLocalizedString(item, comment: "")
            switch item {
            case "Set Background Color":
                menuItemCell.icon.image = UIImage(named: "paint_brush")
            case "Set Image From Camera":
                menuItemCell.icon.image = UIImage(named: "camera")
            case "Set Image From Photo Library":
                menuItemCell.icon.image = UIImage(named: "photo_library")
            case "Move Image to Top":
                menuItemCell.icon.image = UIImage(named: "up")
            case "Move Image to Bottom":
                menuItemCell.icon.image = UIImage(named: "down")
            case "Remove Image":
                menuItemCell.icon.image = UIImage(named: "remove")
            case "Print":
                menuItemCell.icon.image = UIImage(named: "print")
            default:
                break
            }
        }
        
        moreMenu.selectionAction = {
            [unowned self] index, item in
            switch item {
            case "Set Background Color":
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.performSegue(withIdentifier: "showColorSelector", sender: self)
                }
            case "Set Image From Camera":
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            case "Set Image From Photo Library":
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            case "Move Image to Top":
                self.imagePositionTop = true
                self.updatePreview()
            case "Move Image to Bottom":
                self.imagePositionTop = false
                self.updatePreview()
            case "Remove Image":
                self.imagePositionTop = nil
                self.image = nil
                self.updatePreview()
            case "Print":
                self.printDiary()
            default:
                break
            }
        }
        
        moreMenu.show()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismiss(animated: true, completion: nil)
        imagePositionTop = false
        self.image = UIImageJPEGRepresentation(image, 0)
        tabs.selectedSegmentIndex = 1
        tabs.sendActions(for: .valueChanged)
    }
    
    func updatePreview() {
        view.backgroundColor = bgColor ?? UIColor.white
        preview.backgroundColor = bgColor ?? UIColor.white
        txtTitle.backgroundColor = bgColor ?? UIColor.white
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let dateFormatted = formatter.string(from: date!)
        
        let stylesheet = try! String(contentsOfFile: Bundle.main.path(forResource: "modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.htmlString(withMarkdown: txtContent.text!, extensions: .gitHubFlavored)) ?? txtContent.text!
        let displayTitleAndContent = "<h1>\(txtTitle.text!)</h1>\(contentHtml)"
        var displayHtml = "&nbsp;&nbsp;&nbsp;&nbsp;\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        if image != nil {
            let base64 = (image! as NSData).base64EncodedString()!
            if imagePositionTop! {
                displayHtml = "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/> \(displayHtml)"
            } else {
                displayHtml += "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/>"
            }
        }
        
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        bgColor?.getRed(&r, green: &g, blue: &b, alpha: nil)
        let _r = Int(r * 255)
        let _g = Int(g * 255)
        let _b = Int(b * 255)
        
        displayHtml = bgColor == nil ? displayHtml : "<body style=\"background: rgb(\(_r), \(_g), \(_b))\">\(displayHtml)</body>"
        
        preview.loadHTMLString("<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)", baseURL: nil)
    }
    
    @IBAction func unwindFromColorSelector(_ segue: UIStoryboardSegue) {
        if let vc = segue.source as? ColorSelectorController {
            txtContent.backgroundColor = vc.selectedColor
            txtTitle.backgroundColor = vc.selectedColor
            bgColor = vc.selectedColor
            updatePreview()
        }
    }
    
    func printDiary() {
        let printController = UIPrintInteractionController.shared
        printController.delegate = self
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = txtTitle.text! == "" ? NSLocalizedString("Untitled Diary", comment: "") : txtTitle.text!
        printController.printInfo = printInfo
        updatePreview()
        let formatter = preview.viewPrintFormatter()
        printController.printFormatter = formatter
        
        (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = UIColor(hex: "5abb5a")
        printController.present(animated: true, completionHandler: nil)
    }
    
    func printInteractionControllerDidDismissPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = UIColor(hex: "3b7b3b")
    }
}

extension DiaryEditorController: KeyboardStateDelegate {
    
    func keyboardWillTransition(_ state: KeyboardState) {
        // keyboard will show or hide
    }
    
    
    
    func keyboardTransitionAnimation(_ state: KeyboardState) {
        switch state {
        case .activeWithHeight(let height):
            bottomConstraint.constant = height + 10
            if height > 60 {
                ad.isHidden = true
            } else {
                ad.isHidden = false
            }
        case .hidden:
            bottomConstraint.constant = 70
            ad.isHidden = false
        }
        
        view.layoutIfNeeded()
    }
    
    func keyboardDidTransition(_ state: KeyboardState) {
        // keyboard animation finished
    }
}

extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            
            let rgb = (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}
