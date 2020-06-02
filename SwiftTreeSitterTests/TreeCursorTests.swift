//
//  TreeCursorTests.swift
//  SwiftTreeSitterTests
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import XCTest
@testable import SwiftTreeSitter

class TreeCursorTests: XCTestCase {
    
    var cursor: STSTreeCursor!
    
    override func setUpWithError() throws {
        let language = try STSLanguage(fromPreBundle: .json)
        let parser = STSParser(language: language)
        
        let tree = parser.parse(string: "[1,null, 3]", oldTree: nil)!
        self.cursor = tree.walk()
    }
    
    func testGotoFunctions() throws {
        XCTAssertEqual(cursor.gotoFirstChild(), true)
        XCTAssertEqual(cursor.currentNode.type, "array")
        
        XCTAssertEqual(cursor.gotoFirstChild(), true)
        XCTAssertEqual(cursor.gotoNextSibling(), true)
        XCTAssertEqual(cursor.currentNode.type, "number")
    }
    
}
