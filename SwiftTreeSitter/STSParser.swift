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
    
    var language: UnsafePointer<TSLanguage>? {
        set(newValue) {
            ts_parser_set_language(parserPointer, newValue)
        }
        
        get {
            return ts_parser_language(parserPointer)
        }
    }
    
    init() {
        parserPointer = ts_parser_new()
    }
    
    deinit {
        ts_parser_delete(parserPointer)
    }
    
    func parse(string: String) -> STSTree {
        return STSTree()
    }
}
