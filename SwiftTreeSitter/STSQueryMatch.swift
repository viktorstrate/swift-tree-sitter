//
//  STSQueryMatch.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 26/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

import SwiftTreeSitter.CTreeSitter

public struct STSQueryMatch {
    public let id: uint
    public let index: uint
    public let captures: [STSQueryCapture]
}
