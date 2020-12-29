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
              (#match? @constant "^[A-Z][A-Z_]+")
              (#eq? @constant "test"))
        """)
        
        var predicates = query.predicates(forPatternIndex: 0)
        XCTAssertEqual(predicates.count, 1)
        XCTAssertEqual(predicates.first?.name, "set!")
        XCTAssertEqual(predicates.first?.args[0], STSQueryPredicateArg.string("injection.language"))
        XCTAssertEqual(predicates.first?.args[1], STSQueryPredicateArg.string("javascript"))
        XCTAssertEqual(predicates.first?.args.count, 2)
        
        predicates = query.predicates(forPatternIndex: 1)
        XCTAssertEqual(predicates.count, 2)
        XCTAssertEqual(predicates[1].name, "match?")
        XCTAssertEqual(predicates[1].args[0], STSQueryPredicateArg.capture(1))
        XCTAssertEqual(predicates[1].args[1], STSQueryPredicateArg.string("^[A-Z][A-Z_]+"))
        XCTAssertEqual(predicates[1].args.count, 2)
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
    
#if _XCODE_BUILD_
    func testLoadingQueryFromBundle() throws {
        let language = try STSLanguage(fromPreBundle: .javascript)
        
        let highlights = try STSQuery.loadBundledQuery(language: language, sourceType: .highlights)
        XCTAssertNotNil(highlights)
        
        let highlightsJsx = try STSQuery.loadBundledQuery(language: language,
                                                          sourceType: .custom(name: "highlights-jsx"))
        XCTAssertNotNil(highlightsJsx)
    }
#endif
}
