//
//  STSParserLanguage.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import Foundation

func loadJsonParser() -> UnsafePointer<TSLanguage> {
    let parserBundlePath = Bundle(for: STSParser.self).path(forResource: "parserJSON", ofType: "bundle", inDirectory: "Plugins/parsers")!
    
    let bundleURL = CFURLCreateWithFileSystemPath(
        kCFAllocatorDefault,
        parserBundlePath as CFString,
        .cfurlposixPathStyle,
        true)!
    
    let bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL)!
    
    let rawPointer = CFBundleGetFunctionPointerForName(bundle, "tree_sitter_json" as CFString)!
    
    let loadLanguage = unsafeBitCast(rawPointer, to: (@convention(c)() -> UnsafePointer<TSLanguage>).self)
    
    let language = loadLanguage()
    
    return language
    
    //let pointer: UnsafePointer<TSLanguage> = UnsafePointer(rawPointer.bindMemory(to: TSLanguage.self, capacity: 1))
    //return pointer
}
