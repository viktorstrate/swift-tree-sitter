//
//  Parser.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

/// Used to produce `STSTree`s from source code
public class STSParser {
    
    internal var parserPointer: OpaquePointer!
    
    public var language: STSLanguage? {
        set(newValue) {
            ts_parser_set_language(parserPointer, newValue!.languagePointer)
        }
        
        get {
            if let languagePointer = ts_parser_language(parserPointer) {
                return STSLanguage(pointer: languagePointer)
            }
            return nil
        }
    }
    
    public var timeoutMicros: uint64 {
        get {
            ts_parser_timeout_micros(parserPointer)
        }
        
        set(timeout) {
            ts_parser_set_timeout_micros(parserPointer, timeout)
        }
    }
    
    internal let cancelPtr: UnsafeMutablePointer<Int>
    public var isCanceled: Bool {
        get {
            cancelPtr.pointee != 0
        }
        
        set(canceled) {
            cancelPtr.initialize(to: canceled ? 1 : 0)
        }
    }
    
    public init() {
        parserPointer = ts_parser_new()
        
        cancelPtr = UnsafeMutablePointer.allocate(capacity: 1)
        cancelPtr.initialize(to: 0)
        ts_parser_set_cancellation_flag(parserPointer, cancelPtr)
    }
    
    deinit {
        ts_parser_delete(parserPointer)
        cancelPtr.deallocate()
    }
    
    /// Parses a slice of UTF-8 text
    public func parse(string: String, oldTree: STSTree?) -> STSTree? {
        let treePointer = string.withCString { (stringPtr) -> OpaquePointer? in
            return ts_parser_parse_string(parserPointer, oldTree?.treePointer, stringPtr, UInt32(string.count))
        }
        
        if let treePointer = treePointer {
            return STSTree(pointer: treePointer)
        }
        
        return nil
    }
    
    public typealias ParserCallback = ((_ byteIndex: uint, _ position: STSPoint) -> [Int8])
    typealias RawParserCallback = ((UnsafeMutableRawPointer?, UInt32, TSPoint, UnsafeMutablePointer<UInt32>?) -> UnsafePointer<Int8>?)
    
    public func parse(callback: @escaping ParserCallback, oldTree: STSTree?) -> STSTree? {
        
        struct Payload {
            var callback: ParserCallback
            var bytePointes: [UnsafePointer<Int8>] = []
        }
        
        var payload = Payload(callback: callback)
        
        let tsInput = withUnsafeMutablePointer(to: &payload) { (callbackPtr) -> TSInput in
            return TSInput(
                payload: callbackPtr,
                read: { (
                    payload: UnsafeMutableRawPointer?,
                    byteIndex: UInt32,
                    position: TSPoint,
                    bytesRead: UnsafeMutablePointer<UInt32>?) -> UnsafePointer<Int8>? in
                    
                    
                    var payload = payload!.assumingMemoryBound(to: Payload.self).pointee
                    
                    let bytes = payload.callback(byteIndex, STSPoint(from: position))
                    assert(!(bytes.count > 1 && bytes.last == 0),
                           "parser callback bytes should not be null terminated")
                    
                    bytesRead!.initialize(to: UInt32(bytes.count))
                    
                    // Allocate pointer and copy bytes
                    let resultBytesPtr = UnsafeMutablePointer<Int8>.allocate(capacity: bytes.count)
                    for i in 0..<bytes.count {
                        (resultBytesPtr+i).initialize(to: bytes[i])
                    }
                    
                    payload.bytePointes.append(resultBytesPtr)
                    
                    return UnsafePointer(resultBytesPtr)
                    
                },
                encoding: TSInputEncoding(0)
            )
        }
        
        let treePointer = ts_parser_parse(parserPointer, oldTree?.treePointer, tsInput)
        
        // Release allocated bytes
        for pointer in payload.bytePointes {
            pointer.deallocate()
        }
        
        if let treePointer = treePointer {
            return STSTree(pointer: treePointer)
        }
        
        return nil
    }
    
    public func printDotGraphs(file: FileHandle) {
        ts_parser_print_dot_graphs(parserPointer, file.fileDescriptor)
    }
    
    public func stopPrintingDotGraphs() {
        ts_parser_print_dot_graphs(parserPointer, -1)
    }
    
    public func reset() {
        ts_parser_reset(parserPointer)
    }
    
    public enum ParserError: Error {
        case parseString
    }
}
