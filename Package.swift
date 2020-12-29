// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "SwiftTreeSitter",
  products: [
    .library(name: "SwiftTreeSitter", targets: ["SwiftTreeSitter"]),
  ],
  targets: [
    .target(name: "SwiftTreeSitter", dependencies: ["CTreeSitter", "TreeSitterLanguages"]),
    .target(
      name: "TreeSitterLanguages",
      dependencies: ["CTreeSitter"],
      cSettings: [
        .headerSearchPath("private")
      ]
    ),
    .target(
      name: "CTreeSitter",
      path: "tree-sitter/lib",
      sources: ["src/lib.c"],
      cSettings: [
        .headerSearchPath("src")
      ]
    ),
    .testTarget(
      name: "SwiftTreeSitterTests",
      dependencies: ["SwiftTreeSitter", "TreeSitterLanguages"]
    ),
  ]
)
