//
//  STSQuery.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import CTreeSitter

public class STSQuery: Equatable, Hashable {
    
    internal let queryPointer: OpaquePointer
    internal let language: STSLanguage
    
    /**
     Create a new query from a string containing one or more S-expression patterns.

     The query is associated with a particular language, and can only be run on syntax nodes parsed with that language. References to Queries can be shared between multiple threads.
     
     - Parameters:
        - language: The language queries will be run against
        - source: A string containing one or more S-expression patterns
     */
    public init(language: STSLanguage, source: String) throws {
        
        self.language = language
        
        let errorOffset = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        let errorType = UnsafeMutablePointer<TSQueryError>.allocate(capacity: 1)
        
        defer {
            errorOffset.deallocate()
            errorType.deallocate()
        }
        
        let pointer = source.withCString { (cstr) -> OpaquePointer? in
            ts_query_new(language.languagePointer, cstr, UInt32(source.count), errorOffset, errorType)
        }
        
        switch errorType.pointee.rawValue {
        case 1:
            throw QueryError.syntax(offset: errorOffset.pointee)
        case 2:
            throw QueryError.nodeType(offset: errorOffset.pointee)
        case 3:
            throw QueryError.field(offset: errorOffset.pointee)
        case 4:
            throw QueryError.capture(offset: errorOffset.pointee)
        default:
            queryPointer = pointer!
        }
        
    }
    
    deinit {
        ts_query_delete(queryPointer)
    }
    
#if _XCODE_BUILD
    public static func loadBundledQuery(language: STSLanguage, sourceType: BundledSourceType) throws -> STSQuery? {
        
        let name: String
        switch sourceType {
        case .highlights:
            name = "highlights"
        case .injections:
            name = "injections"
        case .locals:
            name = "locals"
        case .tags:
            name = "tags"
        case .custom(let customName):
            name = customName
        }
        
        guard let url = language.bundle?.url(forResource: name, withExtension: "scm", subdirectory: "queries") else {
            return nil
        }
        
        let source = try String(contentsOf: url)
        
        return try STSQuery(language: language, source: source)
    }
    
    public enum BundledSourceType {
        case highlights
        case injections
        case locals
        case tags
        case custom(name: String)
    }
#endif
    
    /// Number of patterns the query contains
    public var patternCount: uint {
        get {
            ts_query_pattern_count(queryPointer)
        }
    }
    
    /// Number of captures the query contains
    public var captureCount: uint {
        get {
            ts_query_capture_count(queryPointer)
        }
    }
    
    public func captureName(forId id: uint) -> String {
        let lengthPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        defer {
            lengthPtr.deallocate()
        }
        
        let cstr = ts_query_capture_name_for_id(queryPointer, id, lengthPtr)
        return String(cString: cstr!)
    }
    
    /// Number of string literals the query contains
    public var stringCount: uint {
        get {
            ts_query_string_count(queryPointer)
        }
    }
    
    public func stringValue(forId id: uint) -> String {
        let lengthPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        defer {
            lengthPtr.deallocate()
        }
        
        let cstr = ts_query_string_value_for_id(queryPointer, id, lengthPtr)
        return String(cString: cstr!)
    }
    
    public func startByteForPattern(index: uint) -> uint {
        return ts_query_start_byte_for_pattern(queryPointer, index)
    }
    
    public func predicates(forPatternIndex index: uint) -> [STSQueryPredicate] {
        let lengthPtr = UnsafeMutablePointer<uint>.allocate(capacity: 1)
        defer {
            lengthPtr.deallocate()
        }
        
        guard let steps = ts_query_predicates_for_pattern(queryPointer, index, lengthPtr) else {
            return []
        }
        
        var predicates: [STSQueryPredicate] = []
        var count = 0
        
        while count < lengthPtr.pointee {
        
            var args: [STSQueryPredicateArg] = []
            let name = self.stringValue(forId: steps.pointee.value_id)
            count += 1
            
            argsLoop: for j in 1 ..< .max {
                let step = (steps + UnsafePointer<TSQueryPredicateStep>.Stride(j)).pointee
                count += 1
                
                let predicateArg: STSQueryPredicateArg
                
                switch step.type.rawValue {
                case 1:
                    predicateArg = .capture(step.value_id)
                case 2:
                    predicateArg = .string(self.stringValue(forId: step.value_id))
                default:
                    break argsLoop
                }
                
                args.append(predicateArg)
            }
            
            predicates.append(STSQueryPredicate(name: name, args: args))
        }
        
        return predicates
    }
    
    public enum QueryError: Error {
        case syntax(offset: uint)
        case nodeType(offset: uint)
        case field(offset: uint)
        case capture(offset: uint)
    }
    
    public static func == (lhs: STSQuery, rhs: STSQuery) -> Bool {
        return lhs.queryPointer == rhs.queryPointer
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(queryPointer)
    }
    
}
