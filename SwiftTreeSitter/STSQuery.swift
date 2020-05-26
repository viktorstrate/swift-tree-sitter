//
//  STSQuery.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSQuery {
    
    internal let queryPointer: OpaquePointer
    
    /**
     Create a new query from a string containing one or more S-expression patterns.

     The query is associated with a particular language, and can only be run on syntax nodes parsed with that language. References to Queries can be shared between multiple threads.
     
     - Parameters:
        - language: The language queries will be run against
        - source: A string containing one or more S-expression patterns
     */
    init(language: STSLanguage, source: String) throws {
        
        let errorOffset = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        let errorType = UnsafeMutablePointer<TSQueryError>.allocate(capacity: 1)
        
        defer {
            errorOffset.deallocate()
            errorType.deallocate()
        }
        
        let pointer = source.withCString { (cstr) -> OpaquePointer? in
            ts_query_new(language.languagePointer, cstr, UInt32(source.count), errorOffset, errorType)
        }
        
        switch errorType.pointee.rawValue {
        case 1:
            throw QueryError.syntax(offset: errorOffset.pointee)
        case 2:
            throw QueryError.nodeType(offset: errorOffset.pointee)
        case 3:
            throw QueryError.field(offset: errorOffset.pointee)
        case 4:
            throw QueryError.capture(offset: errorOffset.pointee)
        default:
            queryPointer = pointer!
        }
        
    }
    
    deinit {
        ts_query_delete(queryPointer)
    }
    
    var patternCount: uint {
        get {
            ts_query_pattern_count(queryPointer)
        }
    }
    
    var captureCount: uint {
        get {
            ts_query_capture_count(queryPointer)
        }
    }
    
    var stringCount: uint {
        get {
            ts_query_string_count(queryPointer)
        }
    }
    
    func startByteForPattern(index: uint) -> uint {
        return ts_query_start_byte_for_pattern(queryPointer, index)
    }
    
    enum QueryError: Error {
        case syntax(offset: uint)
        case nodeType(offset: uint)
        case field(offset: uint)
        case capture(offset: uint)
    }
    
}
