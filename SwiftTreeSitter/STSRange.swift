//
//  STSRange.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 30/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public struct STSRange: Equatable, Hashable {
    public let startPoint: STSPoint
    public let endPoint: STSPoint
    public let startByte: uint
    public let endByte: uint
    
    public init(startPoint: STSPoint, endPoint: STSPoint, startByte: uint, endByte: uint) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.startByte = startByte
        self.endByte = endByte
    }
    
    public init(from node: STSNode) {
        self.init(startPoint: node.startPoint, endPoint: node.endPoint, startByte: node.startByte, endByte: node.endByte)
    }
    
    internal init(tsRange: TSRange) {
        let sPoint = STSPoint(from: tsRange.start_point)
        let ePoint = STSPoint(from: tsRange.end_point)
        
        self.init(startPoint: sPoint, endPoint: ePoint, startByte: tsRange.start_byte, endByte: tsRange.end_byte)
    }
    
}
