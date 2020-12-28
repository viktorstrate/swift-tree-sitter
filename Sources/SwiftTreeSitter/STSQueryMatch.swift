//
//  STSQueryMatch.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import CTreeSitter

public struct STSQueryMatch: Equatable, Hashable {
    public let id: uint
    public let index: uint
    public let captures: [STSQueryCapture]
    
    public static func == (lhs: STSQueryMatch, rhs: STSQueryMatch) -> Bool {
        return lhs.id == rhs.id
    }
}
