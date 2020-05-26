//
//  STSParserLanguage.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSLanguage {
    
    internal let languagePointer: UnsafePointer<TSLanguage>!
    
    init(pointer: UnsafePointer<TSLanguage>!) {
        self.languagePointer = pointer
    }
    
    public var version: uint {
        get {
            return ts_language_version(languagePointer) as uint
        }
    }
    
    public var symbolCount: uint {
        get {
            return ts_language_symbol_count(languagePointer)
        }
    }
    
    public func symbolName(forId id: uint) -> String? {
        let cstr = ts_language_symbol_name(languagePointer, uint16(id))
        if let cstr = cstr {
            return String(cString: cstr)
        }
        
        return nil
    }
    
    public func symbolId(forName name: String, isNamed: Bool) -> uint {
        let result = name.withCString { (cstr) -> uint16 in
            ts_language_symbol_for_name(languagePointer, cstr, uint(name.count), isNamed)
        }
        
        return uint(result)
    }
    
    public func symbolType(forId id: uint) -> SymbolType {
        let type = ts_language_symbol_type(languagePointer, uint16(id))
        switch type {
        case .init(0):
            return .regular
        case .init(1):
            return .anonymous
        case .init(2):
            return .auxillary
        default:
            fatalError()
        }
    }
    
    public enum SymbolType {
        case regular
        case anonymous
        case auxillary
    }
    
    public var fieldCount: uint {
        get {
            return ts_language_field_count(languagePointer)
        }
    }
    
    public func fieldId(forName name: String) -> uint {
        let result = name.withCString { (cstr) -> uint16 in
            ts_language_field_id_for_name(languagePointer, cstr, uint(name.count))
        }
        
        return uint(result)
    }
    
    public func fieldName(forId id: uint) -> String? {
        let cstr = ts_language_field_name_for_id(languagePointer, uint16(id))
        if let cstr = cstr {
            return String(cString: cstr)
        }
        
        return nil
    }
    
    public enum PrebundledLanguage: String {
        case java = "java"
        case javascript = "javascript"
        case json = "json"
    }
    
    public static func loadLanguage(preBundled: PrebundledLanguage) -> STSLanguage {
        let languageName = preBundled.rawValue
        
        let parserBundlePath = Bundle(for: STSParser.self).path(forResource: languageName, ofType: "bundle", inDirectory: "Plugins/languages")!
        
        let functionName = Bundle(path: parserBundlePath)!.infoDictionary!["STSLoadFunction"] as! String
        
        return loadLanguage(path: parserBundlePath, functionName: functionName)
    }
    
    public static func loadLanguage(path: String, functionName: String) -> STSLanguage {
        
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
