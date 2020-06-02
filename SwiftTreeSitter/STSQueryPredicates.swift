//
//  STSQueryPredicate.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 02/06/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public struct STSQueryPredicates {
    public let name: String
    public let args: [STSQueryPredicateArg]
}

public enum STSQueryPredicateArg: Equatable, Hashable {
    case capture(uint)
    case string(String)
}
