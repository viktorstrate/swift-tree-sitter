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
    
    func testLoadLanguages() {
        let _ = STSLanguage.loadLanguage(preBundled: .java)
        let _ = STSLanguage.loadLanguage(preBundled: .javascript)
        let _ = STSLanguage.loadLanguage(preBundled: .json)
    }
    
}
