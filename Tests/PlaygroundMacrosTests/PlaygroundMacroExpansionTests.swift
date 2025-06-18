//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

import Testing
@testable import PlaygroundMacros

import SwiftDiagnostics
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport

@Suite("Playground Macro Expansion Tests")
struct PlaygroundMacroExpansionTests {

  @Test("Named Playground with trailing closure expansion")
  func namedPlaygroundWithTrailingClosureExpansionTest() throws {
    assertMacroExpansion(
      """
      #Playground("Named Playground with trailing closure") {
          let metadata = namedPlaygroundWithTrailingClosure
          let random = Int.random(in: 1...100)
          print("\\(metadata.displayName): random = \\(random)")
          metadata.wasExecuted = true
          print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_("Named Playground with trailing closure") {
          $__Marker(utf8offset: 60);let metadata = namedPlaygroundWithTrailingClosure
          let random = Int.random(in: 1...100)
          print("\\(metadata.displayName): random = \\(random)")
          metadata.wasExecuted = true
          print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named Playground with trailing closure",
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Unnamed playground with trailing closure")
  func unnamedPlaygroundWithTrailingClosureTest() throws {
    assertMacroExpansion(
      """
      #Playground {
        let metadata = unnamedPlaygroundWithTrailingClosure
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_ {
        $__Marker(utf8offset: 16);let metadata = unnamedPlaygroundWithTrailingClosure
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Named Playground with trailing closure containing `in` arg")
  func namedPlaygroundWithTrailingClosureContainingInArgTest() throws {
    assertMacroExpansion(
      """
      #Playground("Named Playground with trailing closure containing in arg") { () -> Void in
        let metadata = namedPlaygroundWithTrailingClosureContainingInArg
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName) random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_("Named Playground with trailing closure containing in arg") { () -> Void in
        $__Marker(utf8offset: 90);let metadata = namedPlaygroundWithTrailingClosureContainingInArg
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName) random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named Playground with trailing closure containing in arg",
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Unnamed Playground with trailing closure containing `in` arg")
  func unnamedPlaygroundWithTrailingClosureContainingInArgTest() throws {
    assertMacroExpansion(
      """
      #Playground { () -> Void in
        let metadata = unnamedPlaygroundWithTrailingClosureContainingInArg
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName) random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_ { () -> Void in
        $__Marker(utf8offset: 30);let metadata = unnamedPlaygroundWithTrailingClosureContainingInArg
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName) random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Named playground with closure as body argument")
  func namedPlaygroundWithClosureAsBodyArgumentTest() throws {
    assertMacroExpansion(
      """
      #Playground("Named playground with closure as body argument", body: {
        let metadata = namedPlaygroundWithClosureAsBodyArgument
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName): was executed: \\(metadata.wasExecuted)")
      })
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_("Named playground with closure as body argument", body: {
        $__Marker(utf8offset: 72);let metadata = namedPlaygroundWithClosureAsBodyArgument
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName): was executed: \\(metadata.wasExecuted)")
      })
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named playground with closure as body argument",
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Unnamed playground with closure as body argument")
  func unnamedPlaygroundWithClosureAsBodyArgumentTest() throws {
    assertMacroExpansion(
      """
      #Playground(body: {
        let metadata = unnamedPlaygroundWithClosureAsBodyArgument
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName): was executed: \\(metadata.wasExecuted)")
      })
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_(body: {
        $__Marker(utf8offset: 22);let metadata = unnamedPlaygroundWithClosureAsBodyArgument
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName): was executed: \\(metadata.wasExecuted)")
      })
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Named playground with function reference as body argument")
  func namedPlaygroundWithFunctionReferenceAsBodyArgumentTest() throws {
    assertMacroExpansion(
      """
      #Playground("Named playground with function reference as body argument", body: namedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_("Named playground with function reference as body argument", body: namedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named playground with function reference as body argument",
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }

  @Test("Unnamed playground with function reference as body argument")
  func unnamedPlaygroundWithFunctionReferenceAsBodyArgumentTest() throws {
    assertMacroExpansion(
      """
      #Playground(body: unnamedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      """,
      expandedSource:
      """
      @MainActor @Sendable private func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      @MainActor @Sendable private func __macro_local_15PlaygroundEntryfMu_() async throws {
      struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      try await __macro_local_17PlaygroundRunFuncfMu_(body: unnamedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      }
      #if hasFeature(SymbolLinkageMarkers)
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @_section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @_section("swift5_tests")
      #elseif os(Windows)
      @_section(".sw5test$B")
      #endif
      @_used
      #endif
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_15PlaygroundEntryfMu_,
            line: 1,
            column: 1,
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum __macro_local_36__🟡$PlaygroundContentRecordContainerfMu_: Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          __macro_local_23PlaygroundContentRecordfMu_
        }
      }
      """,
      macroSpecs: ["Playground" : MacroSpec(type: Playground.self, conformances: [])]
    )
    { failure in
      Issue.record(Comment(rawValue: failure.message))
    }
  }
}
