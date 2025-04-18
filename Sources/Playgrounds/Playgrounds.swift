//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

@freestanding(declaration)
public macro Playground(
  _ name: String? = nil,
  body: @escaping @Sendable () async throws -> Void
) = #externalMacro(module: "PlaygroundMacros", type: "Playground")
