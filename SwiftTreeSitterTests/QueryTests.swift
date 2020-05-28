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
