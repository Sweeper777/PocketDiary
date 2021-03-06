import UIKit
import FSCalendar
import SZTextView
import RealmSwift
import MMMarkdown
import Emoji
import Keyboardy
import GoogleMobileAds
import SwiftyUtils
import SCLAlertView
import FTPopOverMenu_Swift
import SkyFloatingLabelTextField
import RFKeyboardToolbar

class DiaryEditorController: UIViewController, UINavigationControllerDelegate, UIPrintInteractionControllerDelegate, UIWebViewDelegate {
    
    let realm = try! Realm()
    
    var date: LocalDate!
    var bgColor: UIColor?
    var image: Data?
    var imagePositionTop: Bool?
    var entry: Entry!
    var userDeletedEntry = false
    @IBOutlet var txtTitle: SkyFloatingLabelTextField!
    @IBOutlet var txtContent: SZTextView!
    @IBOutlet var preview: UIWebView!
    @IBOutlet var tabs: UISegmentedControl!
    @IBOutlet var deleteBtn: UIBarButtonItem!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var ad: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: date.toDate())
        txtTitle.title = NSLocalizedString("Title", comment: "")
        
        if entry != nil {
            txtTitle.text = entry.title
            txtContent.text = entry.content
            bgColor = entry.bgColor.value?.toColor()
            txtContent.backgroundColor = bgColor ?? UIColor.white
            txtTitle.backgroundColor = bgColor ?? UIColor.white
            image = entry.image as Data?
            imagePositionTop = entry.imagePositionTop
            tabs.selectedSegmentIndex = 1
            txtContent.isHidden = true
            preview.isHidden = false
            dateLabel.isHidden = true
        } else {
            if let index = self.navigationItem.leftBarButtonItems?.firstIndex(of: deleteBtn) {
                self.navigationItem.leftBarButtonItems?.remove(at: index)
            }
        }
        
        txtContent.placeholder = NSLocalizedString("Write your diary here! (Markdown supported!)", comment: "")
//        if #available(iOS 10.0, *) {
//            txtContent.adjustsFontForContentSizeCategory = true
//        } else {
            txtContent.font = UIFont.preferredFont(forTextStyle: .body)
//        }
        
        setUpInputAccessory()
        
        preview.scrollView.showsVerticalScrollIndicator = false
        preview.scrollView.showsHorizontalScrollIndicator = false
        preview.scrollView.bounces = true
        preview.delegate = self
        
        ad.adUnitID = AdUtility.ad2ID
        ad.rootViewController = self
        ad.load(AdUtility.getRequest())
        
        tabs.apportionsSegmentWidthsByContent = true
        updatePreview()
    }
    
    func setUpInputAccessory() {
        let boldButton = RFToolbarButton(title: "B", andEventHandler: {
            if self.txtContent.selectedTextRange!.isEmpty {
                let placeholder = NSLocalizedString("Enter bold text", comment: "")
                self.txtContent.insertText("**\(placeholder)**")
                self.txtContent.moveCursor(by: -2)
                self.txtContent.selectTextBehind(offset: placeholder.count)
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
        
        let codeButton = RFToolbarButton(title: "</>", andEventHandler: {
            if self.txtContent.isCurrentLineEmpty {
                self.txtContent.moveCursorToStartOfLine()
                let placeholder = NSLocalizedString("Enter code", comment: "")
                self.txtContent.insertText("    \(placeholder)")
                self.txtContent.selectTextBehind(offset: placeholder.count)
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
                        self.txtContent.selectTextBehind(offset: placeholder.count)
                    }
                } else {
                    self.txtContent.insertText(self.txtContent.selectedText.insertLinePrefixes([" ", " ", " ", " "]))
                }
            }
        }, for: .touchUpInside)!
        codeButton.titleLabel!.font = UIFont(name: "Courier-Bold", size: 10)
        codeButton.frame = codeButton.frame.with(width: boldButton.width)
        
        let italicButton = RFToolbarButton(title: "I", andEventHandler: {
            if self.txtContent.selectedTextRange!.isEmpty {
                let placeholder = NSLocalizedString("Enter italic text", comment: "")
                self.txtContent.insertText("*\(placeholder)*")
                self.txtContent.moveCursor(by: -1)
                self.txtContent.selectTextBehind(offset: placeholder.count)
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
        italicButton.frame = italicButton.frame.with(width: boldButton.width)
        
        let quoteButton = RFToolbarButton(title: "“", andEventHandler: {
            if self.txtContent.isCurrentLineEmpty {
                self.txtContent.moveCursorToStartOfLine()
                let placeholder = NSLocalizedString("Enter quote", comment: "")
                self.txtContent.insertText("> \(placeholder)")
                self.txtContent.selectTextBehind(offset: placeholder.count)
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
        quoteButton.frame = quoteButton.frame.with(width: boldButton.width)
        
        let linkButton = RFToolbarButton(title: "🔗", andEventHandler: {
            let selectedRange = self.txtContent.selectedTextRange
            if self.txtContent.selectedTextRange!.isEmpty {
                let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                let displayText = alert.addTextField(NSLocalizedString("Display Text", comment: ""))
                let link = alert.addTextField("https://")
                link.text = "https://"
                link.autocapitalizationType = .none
                link.keyboardType = .URL
                link.returnKeyType = .done
                if #available(iOS 10.0, *) {
                    link.textContentType = .URL
                }
                alert.addButton(NSLocalizedString("OK", comment: "")) {
                    self.txtContent.becomeFirstResponder()
                    self.txtContent.selectedTextRange = selectedRange
                    self.txtContent.insertText("[\(displayText.text!)](\(link.text!))")
                }
                alert.addButton(NSLocalizedString("Cancel", comment: "")) {}
                _ = alert.showCustom(NSLocalizedString("Add Link", comment: ""), subTitle: "", color: UIColor(hex: "5abb5a"))
            } else {
                if self.txtContent.selectedText.extractedURLs.count == 1 {
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    let displayText = alert.addTextField(NSLocalizedString("Display Text", comment: ""))
                    alert.addButton(NSLocalizedString("OK", comment: "")) {
                        self.txtContent.becomeFirstResponder()
                        self.txtContent.selectedTextRange = selectedRange
                        self.txtContent.insertText("[\(displayText.text!)](\(self.txtContent.selectedText))")
                    }
                    alert.addButton(NSLocalizedString("Cancel", comment: "")) {}
                    _ = alert.showCustom(NSLocalizedString("Add Link", comment: ""), subTitle: "", color: UIColor(hex: "5abb5a"))
                } else {
                    let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
                    let link = alert.addTextField("https://")
                    link.text = "https://"
                    link.autocapitalizationType = .none
                    link.keyboardType = .URL
                    link.returnKeyType = .done
                    if #available(iOS 10.0, *) {
                        link.textContentType = .URL
                    }
                    alert.addButton(NSLocalizedString("OK", comment: "")) {
                        self.txtContent.becomeFirstResponder()
                        self.txtContent.selectedTextRange = selectedRange
                        self.txtContent.insertText("[\(self.txtContent.selectedText)](\(link.text!))")
                    }
                    alert.addButton(NSLocalizedString("Cancel", comment: "")) {}
                    _ = alert.showCustom(NSLocalizedString("Add Link", comment: ""), subTitle: "", color: UIColor(hex: "5abb5a"))
                }
            }
            self.view.endEditing(true)
        }, for: .touchUpInside)!
        linkButton.titleLabel!.font = UIFont(name: "Symbola", size: 14)
        linkButton.frame = linkButton.frame.with(width: boldButton.width)
        
        let toolbar = RFKeyboardToolbar(buttons: [boldButton, italicButton, quoteButton, codeButton, linkButton])
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
                try! realm.write { [unowned self] in
                    self.realm.delete(entry)
                }
                userDeletedEntry = true
                performSegue(withIdentifier: "unwindFromEditor", sender: self)
            }
            
            return
        }
        
        if entry != nil {
            try! realm.write {
                entry.title = self.txtTitle.text ?? ""
                entry.content = self.txtContent.text ?? ""
                entry.bgColor.value = self.bgColor?.rgb()
                entry.image = self.image
                entry.imagePositionTop = self.imagePositionTop ?? false
            }
        } else {
            entry = Entry()
            entry.title = txtTitle.text ?? ""
            entry.content = txtContent.text ?? ""
            entry.date = self.date
            entry.bgColor.value = self.bgColor?.rgb()
            entry.image = self.image
            entry.imagePositionTop = self.imagePositionTop ?? false
            try! realm.write {
                self.realm.add(entry)
            }
            
        }
        
        performSegue(withIdentifier: "unwindFromEditor", sender: self)
    }
    
    @IBAction func changedTab(_ sender: UISegmentedControl) {
        view.endEditing(true)
        if sender.selectedSegmentIndex == 0 {
            txtContent.isHidden = false
            preview.isHidden = true
            dateLabel.isHidden = false
        } else if sender.selectedSegmentIndex == 1 {
            txtContent.isHidden = true
            preview.isHidden = false
            dateLabel.isHidden = true
            updatePreview()
        }
    }
    
    @IBAction func textChanged(_ sender: AnyObject) {
        updatePreview()
    }
    
    @IBAction func deleteEntry(_ sender: UIBarButtonItem) {
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton: false))
        alert.addButton(NSLocalizedString("Yes, delete it!", comment: "")) {
            if self.entry != nil {
                try! self.realm.write { self.delete(self.entry) }
                self.userDeletedEntry = true
                self.performSegue(withIdentifier: "unwindFromEditor", sender: self)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        alert.addButton(NSLocalizedString("No", comment: ""), action: {})
        _ = alert.showCustom(NSLocalizedString("Delete this?", comment: ""), subTitle: NSLocalizedString("Do you really want to delete this entry?", comment: ""), color: UIColor.red)
    }
    
    @IBAction func showMore(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showOptions", sender: nil)
    }
    
    func updatePreview() {
        view.backgroundColor = bgColor ?? UIColor.white
        preview.backgroundColor = bgColor ?? UIColor.white
        txtTitle.backgroundColor = bgColor ?? UIColor.white
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let dateFormatted = formatter.string(from: date.toDate())
        
        let stylesheet = try! String(contentsOfFile: Bundle.main.path(forResource: "modest", ofType: "css")!)
        
        let contentHtml = (try? MMMarkdown.htmlString(withMarkdown: txtContent.text!, extensions: .gitHubFlavored)) ?? txtContent.text!
        let displayTitleAndContent = "<h1>\(txtTitle.text!)</h1>\(contentHtml)"
        var displayHtml = "&nbsp;&nbsp;&nbsp;&nbsp;\(dateFormatted)<hr>\(displayTitleAndContent)"
        
        if image != nil {
            let base64 = (image! as NSData).base64EncodedString()
            if imagePositionTop! {
                displayHtml = "&nbsp;&nbsp;&nbsp;&nbsp;\(dateFormatted)<hr><img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/>\(displayTitleAndContent)"
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
    
    @IBAction func printDiary() {
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
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .linkClicked {
            UIApplication.shared.openURL(request.url!)
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = (segue.destination as? UINavigationController)?.topViewController as? DiaryOptionsController {
            vc.options = DiaryOptions(backgroundColor: bgColor ?? .white, image: image == nil ? nil : UIImage(data: image!), imagePositionTop: imagePositionTop)
        }
    }
    
    @IBAction func unwindFromOptions(segue: UIStoryboardSegue) {
        let values = (segue.source as! DiaryOptionsController).form.values()
        if let color = values[tagBackgroundColor] as? UIColor {
            txtContent.backgroundColor = color
            txtTitle.backgroundColor = color
            bgColor = color
        }
        
        if let image = values[tagImage] as? UIImage {
            imagePositionTop = (values[tagImagePositionTop] as? String) == NSLocalizedString("Top", comment: "") ? true : false
            self.image = UIImageJPEGRepresentation(image, 0)
        } else {
            self.image = nil
        }
        
        updatePreview()
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

public extension String {
    
    public var extractedURLs: [URL] {
        var urls: [URL] = []
        let detector: NSDataDetector?
        do {
            detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        } catch _ as NSError {
            detector = nil
        }
        let text = self
        if let detector = detector {
            detector.enumerateMatches(in: text, options: [], range: NSRange(location: 0, length: text.count), using: { result, _, _ in
                if let result = result,
                    let url = result.url {
                    urls.append(url as URL)
                }
            })
        }
        return urls
    }
}
