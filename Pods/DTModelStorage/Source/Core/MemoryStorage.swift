//
//  MemoryStorage.swift
//  DTModelStorage
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

import Foundation

/// This struct contains error types that can be thrown for various MemoryStorage errors
public enum MemoryStorageError : LocalizedError
{
    /// Errors that can happen when inserting items into memory storage - `insertItem(_:to:)` method
    public enum InsertionReason
    {
        case indexPathTooBig(IndexPath)
    }
    
    /// Errors that can be thrown, when calling `insertItems(_:to:)` method
    public enum BatchInsertionReason
    {
        /// Is thrown, if length of batch inserted array is different from length of array of index paths.
        case itemsCountMismatch
    }
    
    /// Errors that can happen when replacing item in memory storage - `replaceItem(_:with:)` method
    public enum SearchReason
    {
        case itemNotFound(item: Any)
        
        var localizedDescription : String {
            guard case let SearchReason.itemNotFound(item: item) = self else {
                return ""
            }
            return "Failed to find \(item) in MemoryStorage"
        }
    }
    
    case insertionFailed(reason: InsertionReason)
    case batchInsertionFailed(reason: BatchInsertionReason)
    case searchFailed(reason: SearchReason)
    
    public var localizedDescription: String {
        switch self {
        case .insertionFailed(reason: _):
            return "IndexPath provided was bigger then existing section or item"
        case .batchInsertionFailed(reason: _):
            return "While inserting batch of items, length of provided array differs from index path array length"
        case .searchFailed(reason: let reason):
            return reason.localizedDescription
        }
    }
}

/// Storage of models in memory.
///
/// `MemoryStorage` stores data models using array of `SectionModel` instances. It has various methods for changing storage contents - add, remove, insert, replace e.t.c.
/// - Note: It also notifies it's delegate about underlying changes so that delegate can update interface accordingly
/// - SeeAlso: `SectionModel`
open class MemoryStorage: BaseStorage, Storage, SupplementaryStorage, SectionLocationIdentifyable
{
    /// sections of MemoryStorage
    open var sections: [Section] = [SectionModel]() {
        didSet {
            sections.forEach {
                ($0 as? SectionModel)?.sectionLocationDelegate = self
            }
        }
    }
    
    /// Returns index of `section` or nil, if section is now found
    open func sectionIndex(for section: Section) -> Int? {
        return sections.index(where: {
            return ($0 as? SectionModel) === (section as? SectionModel)
        })
    }
    
    /// Returns total number of items contained in all `MemoryStorage` sections
    ///
    /// - Complexity: O(n) where n - number of sections
    open var totalNumberOfItems : Int {
        return sections.reduce(0) { sum, section in
            return sum + section.numberOfItems
        }
    }
    
    /// Returns item at `indexPath` or nil, if it is not found.
    open func item(at indexPath: IndexPath) -> Any? {
        let sectionModel : SectionModel
        if indexPath.section >= self.sections.count {
            return nil
        }
        else {
            sectionModel = self.sections[indexPath.section] as! SectionModel
            if indexPath.item >= sectionModel.numberOfItems {
                return nil
            }
        }
        return sectionModel.items[indexPath.item]
    }
    
    /// Sets section header `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionHeaderModel<T>(_ model: T?, forSection sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        let section = getValidSection(sectionIndex)
        section.setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!, atIndex: 0)
        delegate?.storageNeedsReloading()
    }
    
    /// Sets section footer `model` for section at `sectionIndex`
    ///
    /// This method calls delegate?.storageNeedsReloading() method at the end, causing UI to be updated.
    /// - SeeAlso: `configureForTableViewUsage`
    /// - SeeAlso: `configureForCollectionViewUsage`
    open func setSectionFooterModel<T>(_ model: T?, forSection sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        let section = getValidSection(sectionIndex)
        section.setSupplementaryModel(model, forKind: self.supplementaryFooterKind!, atIndex: 0)
        delegate?.storageNeedsReloading()
    }
    
    /// Sets supplementary `models` for supplementary of `kind`.
    ///
    /// - Note: This method can be used to clear all supplementaries of specific kind, just pass an empty array as models.
    open func setSupplementaries(_ models : [[Int: Any]], forKind kind: String)
    {
        defer {
            self.delegate?.storageNeedsReloading()
        }
        
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as? SupplementaryAccessible
                section?.supplementaries[kind] = nil
            }
            return
        }
        
        _ = getValidSection(models.count - 1)
        
        for index in 0 ..< models.count {
            let section = self.sections[index] as? SupplementaryAccessible
            section?.supplementaries[kind] = models[index]
        }
    }
    
    /// Sets section header `models`, using `supplementaryHeaderKind`.
    ///
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    open func setSectionHeaderModels<T>(_ models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        var supplementaries = [[Int:Any]]()
        for model in models {
            supplementaries.append([0:model])
        }
        self.setSupplementaries(supplementaries, forKind: self.supplementaryHeaderKind!)
    }

    /// Sets section footer `models`, using `supplementaryFooterKind`.
    ///
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    open func setSectionFooterModels<T>(_ models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        var supplementaries = [[Int:Any]]()
        for model in models {
            supplementaries.append([0:model])
        }
        self.setSupplementaries(supplementaries, forKind: self.supplementaryFooterKind!)
    }
    
    /// Sets `items` for section at `index`.
    /// 
    /// - Note: This will reload UI after updating.
    open func setItems<T>(_ items: [T], forSection index: Int = 0)
    {
        let section = self.getValidSection(index)
        section.items.removeAll(keepingCapacity: false)
        for item in items { section.items.append(item) }
        self.delegate?.storageNeedsReloading()
    }
    
    /// Sets `section` for `index`. This will reload UI after updating
    ///
    /// - Parameter section: SectionModel to set
    /// - Parameter index: index of section
    open func setSection(_ section: SectionModel, forSection index: Int)
    {
        let _ = self.getValidSection(index)
        sections.replaceSubrange(index...index, with: [section as Section])
        delegate?.storageNeedsReloading()
    }
    
    /// Inserts `section` at `sectionIndex`.
    ///
    /// - Parameter section: section to insert
    /// - Parameter sectionIndex: index of section to insert.
    /// - Discussion: this method is assumed to be used, when you need to insert section with items and supplementaries in one batch operation. If you need to simply add items, use `addItems` or `setItems` instead.
    /// - Note: If `sectionIndex` is larger than number of sections, method does nothing.
    open func insertSection(_ section: SectionModel, atIndex sectionIndex: Int) {
        guard sectionIndex <= sections.count else { return }
        startUpdate()
        sections.insert(section, at: sectionIndex)
        currentUpdate?.insertedSectionIndexes.insert(sectionIndex)
        for item in 0..<section.numberOfItems {
            currentUpdate?.insertedRowIndexPaths.insert(IndexPath(item: item, section: sectionIndex))
        }
        finishUpdate()
    }
    
    /// Adds `items` to section with section `index`.
    ///
    /// This method creates all sections prior to `index`, unless they are already created.
    open func addItems<T>(_ items: [T], toSection index: Int = 0)
    {
        startUpdate()
        let section = getValidSection(index)
        
        for item in items {
            let numberOfItems = section.numberOfItems
            section.items.append(item)
            currentUpdate?.insertedRowIndexPaths.insert(IndexPath(item: numberOfItems, section: index))
        }
        finishUpdate()
    }
    
    /// Adds `item` to section with section `index`.
    ///
    /// - Parameter item: item to add
    /// - Parameter toSection: index of section to add item
    open func addItem<T>(_ item: T, toSection index: Int = 0)
    {
        self.startUpdate()
        let section = self.getValidSection(index)
        let numberOfItems = section.numberOfItems
        section.items.append(item)
        self.currentUpdate?.insertedRowIndexPaths.insert(IndexPath(item: numberOfItems, section: index))
        self.finishUpdate()
    }
    
    /// Inserts `item` to `indexPath`.
    ///
    /// This method creates all sections prior to indexPath.section, unless they are already created.
    /// - Throws: if indexPath is too big, will throw MemoryStorageErrors.Insertion.IndexPathTooBig
    open func insertItem<T>(_ item: T, to indexPath: IndexPath) throws
    {
        self.startUpdate()
        let section = self.getValidSection(indexPath.section)
        
        guard section.items.count >= indexPath.item else {
            throw MemoryStorageError.insertionFailed(reason: .indexPathTooBig(indexPath))
        }
        
        section.items.insert(item, at: indexPath.item)
        self.currentUpdate?.insertedRowIndexPaths.insert(indexPath)
        self.finishUpdate()
    }
    
    /// Inserts `items` to `indexPaths`
    ///
    /// This method creates sections prior to maximum indexPath.section in `indexPaths`, unless they are already created.
    /// - Throws: if items.count is different from indexPaths.count, will throw MemoryStorageErrors.BatchInsertion.ItemsCountMismatch
    open func insertItems<T>(_ items: [T], to indexPaths: [IndexPath]) throws
    {
        if items.count != indexPaths.count {
            throw MemoryStorageError.batchInsertionFailed(reason: .itemsCountMismatch)
        }
        performUpdates {
            indexPaths.enumerated().forEach { itemIndex, indexPath in
                let section = getValidSection(indexPath.section)
                guard section.items.count >= indexPath.item else {
                    return
                }
                section.items.insert(items[itemIndex], at: indexPath.item)
                currentUpdate?.insertedRowIndexPaths.insert(indexPath)
            }
        }
    }
    
    /// Reloads `item`.
    open func reloadItem<T:Equatable>(_ item: T)
    {
        self.startUpdate()
        if let indexPath = self.indexPath(forItem: item) {
            self.currentUpdate?.updatedRowIndexPaths.insert(indexPath)
        }
        self.finishUpdate()
    }
    
    /// Replace item `itemToReplace` with `replacingItem`.
    ///
    /// - Throws: if `itemToReplace` is not found, will throw MemoryStorageErrors.Replacement.ItemNotFound
    open func replaceItem<T: Equatable>(_ itemToReplace: T, with replacingItem: Any) throws
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let originalIndexPath = self.indexPath(forItem: itemToReplace) else {
            throw MemoryStorageError.searchFailed(reason: .itemNotFound(item: itemToReplace))
        }
        
        let section = self.getValidSection(originalIndexPath.section)
        section.items[originalIndexPath.item] = replacingItem
        
        self.currentUpdate?.updatedRowIndexPaths.insert(originalIndexPath)
    }
    
    /// Removes `item`.
    ///
    /// - Throws: if item is not found, will throw MemoryStorageErrors.Removal.ItemNotFound
    open func removeItem<T:Equatable>(_ item: T) throws
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let indexPath = self.indexPath(forItem: item) else {
            throw MemoryStorageError.searchFailed(reason: .itemNotFound(item: item))
        }
        self.getValidSection(indexPath.section).items.remove(at: indexPath.item)
        
        self.currentUpdate?.deletedRowIndexPaths.insert(indexPath)
    }
    
    /// Removes `items` from storage.
    ///
    /// Any items that were not found, will be skipped. Items are deleted in reverse order, starting from largest indexPath to prevent unintended gaps.
    /// - SeeAlso: `removeItems(at:)`
    open func removeItems<T:Equatable>(_ items: [T])
    {
        self.startUpdate()
        
        let indexPaths = indexPathArray(forItems: items)
        for indexPath in type(of: self).sortedArrayOfIndexPaths(indexPaths, ascending: false)
        {
            self.getValidSection(indexPath.section).items.remove(at: indexPath.item)
            self.currentUpdate?.deletedRowIndexPaths.insert(indexPath)
        }
        self.finishUpdate()
    }
    
    /// Removes items at `indexPaths`.
    ///
    /// Any indexPaths that will not be found, will be skipped. Items are deleted in reverse order, starting from largest indexPath to prevent unintended gaps.
    /// - SeeAlso: `removeItems(_:)`
    open func removeItems(at indexPaths : [IndexPath])
    {
        self.startUpdate()
        
        let reverseSortedIndexPaths = type(of: self).sortedArrayOfIndexPaths(indexPaths, ascending: false)
        for indexPath in reverseSortedIndexPaths
        {
            if let _ = self.item(at: indexPath)
            {
                self.getValidSection(indexPath.section).items.remove(at: indexPath.item)
                self.currentUpdate?.deletedRowIndexPaths.insert(indexPath)
            }
        }
        
        self.finishUpdate()
    }
    
    /// Deletes `sections` from storage.
    ///
    /// Sections will be deleted in backwards order, starting from the last one.
    open func deleteSections(_ sections : IndexSet)
    {
        self.startUpdate()
        
        var i = sections.last ?? NSNotFound
        while i != NSNotFound && i < self.sections.count {
            self.sections.remove(at: i)
            self.currentUpdate?.deletedSectionIndexes.insert(i)
            i = sections.integerLessThan(i) ?? NSNotFound
        }
        
        self.finishUpdate()
    }
    
    /// Moves section from `sourceSectionIndex` to `destinationSectionIndex`.
    ///
    /// Sections prior to `sourceSectionIndex` and `destinationSectionIndex` will be automatically created, unless they already exist.
    open func moveSection(_ sourceSectionIndex: Int, toSection destinationSectionIndex: Int) {
        self.startUpdate()
        let validSectionFrom = getValidSection(sourceSectionIndex)
        let _ = getValidSection(destinationSectionIndex)
        sections.remove(at: sourceSectionIndex)
        sections.insert(validSectionFrom, at: destinationSectionIndex)
        currentUpdate?.movedSectionIndexes.append([sourceSectionIndex,destinationSectionIndex])
        self.finishUpdate()
    }
    
    /// Moves item from `source` indexPath to `destination` indexPath.
    ///
    /// Sections prior to `source`.section and `destination`.section will be automatically created, unless they already exist. If source item or destination index path are unreachable(too large), this method does nothing.
    open func moveItem(at source: IndexPath, to destination: IndexPath)
    {
        self.startUpdate()
        defer { self.finishUpdate() }
        
        guard let sourceItem = item(at: source) else {
            print("MemoryStorage: source indexPath should not be nil when moving item")
            return
        }
        let sourceSection = getValidSection(source.section)
        let destinationSection = getValidSection(destination.section)
        
        if destinationSection.items.count < destination.row {
            print("MemoryStorage: failed moving item to indexPath: \(destination), only \(destinationSection.items.count) items in section")
            return
        }
        sourceSection.items.remove(at: source.row)
        destinationSection.items.insert(sourceItem, at: destination.item)
        currentUpdate?.movedRowIndexPaths.append([source,destination])
    }
    
    /// Removes all items from storage.
    ///
    /// - Note: method will call .storageNeedsReloading() when it finishes.
    open func removeAllItems()
    {
        for section in self.sections {
            (section as? SectionModel)?.items.removeAll(keepingCapacity: false)
        }
        delegate?.storageNeedsReloading()
    }
    
    /// Remove items from section with `sectionIndex`.
    ///
    /// If section at `sectionIndex` does not exist, this method does nothing.
    open func removeItems(fromSection sectionIndex: Int) {
        startUpdate()
        defer { finishUpdate() }
        
        guard let section = section(atIndex: sectionIndex) else { return }
        
        for (index,_) in section.items.enumerated(){
            currentUpdate?.deletedRowIndexPaths.insert(IndexPath(item: index, section: sectionIndex))
        }
        section.items.removeAll()
    }
    
    // MARK: - Searching in storage
    
    /// Returns items in section with section `index`, or nil if section does not exist
    open func items(inSection index: Int) -> [Any]?
    {
        if self.sections.count > index {
            return self.sections[index].items
        }
        return nil
    }
    
    /// Returns indexPath of `searchableItem` in MemoryStorage or nil, if it's not found.
    open func indexPath<T: Equatable>(forItem searchableItem : T) -> IndexPath?
    {
        for sectionIndex in 0..<self.sections.count
        {
            let rows = self.sections[sectionIndex].items
            
            for rowIndex in 0..<rows.count {
                if let item = rows[rowIndex] as? T {
                    if item == searchableItem {
                        return IndexPath(item: rowIndex, section: sectionIndex)
                    }
                }
            }
            
        }
        return nil
    }
    
    /// Returns section at `sectionIndex` or nil, if it does not exist
    open func section(atIndex sectionIndex : Int) -> SectionModel?
    {
        if sections.count > sectionIndex {
            return sections[sectionIndex] as? SectionModel
        }
        return nil
    }
    
    /// Finds-or-creates section at `sectionIndex`
    ///
    /// - Note: This method finds or create a SectionModel. It means that if you create section 2, section 0 and 1 will be automatically created.
    /// - Returns: SectionModel
    final func getValidSection(_ sectionIndex : Int) -> SectionModel
    {
        if sectionIndex < self.sections.count
        {
            return self.sections[sectionIndex] as! SectionModel
        }
        else {
            for i in self.sections.count...sectionIndex {
                self.sections.append(SectionModel())
                self.currentUpdate?.insertedSectionIndexes.insert(i)
            }
        }
        return self.sections.last as! SectionModel
    }
    
    /// Returns index path array for `items`
    ///
    /// - Parameter items: items to find in storage
    /// - Returns: Array of IndexPaths for found items
    /// - Complexity: O(N^2*M) where N - number of items in storage, M - number of items.
    final func indexPathArray<T:Equatable>(forItems items:[T]) -> [IndexPath]
    {
        var indexPaths = [IndexPath]()
        
        for index in 0..<items.count {
            if let indexPath = self.indexPath(forItem: items[index])
            {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    /// Returns sorted array of index paths - useful for deletion.
    /// - Parameter indexPaths: Array of index paths to sort
    /// - Parameter ascending: sort in ascending or descending order
    /// - Note: This method is used, when you need to delete multiple index paths. Sorting them in reverse order preserves initial collection from mutation while enumerating
    static func sortedArrayOfIndexPaths(_ indexPaths: [IndexPath], ascending: Bool) -> [IndexPath]
    {
        let unsorted = NSMutableArray(array: indexPaths)
        let descriptor = NSSortDescriptor(key: "self", ascending: ascending)
        return unsorted.sortedArray(using: [descriptor]) as? [IndexPath] ?? []
    }
    
    // MARK: - SupplementaryStorage
    
    /// Returns supplementary model of supplementary `kind` for section at `sectionIndexPath`. Returns nil if not found.
    ///
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    open func supplementaryModel(ofKind kind: String, forSectionAt sectionIndexPath: IndexPath) -> Any? {
        guard sectionIndexPath.section < sections.count else {
            return nil
        }
        return (self.sections[sectionIndexPath.section] as? SupplementaryAccessible)?.supplementaryModel(ofKind:kind, atIndex: sectionIndexPath.item)
    }
    
    // DEPRECATED
    
    @available(*,unavailable,renamed:"item(at:)")
    open func itemAtIndexPath(_ indexPath: IndexPath) -> Any? {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"removeItems(at:)")
    open func removeItemsAtIndexPaths(_ indexPaths : [IndexPath])
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"moveItem(at:to:)")
    open func moveItemAtIndexPath(_ source: IndexPath, toIndexPath destination: IndexPath)
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"items(inSection:)")
    @nonobjc open func itemsInSection(_ section: Int) -> [Any]?
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"indexPath(forItem:)")
    open func indexPathForItem<T: Equatable>(_ searchableItem : T) -> IndexPath?
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"indexPathArray(forItems:)")
    final func indexPathArrayForItems<T:Equatable>(_ items:[T]) -> [IndexPath]
    {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"removeItems(fromSection:)")
    @nonobjc open func removeItemsFromSection(_ sectionIndex: Int) {
        fatalError("UNAVAILABLE")
    }
    
    @available(*,unavailable,renamed:"section(atIndex:)")
    open func sectionAtIndex(_ sectionIndex : Int) -> SectionModel?
    {
        fatalError("UNAVAILABLE")
    }
}
