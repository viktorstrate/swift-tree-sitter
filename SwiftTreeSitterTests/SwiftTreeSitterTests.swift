//
//  SwiftTreeSitterTests.swift
//  SwiftTreeSitterTests
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import XCTest
@testable import SwiftTreeSitter

class SwiftTreeSitterTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParserInit() throws {
        let parser = STSParser()
        
        print("Parser language before: \(parser.language)")
        
        parser.language = loadJsonParser()
        
        print("Parser language: \(parser.language)")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
