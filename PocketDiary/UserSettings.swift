import Foundation

class UserSettings {
    static var exactMatch: Bool {
        get { return NSUserDefaults.standardUserDefaults().boolForKey("exactMatch") }
        set { NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "exactMatch") }
    }
    
    static var searchRange: SearchRange {
        get { return SearchRange(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("searchRange"))! }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "searchRange") }
    }
    
    static var timeRange: TimeRange {
        get { return TimeRange(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("timeRange"))! }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "timeRange") }
    }
    
    static var sortMode: SortMode {
        get { return SortMode(rawValue: NSUserDefaults.standardUserDefaults().integerForKey("sortMode"))! }
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "sortMode") }
    }
    
    static let searchRangeStrings: [SearchRange: String] = [
        .TitleAndContent: "Title and Content",
        .ContentOnly: "Content only",
        .TitleOnly: "Title only"
    ]
    
    static let timeRangeStrings: [TimeRange: String] = [
        .Lifetime: "All",
        .LastYear: "Previous 365 days",
        .LastMonth: "Previous 30 days",
        .LastWeek: "Previous 7 days"
    ]
    
    static let sortModeStrings: [SortMode: String] = [
        .DateAscending: "Earlier → Later",
        .DateDescending: "Later → Earlier",
        .TitleAscending: "Title A → Z",
        .TitleDescending: "Title Z → A"
    ]
    
    static var searchRangeDesc: String {
        return NSLocalizedString(searchRangeStrings[searchRange]!, comment: "")
    }
    
    static var timeRangeDesc: String {
        return NSLocalizedString(timeRangeStrings[timeRange]!, comment: "")
    }
    
    static var sortModeDesc: String {
        return NSLocalizedString(sortModeStrings[sortMode]!, comment: "")
    }
}

enum SearchRange: Int {
    case TitleAndContent, ContentOnly, TitleOnly
}

enum TimeRange: Int {
    case Lifetime, LastYear, LastMonth, LastWeek
}

enum SortMode: Int {
    case DateAscending, DateDescending, TitleAscending, TitleDescending
}