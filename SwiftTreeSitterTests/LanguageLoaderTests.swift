//
//  LanguageLoaderTests.swift
//  SwiftTreeSitterTests
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import XCTest
@testable import SwiftTreeSitter

class LanguageLoaderTests: XCTestCase {
    
    func testLoadLanguages() throws {
        let _ = try STSLanguage.loadLanguage(fromPreBundle: .java)
        let _ = try STSLanguage.loadLanguage(fromPreBundle: .javascript)
        let _ = try STSLanguage.loadLanguage(fromPreBundle: .json)
    }
    
}
