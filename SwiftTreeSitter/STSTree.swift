//
//  STSTree.swift
//  SwiftTreeSitter
//
//  Created by Viktor Strate Kløvedal on 23/05/2020.
//  Copyright © 2020 viktorstrate. All rights reserved.
//

class STSTree {
    fileprivate let treePointer: OpaquePointer
    
    var language: STSLanguage {
        get {
            let languagePointer = ts_tree_language(treePointer)
            return STSLanguage(pointer: languagePointer)
        }
    }
    
    init(pointer: OpaquePointer) {
        self.treePointer = pointer
    }
    
    deinit {
        ts_tree_delete(treePointer)
    }
    
}
