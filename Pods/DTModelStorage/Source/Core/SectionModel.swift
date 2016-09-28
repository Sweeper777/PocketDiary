//
//  SectionModel.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 10.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/// Class represents data of the section used by `MemoryStorage`.
open class SectionModel : Section, SupplementaryAccessible
{
    /// Items for current section
    /// - Warning: If you try to set new array to this property [T], the only way to do this without exception is to wrap it into items.map { $0 }. This is a workaround that exists because of Swift inability to cast [T] to [Any]. You can call `setItems` method instead of doing so.
    /// - SeeAlso: `setItems:`
    open var items = [Any]()

    /// Supplementaries dictionary.
    open var supplementaries = [String:Any]()
    
    // Create empty section model.
    public init() {}
    
    /// Set items of specific time to items property.
    /// - Parameter items: items to set
    /// - Note: This method exists because of inability of Swift to cast [T] to [Any].
    open func setItems<T>(_ items: [T])
    {
        self.items = items.map { $0 }
    }

    /// Returns items of specific type, if found in a section
    /// Parameter type: Type of items to search for
    /// Returns: Array of items
    open func itemsOfType<T>(_ type: T.Type) -> [T]
    {
        var foundItems = [T]()
        for item in items {
            if let item = item as? T {
                foundItems.append(item)
            }
        }
        return foundItems
    }
    
    /// Number of items in current section
    open var numberOfItems: Int {
        return self.items.count
    }
}
