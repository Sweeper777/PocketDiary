import Foundation

class UserSettings {
    static var exactMatch: Bool {
        get { return UserDefaults.standard.bool(forKey: "exactMatch") }
        set { UserDefaults.standard.set(newValue, forKey: "exactMatch") }
    }
    
    static var searchRange: SearchRange {
        get { return SearchRange(rawValue: UserDefaults.standard.integer(forKey: "searchRange"))! }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "searchRange") }
    }
    
    static var timeRange: TimeRange {
        get { return TimeRange(rawValue: UserDefaults.standard.integer(forKey: "timeRange"))! }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "timeRange") }
    }
    
    static var sortMode: SortMode {
        get { return SortMode(rawValue: UserDefaults.standard.integer(forKey: "sortMode"))! }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: "sortMode") }
    }
    
    static var lastUsedBuild: Int {
        get { return UserDefaults.standard.integer(forKey: "lastUsedBuild") }
        set { UserDefaults.standard.set(newValue, forKey: "lastUsedBuild") }
    }
    
    static let searchRangeStrings: [SearchRange: String] = [
        .titleAndContent: "Title and Content",
        .contentOnly: "Content only",
        .titleOnly: "Title only"
    ]
    
    static let timeRangeStrings: [TimeRange: String] = [
        .lifetime: "All",
        .lastYear: "Previous 365 days",
        .lastMonth: "Previous 30 days",
        .lastWeek: "Previous 7 days",
        .custom: "Custom"
    ]
    
    static let sortModeStrings: [SortMode: String] = [
        .relevance: "Relevance",
        .dateAscending: "Earlier → Later",
        .dateDescending: "Later → Earlier",
        .titleAscending: "Title A → Z",
        .titleDescending: "Title Z → A"
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
    case titleAndContent, contentOnly, titleOnly
}

enum TimeRange: Int {
    case lifetime, lastYear, lastMonth, lastWeek, custom
}

enum SortMode: Int {
    case relevance, dateAscending, dateDescending, titleAscending, titleDescending
}
