//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

///
/// A type representing playground content in the process.
///
struct PlaygroundContent: Sendable {
  var name: String?
  var fileID: String
  var line: Int
  var column: Int
  
  var body: @MainActor @Sendable () async throws -> Void
  
  init(
    displayName: String?,
    fileID: String,
    line: Int,
    column: Int,
    body: @escaping @MainActor @Sendable () async throws -> Void
  ) {
    self.name = displayName
    self.fileID = fileID
    self.line = line
    self.column = column
    self.body = body
  }
}

// MARK: - Identifiable

extension PlaygroundContent: Identifiable {
  typealias ID = __Playground.__ID

  var id: ID {
    ID(__name: name, __fileID: fileID, __line: line, __column: column)
  }
}

// MARK: - CustomStringConvertible

extension PlaygroundContent: CustomStringConvertible {
  var description: String {
    "<PlaygroundContent displayName=\"\(name ?? "(none)")\">"
  }
}
