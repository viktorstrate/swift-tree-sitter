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
    
    public init() {
        parserPointer = ts_parser_new()
    }
    
    deinit {
        print("parser deleted")
        ts_parser_delete(parserPointer)
    }
    
    /// Parses a slice of UTF-8 text
    public func parse(string: String, oldTree: STSTree?) throws -> STSTree {
        
        let treePointer = string.withCString { (stringPtr) -> OpaquePointer? in
            return ts_parser_parse_string(parserPointer, oldTree?.treePointer, stringPtr, UInt32(string.count))
        }
        
        if treePointer == nil {
            throw ParserError.parseString
        }
        
        let tree = STSTree(pointer: treePointer!)
        
        
        return tree
    }
    
    public func printDotGraphs(file: FileHandle) {
        ts_parser_print_dot_graphs(self.parserPointer, file.fileDescriptor)
    }
    
    public func stopPrintingDotGraphs() {
        ts_parser_print_dot_graphs(self.parserPointer, -1)
    }
    
    public enum ParserError: Error {
        case parseString
    }
}
