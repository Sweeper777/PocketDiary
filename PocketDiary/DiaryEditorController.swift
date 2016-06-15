import UIKit
import FSCalendar
import SZTextView
import CoreData
import MMMarkdown

class DiaryEditorController: UITableViewController {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var date: NSDate!
    var entry: Entry!
    var userDeletedEntry = false
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtContent: SZTextView!
    @IBOutlet var preview: UIWebView!
    @IBOutlet var tabs: UISegmentedControl!

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
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return view.frame.height - 75
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
    
    func updatePreview() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date)
        
        let stylesheet = try! String(contentsOfFile: NSBundle.mainBundle().pathForResource("modest", ofType: "css")!)
        
        let mdHtml = try? MMMarkdown.HTMLStringWithMarkdown("\(dateFormatted)\n<hr>\n# \(txtTitle.text!)\n\n\(txtContent.text!)", extensions: .GitHubFlavored) ?? "\(dateFormatted)\n\n\(txtTitle.text!)\n\n\(txtContent.text!)"
        print(mdHtml)
        
        preview.loadHTMLString("<style>\(stylesheet)</style> \(mdHtml!)", baseURL: nil)
    }
}
