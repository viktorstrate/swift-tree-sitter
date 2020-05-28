//
//  STSInputEdit.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public struct STSInputEdit: Equatable, Hashable {
    public let startByte: uint
    public let oldEndByte: uint
    public let newEndByte: uint
    public let startPoint: STSPoint
    public let oldEndPoint: STSPoint
    public let newEndPoint: STSPoint
    
    public init(startByte: uint, oldEndByte: uint, newEndByte: uint, startPoint: STSPoint, oldEndPoint: STSPoint, newEndPoint: STSPoint) {
        self.startByte = startByte
        self.oldEndByte = oldEndByte
        self.newEndByte = newEndByte
        self.startPoint = startPoint
        self.oldEndPoint = oldEndPoint
        self.newEndPoint = newEndPoint
    }
    
    internal func tsInputEdit() -> TSInputEdit {
        return TSInputEdit(
            start_byte: startByte,
            old_end_byte: oldEndByte,
            new_end_byte: newEndByte,
            start_point: startPoint.tsPoint,
            old_end_point: oldEndPoint.tsPoint,
            new_end_point: newEndPoint.tsPoint)
    }
}
