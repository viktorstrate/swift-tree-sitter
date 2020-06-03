//
//  Parser.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

/// Used to produce `STSTree`s from source code
public class STSParser: Equatable, Hashable {
    
    internal var parserPointer: OpaquePointer!
    
    /// The language that the parser should use for parsing.
    public var language: STSLanguage {
        set(newValue) {
            ts_parser_set_language(parserPointer, newValue.languagePointer)
        }
        
        get {
            let languagePointer = ts_parser_language(parserPointer)!
            return STSLanguage(pointer: languagePointer)
        }
    }
    
    /// The maximum duration in microseconds that parsing should be allowed to take before halting.
    public var timeoutMicros: UInt64 {
        get {
            ts_parser_timeout_micros(parserPointer)
        }
        
        set(timeout) {
            ts_parser_set_timeout_micros(parserPointer, timeout)
        }
    }
    
    internal let cancelPtr: UnsafeMutablePointer<Int>
    
    /// The parser will periodically read this value during parsing. If it reads `false`, it will halt early, returning `nil`.
    public var isCanceled: Bool {
        get {
            cancelPtr.pointee != 0
        }
        
        set(canceled) {
            cancelPtr.initialize(to: canceled ? 1 : 0)
        }
    }
    
    /// Get the ranges of text that the parser will include when parsing.
    public var includedRanges: [STSRange] {
        get {
            let lengthPtr = UnsafeMutablePointer<uint>.allocate(capacity: 1)
            defer {
                lengthPtr.deallocate()
            }
            
            guard let rangePtrs = ts_parser_included_ranges(parserPointer, lengthPtr) else {
                return []
            }
            
            var ranges: [STSRange] = []
            
            for i in 0 ..< lengthPtr.pointee {
                let tsRange = (rangePtrs + UnsafePointer<TSRange>.Stride(i)).pointee
                ranges.append(STSRange(tsRange: tsRange))
            }
            
            return ranges
        }
    }
    
    /**
        Set the ranges of text that the parser should include when parsing.
        
        By default, the parser will always include entire documents. This function
        allows you to parse only a *portion* of a document but still return a syntax
        tree whose ranges match up with the document as a whole. You can also pass
        multiple disjoint ranges.
        
        If `length` is zero, then the entire document will be parsed. Otherwise,
        the given ranges must be ordered from earliest to latest in the document,
        and they must not overlap. That is, the following must hold for all
        `i < length - 1`:
        
        ```
        ranges[i].endByte <= ranges[i + 1].startByte
        ```
        
        If this requirement is not satisfied, the operation will fail, the ranges
        will not be assigned, and this function will return `false`. On success,
        this function returns `true`
     */
    public func setIncludedRanges(_ ranges: [STSRange]) -> Bool {
        let tsRanges = ranges.map { $0.tsRange }
        
        let success = tsRanges.withUnsafeBufferPointer { (rangesPtr) -> Bool in
            return ts_parser_set_included_ranges(parserPointer, rangesPtr.baseAddress, uint(tsRanges.count))
        }
        
        return success
    }
    
    /// Clear the previously set included ranges and instead include the entire document.
    public func clearIncludedRanges() {
        let success = ts_parser_set_included_ranges(parserPointer, nil, uint(0))
        assert(success, "clearing the parser should always be successful")
    }
    
    public init(language: STSLanguage) {
        self.parserPointer = ts_parser_new()
        
        cancelPtr = UnsafeMutablePointer.allocate(capacity: 1)
        cancelPtr.initialize(to: 0)
        ts_parser_set_cancellation_flag(parserPointer, cancelPtr)
        
        self.language = language
    }
    
    deinit {
        ts_parser_delete(parserPointer)
        cancelPtr.deallocate()
    }
    
    /// Parses a string, returning a `STSTree` representing the AST for the given string.
    public func parse(string: String, oldTree: STSTree?) -> STSTree? {
        let treePointer = string.withCString { (stringPtr) -> OpaquePointer? in
            return ts_parser_parse_string(parserPointer, oldTree?.treePointer, stringPtr, UInt32(string.count))
        }
        
        if let treePointer = treePointer {
            return STSTree(pointer: treePointer)
        }
        
        return nil
    }
    
    /**
         A function to retrieve a chunk of text at a given byte offset
         and (row, column) position.
     
         - Parameters:
            - byteIndex: The offset to receive the text from
            - position: The row and column position to receive text from
     
         - Returns: A byte array representing the chunk of text.
                    An empty array indicates the end of the document
     */
    public typealias ParserCallback = ((_ byteIndex: uint, _ position: STSPoint) -> [Int8])
    typealias RawParserCallback = ((UnsafeMutableRawPointer?, UInt32, TSPoint, UnsafeMutablePointer<UInt32>?) -> UnsafePointer<Int8>?)
    
    /**
        Use the parser to parse some source code and create a syntax tree.
     
        This function returns a syntax tree on success, and `nil` on failure. There
        are three possible reasons for failure:
         
        1. The parser does not have a language assigned. Check for this using the
        `language` attribute.
     
        2. Parsing was cancelled due to a timeout that was set by an earlier assignment to
        the `timeoutMicros` attribute. You can resume parsing from
        where the parser left out by calling this function again with the
        same arguments. Or you can start parsing from scratch by first calling
        `parser.reset()`.
        
        3. Parsing was cancelled using a cancellation flag that was set by an
        earlier assignment to `isCanceled`. You can resume parsing
        from where the parser left out by calling this function again with
        the same arguments.
     
         - Parameters:
            - callback:
                The callback to provide the source code to parse.
                
            - oldTree:
                If you are parsing this document for the first time, pass `nil`. Otherwise, if you have already parsed an earlier
                version of this document and the document has since been edited, pass the
                previous syntax tree so that the unchanged parts of it can be reused.
                This will save time and memory. For this to work correctly, you must have
                already edited the old syntax tree using the `tree.edit()` function in a
                way that exactly matches the source code changes.
     */
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
    
    /**
        Set the file descriptor to which the parser should write debugging graphs
        during parsing. The graphs are formatted in the DOT language. You may want
        to pipe these graphs directly to a `dot(1)` process in order to generate
        SVG output.
     */
    public func printDotGraphs(file: FileHandle) {
        ts_parser_print_dot_graphs(parserPointer, file.fileDescriptor)
    }
    
    /// Turn off the dot printing graph.
    public func stopPrintingDotGraphs() {
        ts_parser_print_dot_graphs(parserPointer, -1)
    }
    
    /**
        Instruct the parser to start the next parse from the beginning.
     
        If the parser previously failed because of a timeout or a cancellation, then
        by default, it will resume where it left off on the next call to
        `.parse()`. If you don't want to resume,
        and instead intend to use this parser to parse some other document, you must
        call this function first.
     */
    public func reset() {
        ts_parser_reset(parserPointer)
    }
    
    public enum ParserError: Error {
        case parseString
    }
    
    public static func == (lhs: STSParser, rhs: STSParser) -> Bool {
        return lhs.parserPointer == rhs.parserPointer
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(parserPointer)
    }
}
