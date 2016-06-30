import UIKit
import FSCalendar
import SZTextView
import CoreData
import MMMarkdown
import Emoji
import Keyboardy
import RWDropdownMenu

class DiaryEditorController: UIViewController {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var date: NSDate!
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
            dataContext.saveData()
        } else {
            entry = Entry(entity: NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)!, insertIntoManagedObjectContext: dataContext, title: txtTitle.text!, content: txtContent.text, date: date)
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
        }
        
        updatePreview()
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
        let menuItems = [
            RWDropdownMenuItem(text: NSLocalizedString("Set Background Color", comment: ""), image: UIImage(named: "paint_brush")) {
                
            },
            
            RWDropdownMenuItem(text: NSLocalizedString("Set Image From Camera", comment: ""), image: UIImage(named: "camera")) {
                
            },
            
            RWDropdownMenuItem(text: NSLocalizedString("Set Image From Photo Library", comment: ""), image: UIImage(named: "photo_library")) {
                
            }
        ]
        
        RWDropdownMenu.presentFromViewController(self, withItems: menuItems, align: .Right, style: .Translucent, navBarImage: nil, completion: nil)
    }
    
    func updatePreview() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .LongStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        let mdHtml = try? MMMarkdown.HTMLStringWithMarkdown("\(dateFormatted)\n<hr>\n# \(txtTitle.text!)\n\n\(txtContent.text!)", extensions: .GitHubFlavored) ?? "\(dateFormatted)\n\n\(txtTitle.text!)\n\n\(txtContent.text!)"
        
        preview.loadHTMLString("<style>\(stylesheet)</style> \(mdHtml!.emojiUnescapedString)", baseURL: nil)
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
