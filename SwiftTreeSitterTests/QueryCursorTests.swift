//
//  QueryCursorTests.swift
//  SwiftTreeSitterTests
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import XCTest
@testable import SwiftTreeSitter

class QueryCursorTests: XCTestCase {
    
    var query: STSQuery!
    var tree: STSTree!
    
    override func setUpWithError() throws {
        let language = try STSLanguage(fromPreBundle: .javascript)
        
        query = try STSQuery(language: language, source: """
            ; Function and method definitions
            ;--------------------------------
            (function
              name: (identifier) @function)
            (function_declaration
              name: (identifier) @function)
            (method_definition
              name: (property_identifier) @function.method)
        """)
        
        let parser = STSParser()
        parser.language = language
        tree = parser.parse(string: "function sum(a, b) { return a + b }", oldTree: nil)
        
    }
    
    func testQueryMatches() {
        let cursor = STSQueryCursor()
        let matches = cursor.matches(query: query, onNode: tree.rootNode)
        
        let match = matches.next()
        
        XCTAssertNotNil(match)
        XCTAssertEqual(query.captureName(forId: match!.id), "function")
        
        XCTAssertNil(matches.next())
    }
    
    func testQueryCaptures() {
        let cursor = STSQueryCursor()
        let captures = cursor.captures(query: query, onNode: tree.rootNode)
        
        let capture = captures.next()
        
        XCTAssertNotNil(capture)
        XCTAssertNil(captures.next())
    }
}
