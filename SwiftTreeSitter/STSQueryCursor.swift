//
//  STSQueryCursor.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSQueryCursor {
    
    let cursorPointer: OpaquePointer!
    
    public init() {
        self.cursorPointer = ts_query_cursor_new()
    }
    
    deinit {
        ts_query_cursor_delete(cursorPointer)
    }
    
    public func matches(query: STSQuery, onNode node: STSNode) -> MatchIterator {
        ts_query_cursor_exec(cursorPointer, query.queryPointer, node.tsNode)
        
        return MatchIterator(cursorPointer: cursorPointer)
    }
    
    public class MatchIterator: IteratorProtocol {
        
        internal let cursorPointer: OpaquePointer!
        
        fileprivate init(cursorPointer: OpaquePointer!) {
            self.cursorPointer = cursorPointer
        }
        
        public func next() -> STSQueryMatch? {
            let matchPtr = UnsafeMutablePointer<TSQueryMatch>.allocate(capacity: 1)
            
            if ts_query_cursor_next_match(cursorPointer, matchPtr) == false {
                return nil
            }
            
            var captures: [STSQueryCapture] = []
            var capturePtr = matchPtr.pointee.captures!
            
            for _ in 0...matchPtr.pointee.capture_count {
                
                let node = STSNode(from: capturePtr.pointee.node)
                let capture = STSQueryCapture(node: node, index: capturePtr.pointee.index)
                
                captures.append(capture)
                
                capturePtr = capturePtr.successor()
            }
            
            let matchId = matchPtr.pointee.id
            let matchIndex = uint(matchPtr.pointee.pattern_index)
            
            let match = STSQueryMatch(id: matchId, index: matchIndex, captures: captures)
            return match
        }
    }
    
    public func captures(query: STSQuery, onNode node: STSNode) -> CaptureIterator {
        ts_query_cursor_exec(cursorPointer, query.queryPointer, node.tsNode)
        return CaptureIterator(cursorPointer: cursorPointer)
    }
    
    public class CaptureIterator: IteratorProtocol {
        
        internal let cursorPointer: OpaquePointer!
        
        fileprivate init(cursorPointer: OpaquePointer!) {
            self.cursorPointer = cursorPointer
        }
        
        public func next() -> STSQueryCapture? {
            let matchPtr = UnsafeMutablePointer<TSQueryMatch>.allocate(capacity: 1)
            let captureIndex = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
            
            if ts_query_cursor_next_capture(cursorPointer, matchPtr, captureIndex) == false {
                return nil
            }
            
            let capturePtr = matchPtr.pointee.captures + Int(captureIndex.pointee)
            
            let node = STSNode(from: capturePtr.pointee.node)
            let capture = STSQueryCapture(node: node, index: capturePtr.pointee.index)
            
            return capture
        }
    }
    
}
