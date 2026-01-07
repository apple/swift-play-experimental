//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

/// Declares a runnable playground block that can be discovered and executed by tools like "swift play".
///
/// The `#Playground` macro creates a discoverable code block that can be run independently
/// from the main program execution. Playgrounds are useful for exploration, experimentation,
/// and demonstration code that can be executed on-demand.
///
/// - Parameters:
///   - name: An optional string that provides a display name for the playground.
///           If `nil`, the playground will be unnamed but still discoverable.
///   - body: A closure containing the code to execute when the playground is run.
@freestanding(declaration)
public macro Playground(
  _ name: String? = nil,
  body: @escaping @Sendable () async throws -> Void
) = #externalMacro(module: "PlaygroundMacros", type: "Playground")
