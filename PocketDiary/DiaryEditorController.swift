import UIKit
import FSCalendar
import SZTextView
import CoreData
import MMMarkdown
import Emoji
import Keyboardy
import RWDropdownMenu

class DiaryEditorController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var date: NSDate!
    var bgColor: UIColor?
    var image: NSData?
    var imagePositionTop: Bool?
    var entry: Entry!
    var userDeletedEntry = false
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtContent: SZTextView!
    @IBOutlet var preview: UIWebView!
    @IBOutlet var tabs: UISegmentedControl!
    @IBOutlet var deleteBtn: UIBarButtonItem!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        title = formatter.stringFromDate(date)
        
        if entry != nil {
            txtTitle.text = entry.title
            txtContent.text = entry.content
            bgColor = entry.bgColor?.toColor()
            txtContent.backgroundColor = bgColor ?? UIColor.whiteColor()
            image = entry.image
            imagePositionTop = entry.imagePositionTop?.boolValue
            tabs.selectedSegmentIndex = 1
            txtContent.hidden = true
            preview.hidden = false
            updatePreview()
        } else {
            self.navigationItem.leftBarButtonItems?.removeObject(deleteBtn)
        }
        
        txtContent.placeholder = NSLocalizedString("Write your diary here! (Markdown supported!)", comment: "")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        registerForKeyboardNotifications(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: UIBarButtonItem) {
        if txtContent.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" && txtTitle.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
            
            if entry == nil {
                dismissViewControllerAnimated(true, completion: nil)
            } else {
                dataContext.deleteObject(entry)
                dataContext.saveData()
                userDeletedEntry = true
                performSegueWithIdentifier("unwindFromEditor", sender: self)
            }
            
            return
        }
        
        if entry != nil {
            entry.title = txtTitle.text
            entry.content = txtContent.text
            entry.bgColor = bgColor?.rgb()
            entry.image = self.image
            entry.imagePositionTop = self.imagePositionTop
            dataContext.saveData()
        } else {
            entry = Entry(entity: NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)!, insertIntoManagedObjectContext: dataContext, title: txtTitle.text!, content: txtContent.text, date: date)
            entry.bgColor = bgColor?.rgb()
            entry.image = self.image
            entry.imagePositionTop = self.imagePositionTop
            dataContext.saveData()
        }
        
        performSegueWithIdentifier("unwindFromEditor", sender: self)
    }
    
    @IBAction func changedTab(sender: UISegmentedControl) {
        view.endEditing(true)
        if sender.selectedSegmentIndex == 0 {
            txtContent.hidden = false
            preview.hidden = true
        } else if sender.selectedSegmentIndex == 1 {
            txtContent.hidden = true
            preview.hidden = false
            updatePreview()
        }
    }
    
    @IBAction func textChanged(sender: AnyObject) {
        updatePreview()
    }
    
    @IBAction func deleteEntry(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: NSLocalizedString("Delete this?", comment: ""), message: NSLocalizedString("Do you really want to delete this entry?", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, delete it!", comment: ""), style: .Destructive) {
            _ in
            if self.entry != nil {
                self.dataContext.deleteObject(self.entry)
                self.dataContext.saveData()
                self.userDeletedEntry = true
                self.performSegueWithIdentifier("unwindFromEditor", sender: self)
            } else {
                self.dismissVC(completion: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Cancel, handler: nil))
        
        presentVC(alert)
    }
    
    @IBAction func showMore(sender: UIBarButtonItem) {
        var menuItems = [
            RWDropdownMenuItem(text: NSLocalizedString("Set Background Color", comment: ""), image: UIImage(named: "paint_brush")) {
                dispatch_after(DISPATCH_TIME_NOW, dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("showColorSelector", sender: self)
                }
            }
        ]
        
        if image == nil {
            menuItems.appendContentsOf([
                RWDropdownMenuItem(text: NSLocalizedString("Set Image From Camera", comment: ""), image: UIImage(named: "camera")) {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .Camera
                    self.presentVC(picker)
                },
                
                RWDropdownMenuItem(text: NSLocalizedString("Set Image From Photo Library", comment: ""), image: UIImage(named: "photo_library")) {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .PhotoLibrary
                    self.presentVC(picker)
                }
            ])
        } else {
            menuItems.appendContentsOf([
                RWDropdownMenuItem(text: NSLocalizedString("Move Image to Top", comment: ""), image: UIImage(named: "up")) {
                    self.imagePositionTop = true
                    self.updatePreview()
                },
                
                RWDropdownMenuItem(text: NSLocalizedString("Move Image to Bottom", comment: ""), image: UIImage(named: "down")) {
                    self.imagePositionTop = false
                    self.updatePreview()
                },
                
                RWDropdownMenuItem(text: NSLocalizedString("Remove Image", comment: ""), image: UIImage(named: "remove")) {
                    self.imagePositionTop = nil
                    self.image = nil
                    self.updatePreview()
                }
            ])
        }
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Right, style: .Translucent, navBarImage: nil, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        picker.dismissVC(completion: nil)
        imagePositionTop = true
        self.image = UIImageJPEGRepresentation(image, 0)
        tabs.selectedSegmentIndex = 1
        tabs.sendActionsForControlEvents(.ValueChanged)
    }
    
    func updatePreview() {
        view.backgroundColor = bgColor ?? UIColor.whiteColor()
        preview.backgroundColor = bgColor ?? UIColor.whiteColor()
        
        if preview.hidden {
            return
        }
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        var mdHtml = (try? MMMarkdown.HTMLStringWithMarkdown("\(dateFormatted)<hr>\n# \(txtTitle.text!)\n\n\(txtContent.text!)", extensions: .GitHubFlavored)) ?? "\(dateFormatted)\n\n\(txtTitle.text!)\n\n\(txtContent.text!)"
        
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        bgColor?.getRed(&r, green: &g, blue: &b, alpha: nil)
        let _r = Int(r * 255)
        let _g = Int(g * 255)
        let _b = Int(b * 255)
        
        if image != nil {
            let base64 = image!.base64EncodedString()!
            if imagePositionTop! {
                mdHtml = "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/> \(mdHtml)"
            } else {
                mdHtml += "<img src=\"data:image/jpg;base64,\(base64)\" style=\"max-width: 100%\"/>"
            }
        }
        
        let displayHtml = bgColor == nil ? mdHtml : "<body style=\"background: rgb(\(_r), \(_g), \(_b))\">\(mdHtml)</body>"
        
        preview.loadHTMLString("<style>\(stylesheet)</style> \(displayHtml.emojiUnescapedString)", baseURL: nil)
    }
    
    @IBAction func unwindFromColorSelector(segue: UIStoryboardSegue) {
        if let vc = segue.sourceViewController as? ColorSelectorController {
            txtContent.backgroundColor = vc.selectedColor
            bgColor = vc.selectedColor
            updatePreview()
        }
    }
}

extension DiaryEditorController: KeyboardStateDelegate {
    
    func keyboardWillTransition(state: KeyboardState) {
        // keyboard will show or hide
    }
    
    func keyboardTransitionAnimation(state: KeyboardState) {
        switch state {
        case .ActiveWithHeight(let height):
            bottomConstraint.constant = height + 10
        case .Hidden:
            bottomConstraint.constant = 10
        }
        
        view.layoutIfNeeded()
    }
    
    func keyboardDidTransition(state: KeyboardState) {
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
