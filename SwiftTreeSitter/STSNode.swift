//
//  STSNode.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

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
    
    public var type: String {
        get {
            let cstr = ts_node_type(tsNode)!
            return String(cString: cstr)
        }
    }
    
    public var typeId: uint16 {
        get {
            let symbol = ts_node_symbol(tsNode)
            return symbol
        }
    }
    
    public var sExpressionString: String? {
        get {
            let cstr = ts_node_string(tsNode)
            if let cstr = cstr {
                return String(cString: cstr)
            }
            
            return nil
        }
    }
    
    public var isNull: Bool {
        get {
            ts_node_is_null(tsNode)
        }
    }
    
    public var isNamed: Bool {
        get {
            ts_node_is_named(tsNode)
        }
    }
    
    public var isExtra: Bool {
        get {
            ts_node_is_extra(tsNode)
        }
    }
    
    public var hasChanges: Bool {
        get {
            ts_node_has_changes(tsNode)
        }
    }
    
    public var hasError: Bool {
        get {
            ts_node_has_error(tsNode)
        }
    }
    
    public var isMissing: Bool {
        get {
            ts_node_is_missing(tsNode)
        }
    }
    
    public var startByte: uint {
        get {
            ts_node_start_byte(tsNode)
        }
    }
    
    public var endByte: uint {
        get {
            ts_node_end_byte(tsNode)
        }
    }
    
    public var byteRange: Range<uint> {
        get {
            startByte ..< endByte
        }
    }
    
    public var startPoint: STSPoint {
        get {
            STSPoint(tsPoint: ts_node_start_point(tsNode))
        }
    }
    
    public var endPoint: STSPoint {
        get {
            STSPoint(tsPoint: ts_node_end_point(tsNode))
        }
    }
    
    public var childCount: uint {
        get {
            ts_node_child_count(tsNode)
        }
    }
    
    public func child(index: uint) -> STSNode? {
        
        if index < 0 || index >= childCount {
            return nil
        }
        
        let child = ts_node_child(tsNode, index)
        return STSNode(from: child)
    }
    
    public var namedChildCount: uint {
        get {
            ts_node_named_child_count(tsNode)
        }
    }
    
    public func namedChild(index: uint) -> STSNode? {
        
        if index < 0 || index >= namedChildCount {
            return nil
        }
        
        let child = ts_node_named_child(tsNode, index)
        return STSNode(from: child)
    }
    
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

extension STSNode {
    public struct STSPoint {
        let row: uint
        let column: uint
        
        init(tsPoint: TSPoint) {
            self.row = tsPoint.row
            self.column = tsPoint.column
        }
    }
}
