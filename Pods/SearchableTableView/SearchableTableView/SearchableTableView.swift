//
//  SearchableTableView.swift
//
//  Created by Bazyli Zygan on 01.01.2016.
//  Copyright © 2016 Nova Project. All rights reserved.
//

import UIKit

public class SearchableTableView: UITableView, UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    // MARK: - API variables and methods
    
    @IBOutlet public var searchView: UIView?
    @IBOutlet override weak public var delegate: UITableViewDelegate? {
        get {
            return tableViewDelegate
        }
        
        set {
            tableViewDelegate = newValue
        }
    }
    
    public var translucentNavigationBar: Bool = true
    
    public var searchQuery: String? {
        get {
            if searchVisible {
                return searchController.searchBar.text
            } else {
                return nil
            }
        }
    }
    
    public func cancelSearch() {
        if searchView != nil && searchView == searchController.searchBar {
            searchController.active = false
        }
    }
    
    // MARK: - Implementation - DO NOT TOUCH!
    private var searchVisible = false
    private var searchController: UISearchController!
    private var offsetShift: CGFloat {
        get {
            return (translucentNavigationBar) ? 64.0 : 0
        }
    }
    
    private var tableViewDelegate: UITableViewDelegate?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.prepareSearchViews()
        }
    }
    
    // MARK: - ScrollView handling
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if searchView == nil || searchController.searchBar.isFirstResponder() {
            return
        }
        
        if searchVisible {
                return
        }
        
        if scrollView.contentOffset.y < 0 {
            searchView!.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y)
        } else {
            searchView!.transform = CGAffineTransformIdentity
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if searchView == nil {
            return
        }
        
        if !searchVisible && scrollView.contentOffset.y+offsetShift < -searchView!.bounds.height {
            searchVisible = true
            let offset = scrollView.contentOffset.y + self.searchView!.bounds.height
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.self.searchView!.removeFromSuperview()
                self.searchView!.frame = CGRect(x: 0, y: 0, width: self.searchView!.frame.width, height: self.searchView!.frame.height)
                self.tableHeaderView = self.searchView!
                self.searchView!.setNeedsDisplay()
                scrollView.contentOffset.y = offset
            })
        } else if searchVisible && scrollView.contentOffset.y+offsetShift >= searchView!.bounds.height {
            searchVisible = false
            let offset = scrollView.contentOffset.y - self.searchView!.bounds.height
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableHeaderView = nil
                if self.searchView == self.searchController.searchBar {
                    self.createSearchController()
                }
                self.searchView!.transform = CGAffineTransformIdentity
                self.searchView!.frame = CGRect(x: 0, y: self.frame.origin.y-self.searchView!.frame.height, width: self.searchView!.frame.width, height: self.searchView!.frame.height)
                scrollView.contentOffset.y = offset
                self.superview?.addSubview(self.searchView!)
                self.searchView!.sizeToFit()
                self.searchView!.setNeedsDisplay()
                self.setNeedsDisplay()
                self.reloadData()
            })
            
        }
    }
    
    // MARK: - Transformation of UITableViewDelegates
    public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
    }

    public func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if #available(iOS 9.0, *) {
            return tableViewDelegate?.tableView?(tableView, canFocusRowAtIndexPath: indexPath) ?? true
        } else {
            return true
        }
    }
    
    public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return tableViewDelegate?.tableView?(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender) ?? false
    }
    
    public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, didDeselectRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }
    
    public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }
    
    public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, didEndEditingRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, didHighlightRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, didUnhighlightRowAtIndexPath: indexPath)
    }
    
    @available(iOS 9.0, *)
    public func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        tableViewDelegate?.tableView?(tableView, didUpdateFocusInContext: context, withAnimationCoordinator: coordinator)
    }
    
    public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return tableViewDelegate?.tableView?(tableView, editActionsForRowAtIndexPath: indexPath)
    }

    public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return tableViewDelegate?.tableView?(tableView, editingStyleForRowAtIndexPath: indexPath) ?? .None
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, estimatedHeightForFooterInSection: section) ?? 0
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? 0
    }
    
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, estimatedHeightForRowAtIndexPath: indexPath) ?? 0
    }

    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, heightForFooterInSection: section) ?? 0
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, heightForHeaderInSection: section) ?? 0
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewDelegate?.tableView?(tableView, heightForRowAtIndexPath: indexPath) ?? self.rowHeight
    }
    
    public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return tableViewDelegate?.tableView?(tableView, indentationLevelForRowAtIndexPath: indexPath) ?? 0
    }
    
    public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
        tableViewDelegate?.tableView?(tableView, performAction: action, forRowAtIndexPath: indexPath, withSender: sender)
    }
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldHighlightRowAtIndexPath: indexPath) ?? true
    }
    
    public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldIndentWhileEditingRowAtIndexPath: indexPath) ?? false
    }
    
    public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldShowMenuForRowAtIndexPath: indexPath) ?? false
    }
    
    @available(iOS 9.0, *)
    public func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
        return tableViewDelegate?.tableView?(tableView, shouldUpdateFocusInContext: context) ?? false
    }
    
    public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        return tableViewDelegate?.tableView?(tableView, targetIndexPathForMoveFromRowAtIndexPath: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) ?? proposedDestinationIndexPath
    }
    
    public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return tableViewDelegate?.tableView?(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableViewDelegate?.tableView?(tableView, viewForFooterInSection: section)
    }
    
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableViewDelegate?.tableView?(tableView, viewForHeaderInSection: section)
    }
    
    public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, willBeginEditingRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return tableViewDelegate?.tableView?(tableView, willDeselectRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableViewDelegate?.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }
    
    public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableViewDelegate?.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
    
    public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return tableViewDelegate?.tableView?(tableView, willSelectRowAtIndexPath: indexPath)
    }
    
    // MARK: - SearchBar delegates
    public func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchController.searchBar.resignFirstResponder()
        
    }
    
    public func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResultsForSearchController(searchController)
    }
    
    public func updateSearchResultsForSearchController(searchController: UISearchController) {
        reloadData()
    }
    
    // MARK: - Private implementations
    private func prepareSearchViews() {

        createSearchController()
        
        searchView!.frame = CGRect(x: 0, y: frame.origin.y-searchView!.frame.height, width: searchView!.frame.width, height: searchView!.frame.height)
        super.delegate = self
        self.superview?.addSubview(searchView!)
        reloadData()
    }
    
    private func createSearchController() {
        if searchView == nil {
            searchController = UISearchController(searchResultsController: nil)
            // Testing adding an appropriate view
            searchController.searchBar.sizeToFit()
            self.searchController.searchResultsUpdater = self;
            
            self.searchController.dimsBackgroundDuringPresentation = false;
            
            // Search delegates
            self.searchController.delegate = self;
            self.searchController.searchBar.delegate = self;
            
            searchView = searchController.searchBar
        }
    }
}
