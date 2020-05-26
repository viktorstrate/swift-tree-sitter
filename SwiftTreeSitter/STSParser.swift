//
//  Parser.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

/// Used to produce `STSTree`s from source code
public class STSParser {
    
    internal var parserPointer: OpaquePointer!
    
    public var language: STSLanguage? {
        set(newValue) {
            ts_parser_set_language(parserPointer, newValue!.languagePointer)
        }
        
        get {
            if let languagePointer = ts_parser_language(parserPointer) {
                return STSLanguage(pointer: languagePointer)
            }
            return nil
        }
    }
    
    public var timeoutMicros: uint64 {
        get {
            ts_parser_timeout_micros(parserPointer)
        }
        
        set(timeout) {
            ts_parser_set_timeout_micros(parserPointer, timeout)
        }
    }
    
    internal let cancelPtr: UnsafeMutablePointer<Int>
    public var isCanceled: Bool {
        get {
            cancelPtr.pointee != 0
        }
        
        set(canceled) {
            cancelPtr.initialize(to: canceled ? 1 : 0)
        }
    }
    
    public init() {
        parserPointer = ts_parser_new()
        
        cancelPtr = UnsafeMutablePointer.allocate(capacity: 1)
        cancelPtr.initialize(to: 0)
        ts_parser_set_cancellation_flag(parserPointer, cancelPtr)
    }
    
    deinit {
        print("parser deleted")
        ts_parser_delete(parserPointer)
        cancelPtr.deallocate()
    }
    
    /// Parses a slice of UTF-8 text
    public func parse(string: String, oldTree: STSTree?) -> STSTree? {
        
        let treePointer = string.withCString { (stringPtr) -> OpaquePointer? in
            return ts_parser_parse_string(parserPointer, oldTree?.treePointer, stringPtr, UInt32(string.count))
        }
        
        if treePointer == nil {
            return nil
        }
        
        let tree = STSTree(pointer: treePointer!)
        return tree
    }
    
    public func printDotGraphs(file: FileHandle) {
        ts_parser_print_dot_graphs(parserPointer, file.fileDescriptor)
    }
    
    public func stopPrintingDotGraphs() {
        ts_parser_print_dot_graphs(parserPointer, -1)
    }
    
    public func reset() {
        ts_parser_reset(parserPointer)
    }
    
    public enum ParserError: Error {
        case parseString
    }
}
