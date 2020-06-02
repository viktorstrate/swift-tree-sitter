//
//  STSQueryCursor.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSQueryCursor {
    
    internal var byteRange: (uint, uint)?
    internal var pointRange: (STSPoint, STSPoint)?
    
    public init() {}
    
    public init(byteRangeFrom start: uint, to end: uint) {
        self.byteRange = (start, end)
    }
    
    public init(pointRangeFrom start: STSPoint, end: STSPoint) {
        self.pointRange = (start, end)
    }
    
    internal static func setRanges(cursor: STSQueryCursor, pointer: OpaquePointer) {
        if let (start, end) = cursor.byteRange {
            ts_query_cursor_set_byte_range(pointer, start, end)
        }
        
        if let (start, end) = cursor.pointRange {
            ts_query_cursor_set_point_range(pointer, start.tsPoint, end.tsPoint)
        }
        
    }
    
    public func matches(query: STSQuery, onNode node: STSNode) -> MatchSequence {       
        return MatchSequence(queryCursor: self, query: query, node: node)
    }
    
    public class MatchSequence: Sequence, IteratorProtocol {
        
        let queryCursor: STSQueryCursor
        let cursorPointer: OpaquePointer
        let query: STSQuery
        let node: STSNode
        
        fileprivate init(queryCursor: STSQueryCursor, query: STSQuery, node: STSNode) {
            self.queryCursor = queryCursor
            self.cursorPointer = ts_query_cursor_new()
            self.query = query
            self.node = node
            
            STSQueryCursor.setRanges(cursor: queryCursor, pointer: cursorPointer)
            ts_query_cursor_exec(cursorPointer, query.queryPointer, node.tsNode)
        }
        
        deinit {
            ts_query_cursor_delete(cursorPointer)
        }
        
        public func makeIterator() -> STSQueryCursor.MatchSequence {
            return MatchSequence(queryCursor: self.queryCursor, query: query, node: node)
        }
        
        public func next() -> STSQueryMatch? {
            let matchPtr = UnsafeMutablePointer<TSQueryMatch>.allocate(capacity: 1)
            
            if ts_query_cursor_next_match(cursorPointer, matchPtr) == false {
                return nil
            }
            
            var captures: [STSQueryCapture] = []
            var capturePtr = matchPtr.pointee.captures!
            
            for _ in 0..<matchPtr.pointee.capture_count {
                
                let node = STSNode(from: capturePtr.pointee.node)
                let capture = STSQueryCapture(query: query, node: node, index: capturePtr.pointee.index)
                
                captures.append(capture)
                
                capturePtr = capturePtr.successor()
            }
            
            let matchId = matchPtr.pointee.id
            let matchIndex = uint(matchPtr.pointee.pattern_index)
            
            let match = STSQueryMatch(id: matchId, index: matchIndex, captures: captures)
            return match
        }
    }
    
    public func captures(query: STSQuery, onNode node: STSNode) -> CaptureSequence {
        return CaptureSequence(queryCursor: self, query: query, node: node)
    }

    public class CaptureSequence: Sequence, IteratorProtocol {

        let queryCursor: STSQueryCursor
        let cursorPointer: OpaquePointer
        let query: STSQuery
        let node: STSNode
        
        fileprivate init(queryCursor: STSQueryCursor, query: STSQuery, node: STSNode) {
            self.queryCursor = queryCursor
            self.cursorPointer = ts_query_cursor_new()
            self.query = query
            self.node = node
            
            STSQueryCursor.setRanges(cursor: queryCursor, pointer: cursorPointer)
            ts_query_cursor_exec(cursorPointer, query.queryPointer, node.tsNode)
        }
        
        deinit {
            ts_query_cursor_delete(cursorPointer)
        }
        
        public func makeIterator() -> STSQueryCursor.CaptureSequence {
            return CaptureSequence(queryCursor: self.queryCursor, query: query, node: node)
        }

        public func next() -> STSQueryCapture? {
            let matchPtr = UnsafeMutablePointer<TSQueryMatch>.allocate(capacity: 1)
            let captureIndex = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)

            if ts_query_cursor_next_capture(cursorPointer, matchPtr, captureIndex) == false {
                return nil
            }

            let capturePtr = matchPtr.pointee.captures + Int(captureIndex.pointee)

            let node = STSNode(from: capturePtr.pointee.node)
            let capture = STSQueryCapture(query: query, node: node, index: capturePtr.pointee.index)

            return capture
        }
    }
    
}
