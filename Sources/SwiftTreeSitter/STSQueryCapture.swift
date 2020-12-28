//
//  STSQueryCapture.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import CTreeSitter

public struct STSQueryCapture: Equatable, Hashable {
    public let node: STSNode
    public let index: uint
    
    internal let query: STSQuery
    
    internal init(query: STSQuery, node: STSNode, index: uint) {
        self.query = query
        self.node = node
        self.index = index
    }
    
    public var name: String {
        get {
            query.captureName(forId: self.index)
        }
    }
    
}
