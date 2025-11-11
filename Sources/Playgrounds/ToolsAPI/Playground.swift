//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

#if !os(Windows)
@_weakLinked
#endif
public struct __Playground: Sendable {
  // MARK: - For Tools Use: Identifying a playground -
  public struct __ID: Equatable, Hashable, CustomStringConvertible, Sendable {
    public var __name: String?
    public var __fileID: String
    public var __line: Int
    public var __column: Int

    public init(__name: String? = nil, __fileID: String, __line: Int, __column: Int) {
      self.__name = __name
      self.__fileID = __fileID
      self.__line = __line
      self.__column = __column
    }

    public var description: String {
      let location = "\(__fileID):\(__line):\(__column)"
      if let name = __name {
        return "\(name) at \(location)"
      }
      return location
    }

    /// Returns true only if the other ID has matching file and line, but
    /// not the same column (so they aren't the same IDs).
    public func sharesLine(with otherID: __ID) -> Bool {
      self.__fileID == otherID.__fileID &&
      self.__line   == otherID.__line   &&
      self.__column != otherID.__column
    }
  }

  // MARK: - For Tools Use: Public properties of a playground -

  public var __name: String? { playgroundContent.name }
  public var __id: __ID { playgroundContent.id }

  /// A name for the playground that is always displayable.
  public var __displayName: String {
    if let name = __name {
      return name
    }
    return String(describing: __id)
  }

  // MARK: - For Tools Use: Public function to run a playground -

  /// Executes the body of the playground
  public func __run() async throws {
    try await playgroundContent.body()
  }

  // MARK: - For Tools Use: Public functions to fetch playground records -

  /// Returns all playgrounds found at runtime
  public static func __allPlaygrounds() -> [__Playground] {
    PlaygroundContent.all.map { __Playground(from: $0) }
  }

  /// Returns a specific playground by name, if found at runtime
  public static func __getPlayground(named name: String) -> __Playground? {
    getPlayground(withHint: .name(name))
  }

  /// Returns a specific playground by ID, if found at runtime
  public static func __getPlayground(identifiedBy id: __ID) -> __Playground? {
    getPlayground(withHint: .id(id))
  }

  /// Returns all playgrounds matching the description, which can be either a playground
  /// name or a "filename:line:column" description string or subset of that description (like
  /// filename only to return all playgrounds in the given file).
  public static func __findPlaygrounds(describedBy description: String) -> [__Playground] {
    // If a playground name matches the description exactly, return it
    if let playground = __getPlayground(named: description) {
      return [playground]
    }

    guard let descriptionComponents = PlaygroundDescriptionComponents.parsePlaygroundDescription(description) else {
      return []
    }

    let matchingContent = PlaygroundContent.all.filter { playgroundContent in
      descriptionComponents.matches(playgroundContent)
    }

    return matchingContent.map { __Playground(from: $0) }
  }

  // MARK: - Internal implementation details -

  internal init(from playgroundContent: PlaygroundContent) {
    self.playgroundContent = playgroundContent
  }

  internal let playgroundContent: PlaygroundContent

  /// Returns a specific playground by hint, if found at runtime
  internal static func getPlayground(withHint hint: PlaygroundContent.Hint) -> __Playground? {
    PlaygroundContent.find(withHint: hint).map { playground in
      __Playground(from: playground)
    }
  }

}

extension __Playground: CustomStringConvertible {
  public var description: String {
    let id = __id
    return "<__Playground name=\"\(__name ?? "(none)")\", fileID=\"\(id.__fileID)\", line=\(id.__line), column=\(id.__column)>"
  }
}

fileprivate struct PlaygroundDescriptionComponents {
  var fileID: String?
  var fileName: String?
  var lineNumber: Int?
  var columnNumber: Int?
  
  static func parsePlaygroundDescription(_ description: String) -> PlaygroundDescriptionComponents? {
    var descriptionComponents = PlaygroundDescriptionComponents()
    
    let components = description.split(separator: ":", maxSplits: 3)
    guard components.count >= 1 && components.count <= 3 else {
      return nil
    }
    
    descriptionComponents.fileID = String(components[0])
    
    guard let fileName = components[0].split(separator: "/").last else {
      return nil
    }
    descriptionComponents.fileName = String(fileName)
    
    if components.count >= 2 {
      guard let lineNumber = Int(components[1]) else { return nil }
      descriptionComponents.lineNumber = lineNumber
    }
    
    if components.count == 3 {
      guard let columnNumber = Int(components[2]) else { return nil }
      descriptionComponents.columnNumber = columnNumber
    }
    
    return descriptionComponents
  }
  
  func matches(_ playgroundContent: PlaygroundContent) -> Bool {
    if let columnNumber {
      if playgroundContent.column != columnNumber {
        // Specified column number doesn't match
        return false
      }
    }
    
    if let lineNumber {
      if playgroundContent.line != lineNumber {
        // Specified line number doesn't match
        return false
      }
    }
    
    if let fileID, playgroundContent.fileID == fileID {
      // File ID matches exactly
      return true
    }
    
    if let fileName {
      if let contentFileName = playgroundContent.fileID.split(separator: "/").last,
         String(contentFileName) == fileName
      {
        // The file name matches
        return true
      }
    }
    
    return false
  }
}

