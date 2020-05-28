//
//  STSQueryCapture.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public struct STSQueryCapture: Equatable {
    public let node: STSNode
    public let index: uint
}
