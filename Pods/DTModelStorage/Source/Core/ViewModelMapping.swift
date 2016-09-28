//
//  ViewModelMapping.swift
//  DTModelStorage
//
//  Created by Denys Telezhkin on 27.11.15.
//  Copyright © 2015 Denys Telezhkin. All rights reserved.
//
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

/// ViewType enum allows differentiating between mappings for different kinds of views. For example, UICollectionView headers might use ViewType.supplementaryView(UICollectionElementKindSectionHeader) value.
public enum ViewType : Equatable
{
    case cell
    case supplementaryView(kind: String)
    
    /// Returns supplementaryKind for .supplementaryView case, nil for .cell case.
    /// - Returns supplementaryKind string
    public func supplementaryKind() -> String?
    {
        switch self
        {
        case .cell: return nil
        case .supplementaryView(let kind): return kind
        }
    }
    
    // Compares view types, `Equatable` protocol.
    static public func == (left: ViewType, right: ViewType) -> Bool {
        switch (left, right) {
        case (.cell, .cell): return true
        case (.supplementaryView(let leftKind),.supplementaryView(let rightKind)): return leftKind == rightKind
        default: return false
        }
    }
}

/// `ViewModelMapping` struct serves to store mappings, and capture model and cell types. Due to inability of moving from dynamic types to compile-time types, we are forced to use (Any,Any) closure and force cast types when mapping is performed.
public struct ViewModelMapping
{
    /// View type for this mapping
    public let viewType : ViewType
    
    /// View class, that will be used for current mapping
    public let viewClass : AnyClass
    
    /// Xib name for mapping. This value will not be nil only if XIBs are used for this particular mapping.
    public let xibName : String?
    
    /// Type checking block, that will verify whether passed model should be mapped to `viewClass`.
    public let modelTypeCheckingBlock: (Any) -> Bool
    
    /// Type-erased update block, that will be called when `ModelTransfer` `update(with:)` method needs to be executed.
    public let updateBlock : (Any, Any) -> Void
}

/// Adopt this protocol on your `DTTableViewManageable` or `DTCollectionViewManageable` instance to be able to select mapping from available candidates.
public protocol ViewModelMappingCustomizing : class {
    
    /// Select `ViewModelMapping` from candidates or return your own mapping
    /// - Parameter candidates: mapping candidates, that were found for this model
    /// - Parameter model: model to search candidates for
    /// - Returns: `ViewModelMapping` instance, or nil if no mapping is required
    func viewModelMapping(fromCandidates candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping?
}

public extension RangeReplaceableCollection where Self.Iterator.Element == ViewModelMapping {
    
    /// Returns mappings candidates of correct `viewType`, for which `modelTypeCheckingBlock` with `model` returns true.
    /// - Returns: Array of view model mappings
    /// - Note: Usually returned array will consist of 0 or 1 element. Multiple candidates will be returned when several mappings correspond to current model - this can happen in case of protocol or subclassed model.
    /// - SeeAlso: `addMappingForViewType(_:viewClass:)`
    func mappingCandidates(forViewType viewType: ViewType, withModel model: Any) -> [ViewModelMapping] {
        return filter { mapping -> Bool in
            guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return false }
            return viewType == mapping.viewType && mapping.modelTypeCheckingBlock(unwrappedModel)
        }
    }
    
    /// Add mapping for `viewType` for `viewClass` with `xibName`. 
    /// - SeeAlso: `mappingCandidatesForViewType(_:model:)`
    mutating func addMapping<T:ModelTransfer>(for viewType: ViewType, viewClass: T.Type, xibName: String? = nil) {
        append(ViewModelMapping(viewType: viewType,
            viewClass: T.self,
              xibName: xibName,
            modelTypeCheckingBlock: { model -> Bool in
                return model is T.ModelType
            }, updateBlock: { (view, model) in
                guard let view = view  as? T, let model = model as? T.ModelType else { return }
                view.update(with: model)
        }))
    }
}

// DEPRECATED

public extension RangeReplaceableCollection where Self.Iterator.Element == ViewModelMapping {
    @available(*,unavailable,renamed:"mappingCandidates(forViewType:withModel:)")
    func mappingCandidatesForViewType(_ viewType: ViewType, model: Any) -> [ViewModelMapping] {
        return filter { mapping -> Bool in
            guard let unwrappedModel = RuntimeHelper.recursivelyUnwrapAnyValue(model) else { return false }
            
            return viewType == mapping.viewType && mapping.modelTypeCheckingBlock(unwrappedModel)
        }
    }
    
    @available(*, unavailable, renamed: "addMapping(for:viewClass:xibName:)")
    mutating func addMappingForViewType<T:ModelTransfer>(_ viewType: ViewType, viewClass: T.Type, xibName: String? = nil) {
        append(ViewModelMapping(viewType: viewType,
                                viewClass: T.self,
                                xibName: xibName,
                                modelTypeCheckingBlock: { model -> Bool in
                                    return model is T.ModelType
            }, updateBlock: { (view, model) in
                guard let view = view  as? T, let model = model as? T.ModelType else { return }
                view.update(with: model)
        }))
    }
}
@available(*,unavailable,renamed:"ViewModelMappingCustomizing")
public protocol DTViewModelMappingCustomizable {}

public extension ViewModelMappingCustomizing {
    @available(*,unavailable,renamed:"viewModelMapping(fromCandidates:withModel:)")
    func viewModelMappingFromCandidates(_ candidates: [ViewModelMapping], forModel model: Any) -> ViewModelMapping? {
        fatalError("UNAVAILABLE")
    }
}
