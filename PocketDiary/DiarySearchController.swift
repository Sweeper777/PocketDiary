import UIKit

class DiarySearchController: UITableViewController {
    var cells: [[UITableViewCell]] = [[], []]
    
    var searchText: UITextField!
    
    override func viewDidLoad() {
        let searchCell = tableView.dequeueReusableCellWithIdentifier("searchCell")!
        let advanced1 = tableView.dequeueReusableCellWithIdentifier("advanced1")!
        let advanced2 = tableView.dequeueReusableCellWithIdentifier("advanced2")!
        let advanced3 = tableView.dequeueReusableCellWithIdentifier("advanced3")!
        
        (advanced1.viewWithTag(1) as! UISwitch).addTarget(self, action: #selector(exactMatchChanged), forControlEvents: .ValueChanged)
        (advanced2.viewWithTag(1) as! UISegmentedControl).addTarget(self, action: #selector(searchInChanged), forControlEvents: .ValueChanged)
        (advanced3.viewWithTag(1) as! UISegmentedControl).addTarget(self, action: #selector(timeRangeChanged), forControlEvents: .ValueChanged)
        (searchCell.viewWithTag(2) as! UIButton).addTarget(self, action: #selector(search), forControlEvents: .TouchUpInside)
        
        searchText = searchCell.viewWithTag(1) as! UITextField
        
        (advanced2.viewWithTag(1) as! UISegmentedControl).apportionsSegmentWidthsByContent = true
        (advanced3.viewWithTag(1) as! UISegmentedControl).apportionsSegmentWidthsByContent = true
        
        addCellToSection(0, cell: tableView.dequeueReusableCellWithIdentifier("searchCell")!)
        addCellToSection(1, cell: tableView.dequeueReusableCellWithIdentifier("advanced1")!)
        addCellToSection(1, cell: advanced2)
        addCellToSection(1, cell: advanced3)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cells.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return cells[indexPath.section][indexPath.row]
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return NSLocalizedString("Advanced", comment: "")
        default:
            return nil
        }
    }

    func addCellToSection(section: Int, cell: UITableViewCell) {
        cells[section].append(cell)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: cells[section].endIndex - 1, inSection: section)], withRowAnimation: .Top)
    }
    
    func removeCellFromSection(section: Int, index: Int) {
        cells[section].removeAtIndex(index)
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: section)], withRowAnimation: .Left)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let reuseId = self.tableView(tableView, cellForRowAtIndexPath: indexPath).reuseIdentifier!
        if ["advanced2", "advanced3"].contains(reuseId) {
            return 65
        } else {
            return 44
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissVC(completion: nil)
    }
    
    @IBAction func search(sender: UIButton) {
        
    }
    
    @IBAction func exactMatchChanged(sender: UISwitch) {
        
    }
    
    @IBAction func searchInChanged(sender: UISegmentedControl) {
        
    }
    
    @IBAction func timeRangeChanged(sender: UISegmentedControl) {
        
    }
}
