//
//  STSPoint.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

#if _XCODE_BUILD_
import SwiftTreeSitter.CTreeSitter
#else
import CTreeSitter
#endif

public struct STSPoint: Equatable, Hashable {
    public let row: uint
    public let column: uint
    
    internal var tsPoint: TSPoint {
        get {
            TSPoint(row: row, column: column)
        }
    }
    
    public init(row: uint, column: uint) {
        self.row = row
        self.column = column
    }
    
    internal init(from tsPoint: TSPoint) {
        self.init(row: tsPoint.row, column: tsPoint.column)
    }
}
