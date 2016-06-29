import CoreData
import Foundation
import FSCalendar

struct DiarySearcher {
    let searchText: String
    let exactMatch: Bool
    let searchRange: SearchRange
    let timeRange: TimeRange
    let sortMode: SortMode
    
    func search(dataContext: NSManagedObjectContext) -> [Entry]? {
        // get data
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: dataContext)
        guard let anyObjs = try? dataContext.executeFetchRequest(request) else { return nil }
        let entriesOp = anyObjs.map { $0 as? Entry }
        
        guard !entriesOp.contains({$0 === nil }) else { return nil }
        var entries = entriesOp.map { $0! }
        
        // filter by date
        switch timeRange {
        case .Lifetime:
            break
        default:
            entries = filterByDate(entries)
        }
        
        // filter by search range
        switch searchRange {
        case .ContentOnly:
            entries = filterByContent(entries)
        case .TitleOnly:
            entries = filterByTitle(entries)
        case .TitleAndContent:
            let titleOnlySet = Set(filterByTitle(entries))
            let contentOnlySet = Set(filterByContent(entries))
            entries = Array(titleOnlySet.union(contentOnlySet))
        }
        
        // sort
        switch sortMode {
        case .DateAscending:
            entries.sortInPlace {
                (entry1, entry2) -> Bool in
                return entry1.date!.compare(entry2.date!) == NSComparisonResult.OrderedAscending
            }
        case .DateDescending:
            entries.sortInPlace {
                (entry1, entry2) -> Bool in
                return entry1.date!.compare(entry2.date!) == NSComparisonResult.OrderedDescending
            }
        case .TitleAscending:
            entries.sortInPlace {
                (entry1, entry2) -> Bool in
                return entry1.title!.lowercaseString < entry2.title!.lowercaseString
            }
        case .TitleDescending:
            entries.sortInPlace {
                (entry1, entry2) -> Bool in
                return entry1.title!.lowercaseString > entry2.title!.lowercaseString
            }
        }
        
        return entries
    }
    
    private func filterByDate(entries: [Entry]) -> [Entry] {
        var dateRange: ClosedInterval<NSDate>
        let today = NSDate().fs_dateByIgnoringTimeComponents
        switch timeRange {
        case .Lifetime:
            fatalError()
        case .LastWeek:
            let last7Days = today.fs_dateByAddingDays(-7)
            dateRange = last7Days...today
        case .LastMonth:
            let last30Days = today.fs_dateByAddingDays(-30)
            dateRange = last30Days...today
        case .LastYear:
            let last365Days = today.fs_dateByAddingDays(-365)
            dateRange = last365Days...today
        }
        
        return entries.filter { dateRange.contains($0.date!) }
    }
    
    private func filterByTitle(entries: [Entry]) -> [Entry] {
        return entries.filter { $0.title!.contains(searchText, exactMatch: exactMatch) }
    }
    
    private func filterByContent(entries: [Entry]) -> [Entry] {
        return entries.filter { $0.content!.contains(searchText, exactMatch: exactMatch) }
    }
}

extension String {
    func contains(str: String, exactMatch: Bool) -> Bool {
        if exactMatch {
            return self.rangeOfString(str) != nil
        } else {
            let keywords = str.componentsSeparatedByString(" ").filter {$0 != ""}
            for keyword in keywords {
                if self.rangeOfString(keyword) != nil {
                    return true
                }
            }
            return false
        }
    }
}