# Swift Tree Sitter

This module provides Swift bindings for the [tree-sitter](https://tree-sitter.github.io) parsing library

## Installation

### Using Swift Package Manager

Add it as a dependency in the `Package.swift` file.

```swift
.package(url: "https://github.com/viktorstrate/swift-tree-sitter", from: "1.0.0")
```

Or from Xcode navigate to `File` -> `Swift Packages` -> `Add Package Dependency...`, then enter this url:

```
https://github.com/viktorstrate/swift-tree-sitter
```

### Import directly to Xcode

If you want to load languages from `.bundles` dynamically at runtime, you'll have to import it directly to Xcode as Mac bundles aren't supported using the Swift Package Manager.

To do this, download the project and drag the folder with the `SwiftTreeSitter.xcodeproj` file into the sidebar of your Xcode project.

## Usage

First you'll need to setup the Parser and specify what language to use.

```swift
let javascript = try STSLanguage(fromPreBundle: .javascript)
let parser = STSParser(language: javascript)
```

Then you can parse some source code.

```swift
let sourceCode = "let x = 1; console.log(x);";
let tree = parser.parse(string: sourceCode, oldTree: nil)!
print(tree.rootNode.sExpressionString!)

// (program
//   (lexical_declaration
//     (variable_declarator name: (identifier) value: (number)))
//   (expression_statement
//     (call_expression function:
//       (member_expression object: (identifier)
//         property: (property_identifier))
//         arguments: (arguments (identifier)))))
```

Inspect the syntax tree.

```swift
let callExpression = tree.rootNode.child(at: 1).firstChild(forOffset: 0)
print("type:\t\(callExpression.type)")
print("start point:\t\(callExpression.startPoint)")
print("end point:\t\(callExpression.endPoint)")
print("start byte:\t\(callExpression.startByte)")
print("end byte:\t\(callExpression.endByte)")

// type:        call_expression
// start point: STSPoint(row: 0, column: 11)
// end point:   STSPoint(row: 0, column: 25)
// start byte:  11
// end byte:    25
```

If your source code changes you can update the syntax tree.
This will take less time than to recompute the tree from scratch again.

```swift
// replace let with const
let newSourceCode = "const x = 1; console.log(x);";

tree.edit(
  STSInputEdit(
    startByte: 0,
    oldEndByte: 3,
    newEndByte: 5,
    startPoint: STSPoint(row: 0, column: 0),
    oldEndPoint: STSPoint(row: 0, column: 3),
    newEndPoint: STSPoint(row: 0, column: 5)
))

let newTree = parser.parse(string: newSourceCode, oldTree: tree)
```

### Parsing text from a custom data source

If your text is stored in a custom data source,
you can parse it by passing a callback to `.parse()` instead of a `String`.

```swift
let sourceLines = [
  "let x = 1;\n",
  "console.log(x);\n"
]

let tree = parser.parse(callback: { (byte, point) -> [Int8] in
  if (point.row >= sourceLines.count) {
    return []
  }

  let line = sourceLines[Int(point.row)]

  let index = line.index(line.startIndex, offsetBy: Int(point.column))
  let slice = line[index...]
  let array = Array(slice.utf8).map { Int8($0) }

  return array
}, oldTree: nil)
```
