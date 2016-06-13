#SearchableTableView: Make your UITableView searchable with few clicks

SearchableTableView is a quick way to add a searching mechanisms to your table views.

## Requirements

- iOS 8.0+
- Xcode 7.2+

## Installation

Just copy SearchableTableView.swift to your project and use it instead of your UITableViews. Or use CocoaPods

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate SearchableTableVIew into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'SearchableTableView'
```

Then, run the following command:

```bash
$ pod install
```
Remember that it's Swift. So you need to use frameworks in your CocoaPods to embed it this way.

## Usage

To use SearchableTableView simply use it instead of UITableView.

To check if user is currently is searching, check your tablesView searchQuery attribute. Easiest way is to implement an additional checking function in your controller like:

```swift
    private func updateValues() {
        if tableView.searchQuery != nil && tableView.searchQuery!.characters.count > 0 {
            if lastQuery == nil || lastQuery != tableView.searchQuery {
                lastQuery = tableView.searchQuery
                currentItems = items.filter({ (item) -> Bool in
                    return item.lowercaseString.containsString(tableView.searchQuery!.lowercaseString)
                })
            }
        } else {
            lastQuery = nil
            currentItems = items
        }
    }
```

And run it when table view is asking you for values

```swift
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateValues()
        return currentItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        updateValues()
        var cell = tableView.dequeueReusableCellWithIdentifier("TestCell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "TestCell")
        }
        
        cell?.textLabel?.text = currentItems[indexPath.row]
        
        return cell!
    }
```

## Credits

SearchableTableView is owned and maintained by the [Nova Project](http://novaproject.net).

## License

SearchableTableView is released under the MIT license. See LICENSE for details.
