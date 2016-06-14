import UIKit
import FSCalendar
import SZTextView
import CoreData

class DiaryEditorController: UITableViewController {
    let dataContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var date: NSDate!
    var entry: Entry!
    var userDeletedEntry = false
    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtContent: SZTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        title = formatter.stringFromDate(date)
        
        if entry != nil {
            txtTitle.text = entry.title
            txtContent.text = entry.content
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIApplication.sharedApplication().delegate!.window!!.frame.height - 100
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
}
