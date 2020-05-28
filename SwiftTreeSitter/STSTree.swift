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
    
    public static func == (lhs: STSTree, rhs: STSTree) -> Bool {
        return lhs.treePointer == rhs.treePointer
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(treePointer)
    }
    
}
