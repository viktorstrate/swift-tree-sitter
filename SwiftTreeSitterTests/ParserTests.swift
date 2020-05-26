//
//  SwiftTreeSitterTests.swift
//  SwiftTreeSitterTests
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import XCTest
@testable import SwiftTreeSitter

class ParserTests: XCTestCase {

    private var parser: STSParser!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        parser = STSParser()
        parser.language = STSLanguage.loadLanguage(preBundled: .json)
    }

    func testParserLoadLanguage() throws {
        XCTAssertNotNil(parser.language)
    }
    
    func testParseString() {
        let tree = parser.parse(string: "[1,2,3]", oldTree: nil)!
        XCTAssertEqual(tree.rootNode.type, "document")
        XCTAssertEqual(tree.rootNode.sExpressionString, "(document (array (number) (number) (number)))")
    }
    
    func testCancellation() {
        
        let longJson = "[ \(String.init(repeating: "123,", count: 200)) 123 ]"
        
        parser.isCanceled = true
        let treeCanceled = parser.parse(string: longJson, oldTree: nil)
        XCTAssertNil(treeCanceled)
        
        parser.reset()
        parser.isCanceled = false
        let treeNotCanceled = parser.parse(string: longJson, oldTree: nil)
        XCTAssertNotNil(treeNotCanceled)
        
    }

    func testTimeout() {
        XCTAssertNotEqual(parser.timeoutMicros, 12345)
        parser.timeoutMicros = 12345
        XCTAssertEqual(parser.timeoutMicros, 12345)
    }
    
}
