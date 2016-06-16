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
}

enum SearchRange: Int {
    case TitleAndContent, ContentOnly, TitleOnly
}

enum TimeRange: Int {
    case Lifetime, LastYear, LastMonth, LastWeek
}