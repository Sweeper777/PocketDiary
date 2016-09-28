//
//  CoreDataStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
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
import CoreData

private struct DTFetchedResultsSectionInfoWrapper : Section
{
    let fetchedObjects : [AnyObject]
    let numberOfItems: Int
    
    var items : [Any] {
        return fetchedObjects.map { $0 }
    }
}

/// This class represents model storage in CoreData
/// It uses NSFetchedResultsController to monitor all changes in CoreData and automatically notify delegate of any changes
open class CoreDataStorage : BaseStorage, StorageProtocol, SupplementaryStorageProtocol, NSFetchedResultsControllerDelegate
{
    /// Fetched results controller of storage
    open let fetchedResultsController : NSFetchedResultsController<AnyObject>
    
    /// Initialize CoreDataStorage with NSFetchedResultsController
    /// - Parameter fetchedResultsController: fetch results controller
    public init(fetchedResultsController: NSFetchedResultsController<AnyObject>)
    {
        self.fetchedResultsController = fetchedResultsController
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    /// Sections of fetched results controller as required by StorageProtocol
    /// - SeeAlso: `StorageProtocol`
    /// - SeeAlso: `MemoryStorage`
    open var sections : [Section]
    {
        if let sections = self.fetchedResultsController.sections
        {
            return sections.map { DTFetchedResultsSectionInfoWrapper(fetchedObjects: $0.objects!, numberOfItems: $0.numberOfObjects) }
        }
        return []
    }
    
    // MARK: - StorageProtocol
    
    /// Retrieve object at index path from `CoreDataStorage`
    /// - Parameter path: NSIndexPath for object
    /// - Returns: model at indexPath or nil, if item not found
    open func itemAtIndexPath(_ path: IndexPath) -> Any? {
        return fetchedResultsController.object(at: path)
    }
    
    // MARK: - SupplementaryStorageProtocol
    
    /// Retrieve supplementary model of specific kind for section.
    /// - Parameter kind: kind of supplementary model
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    open func supplementaryModelOfKind(_ kind: String, sectionIndex: Int) -> Any?
    {
        if kind == self.supplementaryHeaderKind
        {
            if let sections = self.fetchedResultsController.sections
            {
                return sections[sectionIndex].name
            }
            return nil
        }
        return nil
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// NSFetchedResultsController is about to start changing content - we'll start monitoring for updates.
    @objc open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.startUpdate()
    }
    
    /// React to specific change in NSFetchedResultsController
    @objc open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?)
    {
        switch type
        {
        case .insert:
            if newIndexPath != nil { self.currentUpdate?.insertedRowIndexPaths.insert(newIndexPath!) }
        case .delete:
            if indexPath != nil { self.currentUpdate?.deletedRowIndexPaths.insert(indexPath!) }
        case .move:
            if indexPath != nil && newIndexPath != nil {
                if indexPath != newIndexPath {
                    self.currentUpdate?.deletedRowIndexPaths.insert(indexPath!)
                    self.currentUpdate?.insertedRowIndexPaths.insert(newIndexPath!)
                }
                else {
                    self.currentUpdate?.updatedRowIndexPaths.insert(indexPath!)
                }
            }
        case .update:
            if indexPath != nil { self.currentUpdate?.updatedRowIndexPaths.insert(indexPath!) }
        }
    }
    
    /// React to changed section in NSFetchedResultsController
    @objc
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    { switch type
    {
    case .insert:
        self.currentUpdate?.insertedSectionIndexes.insert(sectionIndex)
    case .delete:
        self.currentUpdate?.deletedSectionIndexes.insert(sectionIndex)
    case .update:
        self.currentUpdate?.updatedSectionIndexes.insert(sectionIndex)
    default: ()
        }
    }
    
    /// Finish update from NSFetchedResultsController
    @objc
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.finishUpdate()
    }
}
