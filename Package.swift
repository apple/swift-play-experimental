// swift-tools-version: 6.0

//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "swift-play-experimental",

  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .watchOS(.v6),
    .tvOS(.v13),
    .macCatalyst(.v13),
    .visionOS(.v1),
  ],

  products: [
    .library(
      name: "Playgrounds",
      targets: ["Playgrounds"]
    )
  ],

  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    .package(url: "https://github.com/swiftlang/swift-testing.git", branch: "main"),
  ],

  targets: [
    
    .target(
      name: "Playgrounds",
      dependencies: [
        "PlaygroundMacros",
        .product(name: "_TestDiscovery", package: "swift-testing"),
      ],
      swiftSettings: .packageSettings
    ),
    
    .testTarget(
      name: "PlaygroundsTests",
      dependencies: [
        "Playgrounds",
      ],
      swiftSettings: .packageSettings
    ),
    
    .macro(
      name: "PlaygroundMacros",
      dependencies: [
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ],
      swiftSettings: .packageSettings
    ),
  ]
)

// BUG: swift-package-manager-#6367
#if !os(Windows) && !os(FreeBSD) && !os(OpenBSD)
package.targets.append(contentsOf: [
  .testTarget(
    name: "PlaygroundMacrosTests",
    dependencies: [
      "Playgrounds",
      "PlaygroundMacros",
      .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
    ],
    swiftSettings: .packageSettings
  )
])
#endif

extension Array where Element == PackageDescription.SwiftSetting {
  /// Settings intended to be applied to every Swift target in this package.
  /// Analogous to project-level build settings in an Xcode project.
  static var packageSettings: Self {
    [
      // When building as a package, the macro plugin always builds as an
      // executable rather than a library.
      .define("SWP_NO_LIBRARY_MACRO_PLUGINS"),
    ]
  }
}
