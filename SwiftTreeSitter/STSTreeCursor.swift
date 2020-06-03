//
//  STSTreeCursor.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSTreeCursor: Equatable, Hashable {
    
    // Keep a reference to the cursors's tree,
    // to prevent it from being deleted prematurly
    internal let treeRef: STSTree
    
    internal var tsTreeCursor: TSTreeCursor
    
    /// Tree cursor's current node
    public var currentNode: STSNode {
        get {
            let tsNode = withUnsafePointer(to: &self.tsTreeCursor) { (cursorPointer) -> TSNode in
                ts_tree_cursor_current_node(cursorPointer)
            }
            return STSNode(from: tsNode)
        }
    }
    
    public var fieldName: String? {
        get {
            
            let cstr = withUnsafePointer(to: &self.tsTreeCursor) { (cursorPointer) -> UnsafePointer<Int8>? in
                ts_tree_cursor_current_field_name(cursorPointer)
            }
            
            if let cstr = cstr {
                return String(cString: cstr)
            }
            return nil
        }
    }
    
    public var fieldId: UInt16 {
        get {
            withUnsafePointer(to: &self.tsTreeCursor) { (cursorPointer) -> UInt16 in
                ts_tree_cursor_current_field_id(cursorPointer)
            }
        }
    }
    
    public init(tree: STSTree, node: STSNode) {
        self.treeRef = tree
        self.tsTreeCursor = ts_tree_cursor_new(node.tsNode)
    }
    
    deinit {
        withUnsafeMutablePointer(to: &self.tsTreeCursor) { (cursorPointer) -> Void in
            ts_tree_cursor_delete(cursorPointer)
        }
    }

    public func reset(node: STSNode) {
        withUnsafeMutablePointer(to: &self.tsTreeCursor) { (cursorPointer) -> Void in
            ts_tree_cursor_reset(cursorPointer, node.tsNode)
        }
    }
    
    public func gotoFirstChild() -> Bool {
        return withUnsafeMutablePointer(to: &self.tsTreeCursor) { (cursorPointer) -> Bool in
            ts_tree_cursor_goto_first_child(cursorPointer)
        }
    }
    
    public func gotoParent() -> Bool {
        return withUnsafeMutablePointer(to: &self.tsTreeCursor) { (cursorPointer) -> Bool in
            ts_tree_cursor_goto_parent(cursorPointer)
        }
    }

    public func gotoNextSibling() -> Bool {
        return withUnsafeMutablePointer(to: &self.tsTreeCursor) { (cursorPointer) -> Bool in
            ts_tree_cursor_goto_next_sibling(cursorPointer)
        }
    }

    public func gotoFirstChildForByte(index: uint) -> uint? {
        let result = withUnsafeMutablePointer(to: &self.tsTreeCursor) { (cursorPointer) -> Int64 in
            ts_tree_cursor_goto_first_child_for_byte(cursorPointer, index)
        }
        
        if result < 0 {
            return nil
        }

        return uint(result)
    }
    
    public static func == (lhs: STSTreeCursor, rhs: STSTreeCursor) -> Bool {
        return lhs.tsTreeCursor.id == rhs.tsTreeCursor.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tsTreeCursor.id)
    }
    
}
