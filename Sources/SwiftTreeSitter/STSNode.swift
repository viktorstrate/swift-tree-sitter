//
//  STSNode.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import CTreeSitter

public class STSNode: Equatable, Hashable {
    
    internal var tsNode: TSNode
    
    init(from tsNode: TSNode) {
        self.tsNode = tsNode
    }
    
    public static func == (lhs: STSNode, rhs: STSNode) -> Bool {
        ts_node_eq(lhs.tsNode, rhs.tsNode)
    }
    
    /// A numeric id for this node that is unique.
    public var id: uint {
        get {
            tsNode.id.load(as: uint.self)
        }
    }
    
    /// Get the node's type.
    public var type: String {
        get {
            let cstr = ts_node_type(tsNode)!
            return String(cString: cstr)
        }
    }
    
    /// Get the node's type as a numerical id.
    public var typeId: UInt16 {
        get {
            let symbol = ts_node_symbol(tsNode)
            return symbol
        }
    }
    
    /// Get an S-expression representing the node as a string.
    public var sExpressionString: String? {
        get {
            let cstr = ts_node_string(tsNode)
            if let cstr = cstr {
                let result = String(cString: cstr)
                cstr.deallocate()
                
                return result
            }
            
            return nil
        }
    }
    
    /**
    
     Check if the node is null. Functions like `.child()` and
    `.nextSibling()` will return a null node to indicate that no such node
    was found.
     
     */
    public var isNull: Bool {
        get {
            ts_node_is_null(tsNode)
        }
    }
    
    /**
     Check if the node is *named*. Named nodes correspond to named rules in the
     grammar, whereas *anonymous* nodes correspond to string literals in the
     grammar.
     */
    public var isNamed: Bool {
        get {
            ts_node_is_named(tsNode)
        }
    }
    
    
    /**
     Check if the node is *extra*. Extra nodes represent things like comments,
     which are not required by the grammar, but can appear anywhere.
     */
    public var isExtra: Bool {
        get {
            ts_node_is_extra(tsNode)
        }
    }
    
    /// Check if a syntax node has been edited.
    public var hasChanges: Bool {
        get {
            ts_node_has_changes(tsNode)
        }
    }
    
    /// Check if the node is a syntax error or contains any syntax errors.
    public var hasError: Bool {
        get {
            ts_node_has_error(tsNode)
        }
    }
    
    /**
     Check if the node is *missing*. Missing nodes are inserted by the parser in
     order to recover from certain kinds of syntax errors.
     */
    public var isMissing: Bool {
        get {
            ts_node_is_missing(tsNode)
        }
    }
    
    /// Get the node's start byte.
    public var startByte: uint {
        get {
            ts_node_start_byte(tsNode)
        }
    }
    
    /// Get the node's end byte.
    public var endByte: uint {
        get {
            ts_node_end_byte(tsNode)
        }
    }
    
    /// Get the node's byte range from startByte to endByte
    public var byteRange: Range<uint> {
        get {
            startByte ..< endByte
        }
    }
    
    /// Get the node's start position in terms of rows and columns.
    public var startPoint: STSPoint {
        get {
            STSPoint(from: ts_node_start_point(tsNode))
        }
    }
    
    /// Get the node's end position in terms of rows and columns.
    public var endPoint: STSPoint {
        get {
            STSPoint(from: ts_node_end_point(tsNode))
        }
    }
    
    /// Get the node's immediate parent.
    public func parent() -> STSNode {
        return STSNode(from: ts_node_parent(tsNode))
    }
    
    /// Get the node's number of children.
    public var childCount: uint {
        get {
            ts_node_child_count(tsNode)
        }
    }
    
    /**
     Get the node's child at the given index, where zero represents the first
     child.
     
     - Parameters:
        - index: The index of the child. The value must be between 0 and `childCount` (exclusive)
     
     */
    public func child(at index: uint) -> STSNode {
        assert(index >= 0 && index < childCount)
        
        let child = ts_node_child(tsNode, index)
        return STSNode(from: child)
    }
    
    /// Get the node's children
    public func children() -> [STSNode] {
        var children: [STSNode] = []
        
        for i in 0..<childCount {
            children.append(child(at: i))
        }
        
        return children
    }
    
    /**
     Get the node's number of children.
     
     See also `isNamed`.
     */
    public var namedChildCount: uint {
        get {
            ts_node_named_child_count(tsNode)
        }
    }
    
    /**
     Get the node's child at the given index, where zero represents the first
     child.
    
     See also `isNamed`.
     
     - Parameters:
        - index: The index of the child. The value must be between 0 and `childCount` (exclusive)
    */
    public func namedChild(at index: uint) -> STSNode {
        assert(index >= 0 && index < namedChildCount)
        
        let child = ts_node_named_child(tsNode, index)
        return STSNode(from: child)
    }
    
    /**
     Get the node's number of named children.
    
     See also `isNamed`.
    */
    public func namedChildren() -> [STSNode] {
       var children: [STSNode] = []
       
       for i in 0..<namedChildCount {
           children.append(namedChild(at: i))
       }
       
       return children
    }
    
    /// Get the node's next sibling.
    public func nextSibling() -> STSNode {
        return STSNode(from: ts_node_next_sibling(tsNode))
    }
    
    /// Get the node's next sibling.
    public func previousSibling() -> STSNode {
        return STSNode(from: ts_node_prev_sibling(tsNode))
    }
    
    /**
     Get the node's next named sibling.
    
     See also `isNamed`.
    */
    public func nextNamedSibling() -> STSNode {
        return STSNode(from: ts_node_next_named_sibling(tsNode))
    }
    
    /**
     Get the node's previous named sibling
    
     See also `isNamed`.
    */
    public func previousNamedSibling() -> STSNode {
        return STSNode(from: ts_node_prev_named_sibling(tsNode))
    }
    
    /// Get the node's first child that extends beyond the given byte offset.
    public func firstChild(forOffset offset: uint) -> STSNode {
        return STSNode(from: ts_node_first_child_for_byte(tsNode, offset))
    }
    
    /**
     Get the node's first named child that extends beyond the given byte offset.
    
     See also `isNamed`.
    */
    public func firstNamedChild(forOffset offset: uint) -> STSNode {
        return STSNode(from: ts_node_first_named_child_for_byte(tsNode, offset))
    }
    
    /// Get the smallest node within this node that spans the given range of bytes.
    public func descendantForRange(startByte: uint, endByte: uint) -> STSNode {
        let des = ts_node_descendant_for_byte_range(tsNode, startByte, endByte)
        return STSNode(from: des)
    }
    
    /// Get the smallest node within this node that spans the given range of  (row, column) positions.
    public func descendantForPoint(startPoint: STSPoint, endPoint: STSPoint) -> STSNode {
        let des = ts_node_descendant_for_point_range(tsNode, startPoint.tsPoint, endPoint.tsPoint)
        return STSNode(from: des)
    }
    
    /**
     Edit the node to keep it in-sync with source code that has been edited.
     
     This function is only rarely needed. When you edit a syntax tree with the
     `tree.edit()` function, all of the nodes that you retrieve from the tree
     afterward will already reflect the edit. You only need to use `node.edit()`
     when you have a `STSNode` instance that you want to keep and continue to use
     after an edit.
     */
    public func edit(_ inputEdit: STSInputEdit) {
        withUnsafePointer(to: inputEdit.tsInputEdit()) { (inputEditPtr) -> Void in
            withUnsafeMutablePointer(to: &tsNode) { (tsNodePtr) -> Void in
                ts_node_edit(tsNodePtr, inputEditPtr)
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(tsNode.id)
    }
    
}
