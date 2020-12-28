//
//  STSParserLanguage.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 24/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import CTreeSitter
import TreeSitterLanguages
import Foundation

public class STSLanguage: Equatable, Hashable {
    
    internal let languagePointer: UnsafePointer<TSLanguage>!
    internal var bundle: Bundle?
    
    /// The path to the bundle that the language was loaded from.
    public var bundlePath: String? {
        get {
            bundle?.bundlePath
        }
    }
    
    init(pointer: UnsafePointer<TSLanguage>!) {
        self.languagePointer = pointer
    }
    
    /// The version of the language parser.
    public var version: uint {
        get {
            return ts_language_version(languagePointer) as uint
        }
    }
    
    /// Get the number of distinct node types in the language.
    public var symbolCount: uint {
        get {
            return ts_language_symbol_count(languagePointer)
        }
    }
    
    /// Get a node type string for the given numerical id.
    public func symbolName(forId id: uint) -> String? {
        let cstr = ts_language_symbol_name(languagePointer, UInt16(id))
        if let cstr = cstr {
            return String(cString: cstr)
        }
        
        return nil
    }
    
    /// Get the numerical id for the given node type string.
    public func symbolId(forName name: String, isNamed: Bool) -> uint {
        let result = name.withCString { (cstr) -> UInt16 in
            ts_language_symbol_for_name(languagePointer, cstr, uint(name.count), isNamed)
        }
        
        return uint(result)
    }
    
    /**
     Check whether the given node type id belongs to named nodes, anonymous nodes,
     or a hidden nodes.
     
     See also `node.isNamed`. Hidden nodes are never returned from the API.
     */
    public func symbolType(forId id: uint) -> SymbolType {
        let type = ts_language_symbol_type(languagePointer, UInt16(id))
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
    
    /// Get the number of distinct field names in the language.
    public var fieldCount: uint {
        get {
            return ts_language_field_count(languagePointer)
        }
    }
    
    /// Get the field name string for the given numerical id.
    public func fieldId(forName name: String) -> uint {
        let result = name.withCString { (cstr) -> UInt16 in
            ts_language_field_id_for_name(languagePointer, cstr, uint(name.count))
        }
        
        return uint(result)
    }
    
    /// Get the numerical id for the given field name string.
    public func fieldName(forId id: uint) -> String? {
        let cstr = ts_language_field_name_for_id(languagePointer, UInt16(id))
        if let cstr = cstr {
            return String(cString: cstr)
        }
        
        return nil
    }

    public enum PrebundledLanguage: String {
        case css = "css"
        case html = "html"
        case java = "java"
        case javascript = "javascript"
        case json = "json"
        case php = "php"

#if _XCODE_BUILD_
        public func bundle() throws -> Bundle {
            let languageName = self.rawValue
            
            guard let bundlePath = Bundle(for: STSParser.self).path(forResource: languageName, ofType: "bundle", inDirectory: "PlugIns/languages") else {
                
                throw LanguageError.prebundledBundleNotFound
            }
            
            
            return Bundle(path: bundlePath)!
        }
#endif
    }

    /**
     Initialize a language from one of the pre-bundled ones.
     
     # Example
     
     ```
     let language = STSLanguage(preBundle: .javascript)
     ```
     */
    public convenience init(fromPreBundle preBundle: PrebundledLanguage) throws {
#if _XCODE_BUILD_
        let bundle = try preBundle.bundle()
        try self.init(fromBundle: bundle)
#else
        switch preBundle {
        case .css:
            self.init(pointer: tree_sitter_css())
        case .html:
            self.init(pointer: tree_sitter_html())
        case .java:
            self.init(pointer: tree_sitter_java())
        case .javascript:
            self.init(pointer: tree_sitter_javascript())
        case .json:
            self.init(pointer: tree_sitter_json())
        case .php:
            self.init(pointer: tree_sitter_php())
        }
#endif
    }
    
#if _XCODE_BUILD_
    /// Initialize a language from the given language bundle.
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
#endif
    
    enum LanguageError: Error {
        case prebundledBundleNotFound
        case malformedLanguageBundle(message: String)
    }
    
    public static func == (lhs: STSLanguage, rhs: STSLanguage) -> Bool {
#if os(WASI)
        return lhs.languagePointer == rhs.languagePointer
#else
        return lhs.languagePointer == rhs.languagePointer &&
            lhs.bundle == rhs.bundle
#endif
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(languagePointer)
#if !os(WASI)
        hasher.combine(bundle)
#endif
    }
}
