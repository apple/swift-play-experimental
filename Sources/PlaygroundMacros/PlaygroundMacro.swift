//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

public import SwiftSyntax
public import SwiftSyntaxMacros

struct PlaygroundDiagnostic: Error, CustomStringConvertible {
  var description: String
}

public enum Playground: DeclarationMacro, Sendable {
  /// DeclarationMacro entry point
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    guard let location = node.location(in: context) else {
      print("\(self) macro \"\(node.arguments.first?.trimmedDescription ?? "<unnamed>")\": Unable to determine macro source location")
      return []
    }

    // Determine the playground's name
    let name: any ExprSyntaxProtocol
    if let nameArg = node.arguments.first,
       let stringLiteral = nameArg.trimmed.expression.as(StringLiteralExprSyntax.self)
    {
      // The name of the playground was supplied as the argument to the macro
      name = stringLiteral
    }
    else {
      // Set the name to nil
      name = NilLiteralExprSyntax()
    }

    guard context.lexicalContext.isEmpty else {
      throw PlaygroundDiagnostic(description: "\(self) macro \(name): Must be at file scope")
    }

    let conditionStart: DeclSyntax = """
      #if PLAYGROUND_MACRO_EXPANSION_ENABLED
      """

    let conditionEnd: DeclSyntax = """
      #endif // PLAYGROUND_MACRO_EXPANSION_ENABLED
      """

    // Define a function that will run the playground body
    let playgroundRunFuncName = context.makeUniqueName("PlaygroundRunFunc")
    let playgroundRunFuncDeclSyntax: DeclSyntax =
      """
      @MainActor @Sendable private static func \(playgroundRunFuncName)(_ name: String? = nil, body: @MainActor @Sendable () async throws -> ()) async throws {
      try await body()
      }
      """

    // Define a function that will call the run function with arguments and any trailing closure preserved as written
    let playgroundEntryCallExpression = node.playgroundCallExpression(forFuncName: "\(playgroundRunFuncName)")
    let playgroundEntryName = context.makeUniqueName("PlaygroundEntry")
    // Important: the body of this playground entry func must _not_ be indented. Otherwise column ranges of live results will be incorrect.
    let playgroundEntryDecl: DeclSyntax =
      """
      private struct \(markerTokenSyntax) { 
        let utf8offset: Int
        @discardableResult init(utf8offset: Int) {
          self.utf8offset = utf8offset
        } 
      }
      @MainActor @Sendable fileprivate static func \(playgroundEntryName)() async throws {
      try await \(playgroundEntryCallExpression)
      }
      """

    let playgroundEntryContainerName = context.makeUniqueName("PlaygroundEntryContainer")
    // Important: the body of this playground entry container enum must _not_ be indented. Otherwise column ranges of live results will be incorrect.
    let playgroundEntryContainerDecl: DeclSyntax =
      """
      @available(*, deprecated, message: "This type is an implementation detail of the Playgrounds library. Do not use it directly.")
      fileprivate enum \(playgroundEntryContainerName) {
      \(playgroundRunFuncDeclSyntax)
      \(playgroundEntryDecl)
      }
      """

    // The playground content record to be be looked up at runtime
    let playgroundContentRecordName = context.makeUniqueName("PlaygroundContentRecord")
    let playgroundContentRecordDecl: DeclSyntax =
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
      @available(*, deprecated, message: "This property is an implementation detail of the playgrounds library. Do not use it directly.")
      nonisolated private let \(playgroundContentRecordName): Playgrounds.__PlaygroundsContentRecord = (
        0x706c6179, /* 'play' */
        0,
        { outValue, type, hint, _ in
          Playgrounds.__store(
            \(name),
            \(playgroundEntryContainerName).\(playgroundEntryName),
            line: \(location.line),
            column: \(location.column),
            at: outValue,
            asTypeAt: type,
            withHintAt: hint
          )
        },
        0,
        0
      )
      """

    // The playground content record container to be looked up at runtime
    let playgroundContentRecordContainerName = context.makeUniqueName("__🟡$PlaygroundContentRecordContainer")
    let playgroundContentRecordContainerDecl: DeclSyntax =
      """
      @available(*, deprecated, message: "This type is an implementation detail of the playgrounds library. Do not use it directly.")
      enum \(playgroundContentRecordContainerName): Playgrounds.__PlaygroundsContentRecordContainer {
        nonisolated static var __playgroundsContentRecord: Playgrounds.__PlaygroundsContentRecord {
          \(playgroundContentRecordName)
        }
      }
      """

    return ["""
      \(conditionStart)
      \(playgroundEntryContainerDecl)
      \(playgroundContentRecordDecl)
      \(playgroundContentRecordContainerDecl)
      \(conditionEnd)
      """]
  }
  
  public static var formatMode: FormatMode {
    .disabled
  }
  
  fileprivate static let markerTokenSyntax = TokenSyntax(stringLiteral: "$__Marker")
  
  fileprivate enum BodyClosure {
    case trailingClosure(ClosureExprSyntax)
    case lastArgument(LabeledExprListSyntax.Element, ClosureExprSyntax)
    
    var closureSyntax: ClosureExprSyntax {
      switch self {
      case .trailingClosure(let trailingClosure): trailingClosure
      case .lastArgument(_, let lastArgumentClosure): lastArgumentClosure
      }
    }
  }
}

extension FreestandingMacroExpansionSyntax {
  // Creates a call expression from the macro, exactly preserving
  // arguments, trailing closures, etc, replacing the macro name with
  // the type to be instantiated.
  fileprivate func playgroundCallExpression(forFuncName funcNameExpr: ExprSyntax) -> FunctionCallExprSyntax {
    var callExpression = FunctionCallExprSyntax(
      calledExpression: funcNameExpr,
      leftParen: leftParen,
      arguments: arguments,
      rightParen: rightParen?.trimmed,
      trailingClosure: trailingClosure?.with(\.leadingTrivia, .space),
      additionalTrailingClosures: additionalTrailingClosures,
      trailingTrivia: trailingTrivia
    )
    
    // Injects a marker call at the beginning of the closure body, so
    // that clients can calculate correct character offsets for logged
    // playground expression results.
    if let playgroundBodyClosure {
      var replacementClosure = playgroundBodyClosure.closureSyntax
      replacementClosure.injectMarkerCall(withMacroOffset: positionAfterSkippingLeadingTrivia.utf8Offset)
      switch playgroundBodyClosure {
      case .trailingClosure(_):
        replacementClosure.leftBrace.leadingTrivia = .space
        callExpression.trailingClosure = replacementClosure
      case .lastArgument(var lastArgument, _):
        lastArgument.expression = ExprSyntax(replacementClosure)
        callExpression.arguments = callExpression.arguments.dropLast() + [lastArgument]
      }
    }
    
    return callExpression
  }
  
  /// Returns a closure for the playground body if there is one, from either the
  /// trailing closure or the last argument.
  private var playgroundBodyClosure: Playground.BodyClosure? {
    if let trailingClosure {
      return .trailingClosure(trailingClosure)
    } else if let lastArgument = arguments.last, let closure = lastArgument.expression.as(ClosureExprSyntax.self) {
      return .lastArgument(lastArgument, closure)
    }
    return nil
  }
}

private extension ClosureExprSyntax {
  mutating func injectMarkerCall(withMacroOffset macroOffset: Int) {
    // Only inject a marker call if the passed block contains statements.
    guard var firstStatement = statements.first else { return }
    
    // The marker call has a single parameter: the UTF-8 offset from the
    // macro start position. This allows us to calculate the expected
    // location of the first statement in the original code containing
    // the macro.
    let firstStatementOffset = firstStatement.positionAfterSkippingLeadingTrivia.utf8Offset
    let markerOffset = firstStatementOffset - macroOffset
    var markerStatement = CodeBlockItemSyntax(
      stringLiteral: "\(Playground.markerTokenSyntax)(utf8offset: \(markerOffset));"
    )
    
    // Make sure that the marker call ends up in the original location of
    // the first statement.
    let firstStatementLeadingTrivia = firstStatement.leadingTrivia
    markerStatement.leadingTrivia = firstStatementLeadingTrivia
    
    // The leading trivia of the first statement is cleared to make sure
    // the only character between the marker call and the first statement
    // is the inserted semicolon.
    firstStatement.leadingTrivia = []
    
    // Update the first statement with the new trivia and insert the
    // marker call.
    statements = [firstStatement] + statements.dropFirst()
    statements.insert(markerStatement, at: statements.startIndex)
  }
}

extension FreestandingMacroExpansionSyntax {
  fileprivate func location(in context: any MacroExpansionContext ) -> AbstractSourceLocation? {
    context.location(of: pound, at: .afterLeadingTrivia, filePathMode: .fileID)
  }
}
