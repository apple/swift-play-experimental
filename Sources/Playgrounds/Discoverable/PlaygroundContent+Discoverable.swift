//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

@_spi(ForToolsIntegrationOnly) private import _TestDiscovery

/// Playgrounds uses the same runtime content discovery mechanism
/// that Swift Testing uses.
extension PlaygroundContent: DiscoverableAsTestContent {
  fileprivate static var testContentKind: TestContentKind {
    "play"
  }

  /// Use the hint type to avoid running code for _every_ playground in a binary
  /// in order to find the one that you care about.
  fileprivate typealias TestContentAccessorHint = Hint

  /// This property acts as a hint to ``DiscoverableAsTestContent`` so that it
  /// can skip over types whose names don't match the pattern used in the macro.
  fileprivate static var _testContentTypeNameHint: String {
    "__🟡$PlaygroundContentRecordContainer"
  }
}

extension PlaygroundContent {
  private static func allTypeMetadataBasedTestContentRecords() -> some Sequence<TestContentRecord<Self>> {
    allTypeMetadataBasedTestContentRecords { type, outRecord in
      guard let type = type as? any __PlaygroundsContentRecordContainer.Type else {
        return false
      }
      outRecord.withMemoryRebound(to: __PlaygroundsContentRecord.self) { outRecord in
        outRecord.baseAddress!.initialize(to: type.__playgroundsContentRecord)
      }
      return true
    }
  }

  /// All available playground instances in the process, according to the runtime.
  ///
  /// The order of values in this sequence is unspecified.
  static var all: some Sequence<Self> {
    var result = [Self]()

    result = PlaygroundContent.allTestContentRecords().compactMap {
      $0.load()
    }

    if result.isEmpty {
      // Fall back to type-based discovery.
      result = PlaygroundContent.allTypeMetadataBasedTestContentRecords().compactMap {
        $0.load()
      }
    }

    return Set(result)
  }

  /// The hint for finding a playground is its name or ID.
  enum Hint {
    case name(String)
    case id(ID)
  }

  /// Find the first playground in the current process with the given hint (name
  /// or ID.)
  static func find(withHint hint: Hint) -> Self? {
    var result = PlaygroundContent.allTestContentRecords().lazy
      .compactMap { $0.load(withHint: hint) }
      .first

    if result == nil {
      // Fall back to type-based discovery.
      result = PlaygroundContent.allTypeMetadataBasedTestContentRecords().lazy
        .compactMap { $0.load(withHint: hint) }
        .first
    }

    return result
  }
}

// MARK: - Content Records -

/// The type of the accessor function used to access a playground content record.
///
/// - Parameters:
///   - outValue: A pointer to uninitialized memory large enough to contain the
///     corresponding playground content record's value.
///   - type: A pointer to the expected type of `outValue`. Use `load(as:)` to
///     get the Swift type, not `unsafeBitCast(_:to:)`.
///   - hint: An optional pointer to a hint value.
///   - reserved: Reserved for future use.
///
/// - Returns: Whether or not `outValue` was initialized. The caller is
///   responsible for deinitializing `outValue` if it was initialized.
///
/// - Warning: This type is used to implement the `#Playground` macro. Do not use it
///   directly.
public typealias __PlaygroundsContentRecordAccessor = @convention(c) (
  _ outValue: UnsafeMutableRawPointer,
  _ type: UnsafeRawPointer,
  _ hint: UnsafeRawPointer?,
  _ reserved: UnsafeRawPointer?
) -> CBool

/// The content of a playground content record.
///
/// - Parameters:
///   - kind: The kind of this record.
///   - reserved1: Reserved for future use.
///   - accessor: A function which, when called, produces the playground content.
///   - context: Kind-specific context for this record.
///   - reserved2: Reserved for future use.
///
/// - Warning: This type is used to implement the `#Playground` macro. Do not use it
///   directly.
public typealias __PlaygroundsContentRecord = (
  kind: UInt32,
  reserved1: UInt32,
  accessor: __PlaygroundsContentRecordAccessor?,
  context: UInt,
  reserved2: UInt
)

/// Store a playground into the given memory.
///
/// - Parameters:
///   - name: The name of the playground.
///   - fileID: The file identifier containing the playground.
///   - line: The line number of the playground.
///   - column: The line column number of the playground.
///   - outValue: The uninitialized memory to store the playground into.
///   - typeAddress: A pointer to the expected type of the playground as passed
///     to the playground content record calling this function.
///   - body: The body closure of the playground to store.
///
/// - Returns: Whether or not a playground was stored into `outValue`.
///
/// - Warning: This function is used to implement the `#Playground` macro. Do not use it
///   directly.
@_weakLinked
public func __store(
  _ name: String?,
  _ body: @escaping @Sendable @MainActor () async throws -> Void,
  _ fileID: String = #fileID,
  line: Int,
  column: Int,
  at outValue: UnsafeMutableRawPointer,
  asTypeAt typeAddress: UnsafeRawPointer,
  withHintAt hintAddress: UnsafeRawPointer?
) -> CBool {
  guard typeAddress.load(as: Any.Type.self) == PlaygroundContent.self else {
    return false
  }

  if let hint = hintAddress?.load(as: PlaygroundContent.Hint.self) {
    switch hint {
    case let .name(hintedName):
      if name != hintedName {
        // The caller provided a name as a hint but it didn't match, so exit early.
        return false
      }
    case let .id(hintedID):
      let id = PlaygroundContent.ID(__name: name, __fileID: fileID, __line: line, __column: column)
      if id != hintedID {
        // The caller provided an ID as a hint but it didn't match, so exit early.
        return false
      }
    }
  }

  outValue.initializeMemory(
    as: PlaygroundContent.self,
    to: PlaygroundContent(
      displayName: name,
      fileID: fileID,
      line: line,
      column: column,
      body: body
    )
  )
  return true
}

// MARK: - Content Records (Type-Based Discovery) -

/// A protocol describing a type that contains a playground.
///
/// - Warning: This protocol is used to implement the `#Playground` macro. Do
///   not use it it directly.
@_weakLinked
@_alwaysEmitConformanceMetadata
public protocol __PlaygroundsContentRecordContainer {
  /// The playgrounds content record associated with this container.
  ///
  /// - Warning: This property is used to implement the `#Playground` macro. Do
  ///   not use it it directly.
  nonisolated static var __playgroundsContentRecord: __PlaygroundsContentRecord { get }
}
