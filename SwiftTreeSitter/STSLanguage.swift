//
//  STSParserLanguage.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import Foundation

class STSLanguage {
    
    let languagePointer: UnsafePointer<TSLanguage>!
    
    var version: uint {
        get {
            return ts_language_version(languagePointer) as uint
        }
    }
    
    init(pointer: UnsafePointer<TSLanguage>!) {
        self.languagePointer = pointer
    }
    
    enum PrebundledLanguage {
        case json
    }
    
    static func loadLanguage(preBundled: PrebundledLanguage) -> STSLanguage {
        let parserBundlePath = Bundle(for: STSParser.self).path(forResource: "json", ofType: "bundle", inDirectory: "Plugins/languages")!
        
        return loadLanguage(path: parserBundlePath, functionName: "tree_sitter_json")
    }
    
    static func loadLanguage(path: String, functionName: String) -> STSLanguage {
        
        let bundleURL = CFURLCreateWithFileSystemPath(
            kCFAllocatorDefault,
            path as CFString,
            .cfurlposixPathStyle,
            true)!
        
        let bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL)!
        
        let rawPointer = CFBundleGetFunctionPointerForName(bundle, functionName as CFString)!
        
        let loadLanguage = unsafeBitCast(rawPointer, to: (@convention(c)() -> UnsafePointer<TSLanguage>).self)
        
        let language = loadLanguage()
        
        return STSLanguage(pointer: language)
    }
}
