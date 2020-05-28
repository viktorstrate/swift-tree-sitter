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
    
    override func setUpWithError() throws {
        parser = STSParser()
        parser.language = try STSLanguage(fromPreBundle: .json)
    }

    func testParserLoadLanguage() throws {
        XCTAssertNotNil(parser.language)
    }
    
    func testParseString() {
        let tree = parser.parse(string: "[1,2,3]", oldTree: nil)!
        XCTAssertEqual(tree.rootNode.type, "document")
        XCTAssertEqual(tree.rootNode.sExpressionString, "(document (array (number) (number) (number)))")
    }
    
    func testParseWithCallback() {
        
        var count = 0
        let chunks = ["[1,", "2,", "\n3]"]
        
        let tree = parser.parse(callback: { (byteIndex, position) -> [Int8] in
            
            
            switch count {
            case 0:
                XCTAssertEqual(byteIndex, 0)
                XCTAssertEqual(position.row, 0)
                XCTAssertEqual(position.column, 0)
            case 1:
                XCTAssertEqual(byteIndex, 3)
                XCTAssertEqual(position.row, 0)
                XCTAssertEqual(position.column, 3)
            case 2:
                XCTAssertEqual(byteIndex, 5)
                XCTAssertEqual(position.row, 0)
                XCTAssertEqual(position.column, 5)
            case 3:
                XCTAssertEqual(byteIndex, 8)
                XCTAssertEqual(position.row, 1)
                XCTAssertEqual(position.column, 2)
            default:
                XCTAssert(false)
            }
            
            if count >= chunks.count {
                return []
            }
            
            var result = chunks[count].cString(using: .utf8)!
            result.removeLast() // remove null termination
            
            count += 1
            
            return result
            
        }, oldTree: nil)
        
        XCTAssertEqual(count, 3)
        
        XCTAssertNotNil(tree)
        XCTAssertEqual(tree!.rootNode.type, "document")
        XCTAssertEqual(tree!.rootNode.sExpressionString, "(document (array (number) (number) (number)))")
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
