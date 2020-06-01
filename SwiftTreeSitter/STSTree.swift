//
//  STSTree.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

/// A tree that represents the syntactic structure of a source code file.
public class STSTree: Equatable, Hashable {
    
    internal let treePointer: OpaquePointer
    
    public var rootNode: STSNode {
        get {
            STSNode(from: ts_tree_root_node(treePointer))
        }
    }
    
    public var language: STSLanguage {
        get {
            let languagePointer = ts_tree_language(treePointer)
            return STSLanguage(pointer: languagePointer)
        }
    }
    
    init(pointer: OpaquePointer) {
        self.treePointer = pointer
    }
    
    deinit {
        ts_tree_delete(treePointer)
    }
    
    public func walk() -> STSTreeCursor {
        return STSTreeCursor(tree: self, node: self.rootNode)
    }
    
    public func copy() -> STSTree {
        return STSTree(pointer: ts_tree_copy(treePointer))
    }
    
    public func edit(_ inputEdit: STSInputEdit) {
        withUnsafePointer(to: inputEdit.tsInputEdit()) { (inputEditPtr) -> Void in
            ts_tree_edit(treePointer, inputEditPtr)
        }
    }
    
    /**
     Compare an old edited syntax tree to a new syntax tree representing the same
     document, returning an array of ranges whose syntactic structure has changed.
     
     For this to work correctly, the old syntax tree must have been edited such
     that its ranges match up to the new tree. Generally, you'll want to call
     this function right after calling one of the `STSParser.parse()` functions.
     
     - Parameters:
        - oldTree: The old tree that was passed to parse.
        - newTree: The new tree that was returned from the parser.
     */
    public static func changedRanges(oldTree: STSTree, newTree: STSTree) -> [STSRange] {
        
        let lengthPtr = UnsafeMutablePointer<uint>.allocate(capacity: 1)
        let changesPtr = ts_tree_get_changed_ranges(oldTree.treePointer, newTree.treePointer, lengthPtr)
        defer {
            lengthPtr.deallocate()
            changesPtr?.deallocate()
        }
        
        var ranges: [STSRange] = []
        
        for _ in 0..<lengthPtr.pointee {
            let range = changesPtr!.pointee
            ranges.append(STSRange(tsRange: range))
        }
        
        return ranges
    }
    
    public static func == (lhs: STSTree, rhs: STSTree) -> Bool {
        return lhs.treePointer == rhs.treePointer
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(treePointer)
    }
    
}
