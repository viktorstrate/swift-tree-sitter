//
//  STSNode.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSNode {
    
    internal let tsNode: TSNode
    
    init(from tsNode: TSNode) {
        self.tsNode = tsNode
    }
    
    /// A numeric id for this node that is unique.
    var id: uint {
        get {
            tsNode.id.load(as: uint.self)
        }
    }
    
    var type: String {
        get {
            let cstr = ts_node_type(tsNode)!
            return String(cString: cstr)
        }
    }
    
    var typeId: uint16 {
        get {
            let symbol = ts_node_symbol(tsNode)
            return symbol
        }
    }
    
    var isNull: Bool {
        get {
            ts_node_is_null(tsNode)
        }
    }
    
    var isNamed: Bool {
        get {
            ts_node_is_named(tsNode)
        }
    }
    
    var isExtra: Bool {
        get {
            ts_node_is_extra(tsNode)
        }
    }
    
    var hasChanges: Bool {
        get {
            ts_node_has_changes(tsNode)
        }
    }
    
    var hasError: Bool {
        get {
            ts_node_has_error(tsNode)
        }
    }
    
    var isMissing: Bool {
        get {
            ts_node_is_missing(tsNode)
        }
    }
    
    var startByte: uint {
        get {
            ts_node_start_byte(tsNode)
        }
    }
    
    var endByte: uint {
        get {
            ts_node_end_byte(tsNode)
        }
    }
    
    var byteRange: Range<uint> {
        get {
            startByte ..< endByte
        }
    }
    
    var startPoint: STSPoint {
        get {
            STSPoint(tsPoint: ts_node_start_point(tsNode))
        }
    }
    
    var endPoint: STSPoint {
        get {
            STSPoint(tsPoint: ts_node_end_point(tsNode))
        }
    }
    
    var childCount: uint {
        get {
            ts_node_child_count(tsNode)
        }
    }
    
    func child(index: uint) -> STSNode? {
        
        if index < 0 || index >= childCount {
            return nil
        }
        
        let child = ts_node_child(tsNode, index)
        return STSNode(from: child)
    }
    
    var namedChildCount: uint {
        get {
            ts_node_named_child_count(tsNode)
        }
    }
    
    func namedChild(index: uint) -> STSNode? {
        
        if index < 0 || index >= namedChildCount {
            return nil
        }
        
        let child = ts_node_named_child(tsNode, index)
        return STSNode(from: child)
    }
    
}

extension STSNode {
    struct STSPoint {
        let row: uint
        let column: uint
        
        init(tsPoint: TSPoint) {
            self.row = tsPoint.row
            self.column = tsPoint.column
        }
    }
}
