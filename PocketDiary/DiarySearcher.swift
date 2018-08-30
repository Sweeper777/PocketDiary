import RealmSwift
import Foundation
import FSCalendar

struct DiarySearcher {
    let searchText: String
    let exactMatch: Bool
    let searchRange: SearchRange
    let timeRange: TimeRange
    let sortMode: SortMode
    let customDateRange: ClosedRange<Date>?
    
    func search() -> [Int]? {
        // get data
        guard let realm = try? Realm() else { return nil }
        var entries = Array(realm.objects(Entry.self))
        
        // filter by date
        switch timeRange {
        case .lifetime:
            break
        default:
            entries = filterByDate(entries)
        }
        
        // filter by search range
        switch searchRange {
        case .contentOnly:
            entries = filterByContent(entries)
        case .titleOnly:
            entries = filterByTitle(entries)
        case .titleAndContent:
            let titleOnlySet = Set(filterByTitle(entries))
            let contentOnlySet = Set(filterByContent(entries))
            entries = Array(titleOnlySet.union(contentOnlySet))
        }
        
        // sort
        switch sortMode {
        case .dateAscending:
            entries.sort {
                (entry1, entry2) -> Bool in
                return entry1.date!.toDate() < entry2.date!.toDate()
            }
        case .dateDescending:
            entries.sort {
                (entry1, entry2) -> Bool in
                return entry1.date!.toDate() > entry2.date!.toDate()
            }
        case .titleAscending:
            entries.sort {
                (entry1, entry2) -> Bool in
                return entry1.title.lowercased() < entry2.title.lowercased()
            }
        case .titleDescending:
            entries.sort {
                (entry1, entry2) -> Bool in
                return entry1.title.lowercased() > entry2.title.lowercased()
            }
        case .relevance:
            entries.sort {
                entry1, entry2 in
                switch self.searchRange {
                case .titleOnly:
                    return entry1.title.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch) > entry2.title.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch)
                case .contentOnly:
                    return entry1.content.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch) > entry2.content.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch)
                case .titleAndContent:
                    let occurrencesIn1 = entry1.title.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch) + entry1.content.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch)
                    let occurrencesIn2 = entry2.title.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch) + entry2.content.numberOfOccurrencesOfSubstring(self.searchText, exactMatch: self.exactMatch)
                    return occurrencesIn1 > occurrencesIn2
                }
            }
        }
        
        return entries.map { $0.id }
    }
    
    fileprivate func filterByDate(_ entries: [Entry]) -> [Entry] {
        var dateRange: ClosedRange<Date>
        let today = Date()
        switch timeRange {
        case .lifetime:
            fatalError()
        case .lastWeek:
            let last7Days = today.addingTimeInterval(60 * 60 * 24 * -7)
            dateRange = last7Days...today
        case .lastMonth:
            let last30Days = today.addingTimeInterval(60 * 60 * 24 * -30)
            dateRange = last30Days...today
        case .lastYear:
            let last365Days = today.addingTimeInterval(60 * 60 * 24 * -365)
            dateRange = last365Days...today
        case .custom:
            dateRange = customDateRange!
        }
        
        return entries.filter { dateRange.contains($0.date!.toDate()) }
    }
    
    fileprivate func filterByTitle(_ entries: [Entry]) -> [Entry] {
        return entries.filter { $0.title.contains(searchText, exactMatch: exactMatch) }
    }
    
    fileprivate func filterByContent(_ entries: [Entry]) -> [Entry] {
        return entries.filter { $0.content.emojiUnescapedString.contains(searchText, exactMatch: exactMatch) }
    }
}

extension String {
    func contains(_ str: String, exactMatch: Bool) -> Bool {
        if exactMatch {
            return self.range(of: str) != nil
        } else {
            let keywords = str.components(separatedBy: " ").filter {$0 != ""}
            for keyword in keywords {
                if self.lowercased().range(of: keyword.lowercased()) != nil {
                    return true
                }
            }
            return false
        }
    }
    
    func numberOfOccurrencesOfSubstring(_ subString: String, exactMatch: Bool) -> Int {
        if exactMatch {
            return self.components(separatedBy: subString).count - 1
        } else {
            var total = 0
            for keyword in (subString.components(separatedBy: " ").filter { $0 != "" }) {
                total += self.lowercased().components(separatedBy: keyword.lowercased()).count - 1
            }
            return total
        }
    }
}
