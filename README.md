# swift-tree-sitter

This module provides Swift bindings for the [tree-sitter](https://tree-sitter.github.io) parsing library

## Building a language bundle

- Build the language with `npm install && npm build`
- Compile static library `xcrun clang -c src/parser.c -I./src`