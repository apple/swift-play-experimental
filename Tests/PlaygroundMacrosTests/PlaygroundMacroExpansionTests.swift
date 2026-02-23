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

#if canImport(SwiftSyntaxMacrosGenericTestSupport)
import SwiftSyntaxMacrosGenericTestSupport
fileprivate let macroExpansionTestSupported = true
#else
fileprivate let macroExpansionTestSupported = false
#endif

@Suite("Playground Macro Expansion Tests")
struct PlaygroundMacroExpansionTests {

  private var sectionExpansion: String {
#if compiler(>=6.3)
      """
      #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS) || os(visionOS)
      @section("__DATA_CONST,__swift5_tests")
      #elseif os(Linux) || os(FreeBSD) || os(OpenBSD) || os(Android) || os(WASI)
      @section("swift5_tests")
      #elseif os(Windows)
      @section(".sw5test$B")
      #endif
      @used
      """
#else
      """
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
      """
#endif
  }

  @Test("Named Playground with trailing closure expansion",
        .enabled(if: macroExpansionTestSupported))
  func namedPlaygroundWithTrailingClosureExpansionTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
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
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_("Named Playground with trailing closure") {
          $__Marker(utf8offset: 60);let metadata = namedPlaygroundWithTrailingClosure
          let random = Int.random(in: 1...100)
          print("\\(metadata.displayName): random = \\(random)")
          metadata.wasExecuted = true
          print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named Playground with trailing closure",
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Unnamed playground with trailing closure",
        .enabled(if: macroExpansionTestSupported))
  func unnamedPlaygroundWithTrailingClosureTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
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
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_ {
        $__Marker(utf8offset: 16);let metadata = unnamedPlaygroundWithTrailingClosure
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Named Playground with trailing closure containing `in` arg",
        .enabled(if: macroExpansionTestSupported))
  func namedPlaygroundWithTrailingClosureContainingInArgTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
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
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_("Named Playground with trailing closure containing in arg") { () -> Void in
        $__Marker(utf8offset: 90);let metadata = namedPlaygroundWithTrailingClosureContainingInArg
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName) random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named Playground with trailing closure containing in arg",
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Unnamed Playground with trailing closure containing `in` arg",
        .enabled(if: macroExpansionTestSupported))
  func unnamedPlaygroundWithTrailingClosureContainingInArgTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
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
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_ { () -> Void in
        $__Marker(utf8offset: 30);let metadata = unnamedPlaygroundWithTrailingClosureContainingInArg
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName) random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName) was executed: \\(metadata.wasExecuted)")
      }
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Named playground with closure as body argument",
        .enabled(if: macroExpansionTestSupported))
  func namedPlaygroundWithClosureAsBodyArgumentTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
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
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_("Named playground with closure as body argument", body: {
        $__Marker(utf8offset: 72);let metadata = namedPlaygroundWithClosureAsBodyArgument
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName): was executed: \\(metadata.wasExecuted)")
      })
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named playground with closure as body argument",
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Unnamed playground with closure as body argument",
        .enabled(if: macroExpansionTestSupported))
  func unnamedPlaygroundWithClosureAsBodyArgumentTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
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
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_(body: {
        $__Marker(utf8offset: 22);let metadata = unnamedPlaygroundWithClosureAsBodyArgument
        let random = Int.random(in: 1...100)
        print("\\(metadata.displayName): random = \\(random)")
        metadata.wasExecuted = true
        print("\\(metadata.displayName): was executed: \\(metadata.wasExecuted)")
      })
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Named playground with function reference as body argument",
        .enabled(if: macroExpansionTestSupported))
  func namedPlaygroundWithFunctionReferenceAsBodyArgumentTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
    assertMacroExpansion(
      """
      #Playground("Named playground with function reference as body argument", body: namedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      """,
      expandedSource:
      """
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_("Named playground with function reference as body argument", body: namedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            "Named playground with function reference as body argument",
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }

  @Test("Unnamed playground with function reference as body argument",
        .enabled(if: macroExpansionTestSupported))
  func unnamedPlaygroundWithFunctionReferenceAsBodyArgumentTest() throws {
#if canImport(SwiftSyntaxMacrosGenericTestSupport)
    assertMacroExpansion(
      """
      #Playground(body: unnamedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      """,
      expandedSource:
      """
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum __macro_local_24PlaygroundEntryContainerfMu_ {
      @MainActor @Sendable private static func __macro_local_17PlaygroundRunFuncfMu_(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      
      private struct $__Marker { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func __macro_local_15PlaygroundEntryfMu_() async throws {
      try await __macro_local_17PlaygroundRunFuncfMu_(body: unnamedPlaygroundWithFunctionReferenceAsBodyArgumentBody)
      }
      
      }
      \(sectionExpansion)
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let __macro_local_23PlaygroundContentRecordfMu_: Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            nil,
            __macro_local_24PlaygroundEntryContainerfMu_.__macro_local_15PlaygroundEntryfMu_,
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
#endif
  }
}
