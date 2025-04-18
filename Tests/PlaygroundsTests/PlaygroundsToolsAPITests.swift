//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

import Playgrounds
import Testing

// MARK: - Testable Playground Metadata -

@MainActor class TestablePlaygroundMetadata {
  internal init(name: String? = nil, playgroundLineNumber: Int, playgroundColumnNumber: Int = 1, playgroundFile: String = #file) {
    self.name = name
    self.playgroundLineNumber = playgroundLineNumber
    self.playgroundColumnNumber = playgroundColumnNumber
    self.playgroundFile = playgroundFile
  }
  
  let name: String?
  var wasExecuted: Bool = false
  let playgroundLineNumber: Int
  let playgroundFile: String
  let playgroundColumnNumber: Int
  
  var displayName: String {
    name ?? "\(playgroundFile):\(playgroundLineNumber):\(playgroundColumnNumber)"
  }
}


// MARK: - Playgrounds to Test -

/// Named playground with trailing closure
@MainActor fileprivate var namedPlaygroundWithTrailingClosure = TestablePlaygroundMetadata(name: "Named Playground with trailing closure", playgroundLineNumber: #line + 1)
#Playground("Named Playground with trailing closure") {
  let metadata = namedPlaygroundWithTrailingClosure
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName): random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName) was executed: \(metadata.wasExecuted)")
}

/// Unnamed playground with trailing closure
@MainActor fileprivate var unnamedPlaygroundWithTrailingClosure = TestablePlaygroundMetadata(playgroundLineNumber: #line + 1)
#Playground {
  let metadata = unnamedPlaygroundWithTrailingClosure
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName): random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName) was executed: \(metadata.wasExecuted)")
}

/// Named Playground with trailing closure containing in arg
@MainActor fileprivate var namedPlaygroundWithTrailingClosureContainingInArg = TestablePlaygroundMetadata(name: "Named Playground with trailing closure containing in arg", playgroundLineNumber: #line + 1)
#Playground("Named Playground with trailing closure containing in arg") { () -> Void in
  let metadata = namedPlaygroundWithTrailingClosureContainingInArg
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName) random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName) was executed: \(metadata.wasExecuted)")
}

/// Unnamed Playground with trailing closure containing in arg
@MainActor fileprivate var unnamedPlaygroundWithTrailingClosureContainingInArg = TestablePlaygroundMetadata(playgroundLineNumber: #line + 1)
#Playground { () -> Void in
  let metadata = unnamedPlaygroundWithTrailingClosureContainingInArg
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName) random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName) was executed: \(metadata.wasExecuted)")
}

/// Named playground with closure as body argument
@MainActor fileprivate var namedPlaygroundWithClosureAsBodyArgument = TestablePlaygroundMetadata(name: "Named playground with closure as body argument", playgroundLineNumber: #line + 1)
#Playground("Named playground with closure as body argument", body: {
  let metadata = namedPlaygroundWithClosureAsBodyArgument
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName): random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName): was executed: \(metadata.wasExecuted)")
})

/// Unnamed playground with closure as body argument
@MainActor fileprivate var unnamedPlaygroundWithClosureAsBodyArgument = TestablePlaygroundMetadata(playgroundLineNumber: #line + 1)
#Playground(body: {
  let metadata = unnamedPlaygroundWithClosureAsBodyArgument
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName): random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName): was executed: \(metadata.wasExecuted)")
})

/// Named playground with function reference as body argument
@MainActor fileprivate var namedPlaygroundWithFunctionReferenceAsBodyArgument = TestablePlaygroundMetadata(name: "Named playground with function reference as body argument", playgroundLineNumber: #line + 8)
@MainActor fileprivate func namedPlaygroundWithFunctionReferenceAsBodyArgumentBody() {
  let metadata = namedPlaygroundWithFunctionReferenceAsBodyArgument
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName): random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName): was executed: \(metadata.wasExecuted)")
}
#Playground("Named playground with function reference as body argument", body: namedPlaygroundWithFunctionReferenceAsBodyArgumentBody)

/// Unnamed playground with function reference as body argument
@MainActor fileprivate var unnamedPlaygroundWithFunctionReferenceAsBodyArgument = TestablePlaygroundMetadata(playgroundLineNumber: #line + 8)
@MainActor fileprivate func unnamedPlaygroundWithFunctionReferenceAsBodyArgumentBody() {
  let metadata = unnamedPlaygroundWithFunctionReferenceAsBodyArgument
  let random = Int.random(in: 1...100)
  print("\(metadata.displayName): random = \(random)")
  metadata.wasExecuted = true
  print("\(metadata.displayName): was executed: \(metadata.wasExecuted)")
}
#Playground(body: unnamedPlaygroundWithFunctionReferenceAsBodyArgumentBody)


// MARK: - All Testable Playground Metadata -

@MainActor fileprivate var allTestablePlaygroundMetadata: [TestablePlaygroundMetadata] = [
  namedPlaygroundWithTrailingClosure,
  unnamedPlaygroundWithTrailingClosure,
  namedPlaygroundWithTrailingClosureContainingInArg,
  unnamedPlaygroundWithTrailingClosureContainingInArg,
  namedPlaygroundWithClosureAsBodyArgument,
  unnamedPlaygroundWithClosureAsBodyArgument,
  namedPlaygroundWithFunctionReferenceAsBodyArgument,
  unnamedPlaygroundWithFunctionReferenceAsBodyArgument,
]


// MARK: - Tests -

@Suite("Playgrounds Tools API Tests", .serialized)
struct PlaygroundsToolsAPITests {
  
  @Test("Playground definition variations", arguments: await allTestablePlaygroundMetadata)
  func testPlaygroundDefinitionVariations(metadata: TestablePlaygroundMetadata) async throws {
    let playground: __Playground
    
    if let playgroundName = metadata.name {
      playground = try #require(__Playground.__getPlayground(named: playgroundName))
    }
    else {
      let identifier = __Playground.__ID(__fileID: metadata.playgroundFile, __line: metadata.playgroundLineNumber, __column: metadata.playgroundColumnNumber)
      playground = try #require(__Playground.__getPlayground(identifiedBy: identifier))
    }

    print("[\(#function)] Running Playground \"\(playground.__displayName)\"")
    try await playground.__run()

    print("[\(#function)] Checking wasExecuted value: \(await metadata.wasExecuted)")
    #expect(await metadata.wasExecuted == true)
    
    #expect(playground.__id.__line == metadata.playgroundLineNumber)
  }

  @Test("Find Playground by ID")
  func testFindPlaygroundByID() async throws {
    let playground1 = try #require(__Playground.__allPlaygrounds().first)
    let playground2 = try #require(__Playground.__getPlayground(identifiedBy: playground1.__id))
    #expect(playground1.__id == playground2.__id)
  }
  
  @MainActor
  @Test("Fetch all Playgrounds")
  func testFetchAllPlaygrounds() async throws {
    let playgrounds = __Playground.__allPlaygrounds()
    print("Found \(playgrounds.count) Playground records: \(playgrounds)")

    #expect(playgrounds.count == allTestablePlaygroundMetadata.count)

    let expectedNames = allTestablePlaygroundMetadata.map { $0.displayName }.sorted()
    let names = playgrounds.map { $0.__displayName }.sorted()
    #expect(names == expectedNames)

    let expectedFileIDs = allTestablePlaygroundMetadata.map { $0.playgroundFile }.sorted()
    let fileIDs = playgrounds.map(\.__id.__fileID).sorted()
    #expect(fileIDs == expectedFileIDs)

    let expectedLineNumbers = allTestablePlaygroundMetadata.map { $0.playgroundLineNumber }.sorted()
    let lineNumbers = playgrounds.map(\.__id.__line).sorted()
    #expect(lineNumbers == expectedLineNumbers)

    let expectedColumnNumbers = allTestablePlaygroundMetadata.map { $0.playgroundColumnNumber }.sorted()
    let columnNumbers = playgrounds.map(\.__id.__column).sorted()
    #expect(columnNumbers == expectedColumnNumbers)
  }

}
