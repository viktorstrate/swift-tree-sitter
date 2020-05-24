//
//  Parser.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

class STSParser {
    
    fileprivate var parserPointer: OpaquePointer!
    
    var language: STSLanguage? {
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
    
    init() {
        parserPointer = ts_parser_new()
    }
    
    deinit {
        ts_parser_delete(parserPointer)
    }
    
    func parse(string: String) throws -> STSTree {
        
        let treePointer = string.withCString { (stringPtr) -> OpaquePointer? in
            return ts_parser_parse_string(parserPointer, nil, stringPtr, UInt32(string.count))
        }
        
        if treePointer == nil {
            throw ParserError.parseString
        }
        
        let tree = STSTree(pointer: treePointer!)
        
        
        return tree
    }
    
    enum ParserError: Error {
        case parseString
    }
}
