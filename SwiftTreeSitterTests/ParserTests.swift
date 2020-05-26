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
    
    func testParseString() throws {
        let tree = try! parser.parse(string: "[1,2,3]", oldTree: nil)
        XCTAssertEqual(tree.rootNode.type, "document")
        XCTAssertEqual(tree.rootNode.sExpressionString, "(document (array (number) (number) (number)))")
    }

}
