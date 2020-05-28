//
//  STSParserLanguage.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public class STSLanguage: Equatable, Hashable {
    
    internal let languagePointer: UnsafePointer<TSLanguage>!
    internal var bundle: Bundle?
    
    public var bundlePath: String? {
        get {
            bundle?.bundlePath
        }
    }
    
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
        
        func bundle() throws -> Bundle {
            let languageName = self.rawValue
            
            guard let bundlePath = Bundle(for: STSParser.self).path(forResource: languageName, ofType: "bundle", inDirectory: "Plugins/languages") else {
                
                throw LanguageError.prebundledBundleNotFound
            }
            
            
            return Bundle(path: bundlePath)!
        }
    }
    
    public convenience init(fromPreBundle preBundle: PrebundledLanguage) throws {
        let bundle = try preBundle.bundle()
        try self.init(fromBundle: bundle)
    }
    
    public convenience init(fromBundle bundle: Bundle) throws {
        
        guard let functionName = bundle.infoDictionary!["STSLoadFunction"] as? String else {
            throw LanguageError.malformedLanguageBundle(message: "STSLoadFunction entry missing in info.plist")
        }
        
        try self.init(bundle: bundle, functionName: functionName)
    }
    
    internal convenience init(bundle: Bundle, functionName: String) throws {
        
        let path = bundle.bundlePath
        
        let bundleURL = CFURLCreateWithFileSystemPath(
            kCFAllocatorDefault,
            path as CFString,
            .cfurlposixPathStyle,
            true)!
        
        let cfBundle = CFBundleCreate(kCFAllocatorDefault, bundleURL)!
        
        guard let rawPointer = CFBundleGetFunctionPointerForName(cfBundle, functionName as CFString) else {
            throw LanguageError.malformedLanguageBundle(message: "Could not load function pointer")
        }
        
        let loadLanguage = unsafeBitCast(rawPointer, to: (@convention(c)() -> UnsafePointer<TSLanguage>).self)
        let languagePtr = loadLanguage()
        
        self.init(pointer: languagePtr)
        
        self.bundle = bundle
    }
    
    enum LanguageError: Error {
        case prebundledBundleNotFound
        case malformedLanguageBundle(message: String)
    }
    
    public static func == (lhs: STSLanguage, rhs: STSLanguage) -> Bool {
        return lhs.languagePointer == rhs.languagePointer &&
            lhs.bundle == rhs.bundle
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(languagePointer)
        hasher.combine(bundle)
    }
}
