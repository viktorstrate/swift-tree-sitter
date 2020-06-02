//
//  QueryTests.swift
//  SwiftTreeSitterTests
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import XCTest
@testable import SwiftTreeSitter

class QueryTests: XCTestCase {
    
    func testQueryPredicates() throws {
        let language = try STSLanguage(fromPreBundle: .html)
        let query = try STSQuery(language: language, source: """
            ((script_element
              (raw_text) @injection.content)
             (#set! injection.language "javascript"))

            ((tag_name) @constant
              (#eq? @constant "test"))
        """)
        
        var predicates = query.predicates(forPatternIndex: 0)
        XCTAssertEqual(predicates?.name, "set!")
        XCTAssertEqual(predicates?.args[0], STSQueryPredicateArg.string("injection.language"))
        XCTAssertEqual(predicates?.args[1], STSQueryPredicateArg.string("javascript"))
        XCTAssertEqual(predicates?.args.count, 2)
        
        predicates = query.predicates(forPatternIndex: 1)
        XCTAssertEqual(predicates?.name, "eq?")
        XCTAssertEqual(predicates?.args[0], STSQueryPredicateArg.capture(1))
        XCTAssertEqual(predicates?.args[1], STSQueryPredicateArg.string("test"))
        XCTAssertEqual(predicates?.args.count, 2)
    }
    
    func testQueryValues() throws {
        let language = try STSLanguage(fromPreBundle: .javascript)
        let query = try STSQuery(language: language, source: """
            ; Function and method definitions
            ;--------------------------------
            (function
              name: (identifier) @function)
            (function_declaration
              name: (identifier) @function)
            (method_definition
              name: (property_identifier) @function.method)
        """)
        
        XCTAssertEqual(query.captureCount, 2)
        XCTAssertEqual(query.patternCount, 3)
        XCTAssertEqual(query.stringCount, 0)
    }
    
    func testLoadingQueryFromBundle() throws {
        let language = try STSLanguage(fromPreBundle: .javascript)
        
        let highlights = try STSQuery.loadBundledQuery(language: language, sourceType: .highlights)
        XCTAssertNotNil(highlights)
        
        let highlightsJsx = try STSQuery.loadBundledQuery(language: language,
                                                          sourceType: .custom(name: "highlights-jsx"))
        XCTAssertNotNil(highlightsJsx)
    }
}
