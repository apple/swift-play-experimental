//
// This source file is part of the Swift Play Experimental open source project
//
// Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//

import Foundation

/// Legacy entry point to the playgrounds library used by Swift Package Manager.
///
/// (No longer used by recent SwiftPM implementation. This function only remains
/// for compatibility with older SwiftPM checkouts, and will be removed soon.)
///
/// - Parameters:
///   - args: Command-line arguments to interpret.
///
/// - Returns: The result of invoking the playgrounds library. The type of this
///   value is subject to change.
///
/// This function examines the command-line arguments represented by `args` and
/// then invokes the playgrounds library in the current process.
///
/// - Warning: This function is used by Swift Package Manager. Do not call it
///   directly.
@available(*, deprecated, message: "Not used by SwiftPM anymore")
public func __swiftPMEntryPoint(_ args: [String]) -> CInt {
  var listOption = false
  var oneShotOption = false
  var libPath = ""
  var playgroundDescription = ""
  
  // Parse arguments
  for arg in args {
    if arg == "--list" {
      listOption = true
    }
    else if arg == "--one-shot" {
      oneShotOption = true
    }
    else if arg == "--lib-path" {
      libPath = args[args.index(after: args.firstIndex(of: "--lib-path")!)]
    }
    else if arg != libPath {
      playgroundDescription = arg
    }
  }
  
  if libPath.isEmpty {
    print("Specify the path to a dylib with --lib-path <dylib path>")
    return 1
  }
  
  // Load the specified dylib
#if canImport(Darwin)
  let flags = RTLD_LAZY | RTLD_FIRST
#else
  let flags = RTLD_LAZY
#endif
  guard let image = dlopen(libPath, flags) else {
    let errorMessage: String = dlerror().flatMap {
#if compiler(>=6)
      String(validatingCString: $0)
#else
      String(validatingUTF8: $0)
#endif
    } ?? "An unknown error occurred."
    fatalError("Failed to open target library at path \(libPath): \(errorMessage)")
  }
  defer {
    dlclose(image)
  }
  
  func printListOfPlaygrounds(_ playgrounds: [__Playground]) {
    for playground in playgrounds.sorted(by: playgroundSort) {
      let playgroundName = {
        if let name = playground.__name {
          return "\"\(name)\""
        }
        return "(unnamed)"
      }()
      print("* \(playground.__id.__fileID):\(playground.__id.__line) \(playgroundName)")
    }
  }

  if listOption {
    // List playgrounds only
    let playgrounds = __Playground.__allPlaygrounds()
    print("Found \(playgrounds.count) Playground\(playgrounds.count==1 ? "" : "s")")
    printListOfPlaygrounds(playgrounds)
  }
  else {
    let playgrounds = __Playground.__findPlaygrounds(describedBy: playgroundDescription)
    guard playgrounds.count > 0 else {
      print("Unknown Playground \"\(playgroundDescription)\"")
      return 1
    }
    
    guard playgrounds.count == 1 else {
      print("Multiple playgrounds match the given description \"\(playgroundDescription)\"")
      printListOfPlaygrounds(playgrounds)
      return 1
    }
    
    let playground = playgrounds[0]
    
    print("---- Running Playground \"\(playground.__displayName)\" - Hit ^C to quit ----")
    Task {
      try await playground.__run()
      
      if oneShotOption {
        // Exit immediately after one-shot execution
        exit(0)
      }
    }
    
    // Wait forever so Playground can continue executing asynchronous calls
    RunLoop.main.run(until: Date.distantFuture)
  }
  
  return 0
}

/// The entry point to the playgrounds library used by Swift Package Manager.
///
/// - Parameters:
///   - args: Swift Play arguments to interpret.
///
/// - Returns: The result of invoking the playgrounds library.
///
/// This function examines the arguments represented by `args` and
/// then invokes the playgrounds library in the current process.
///
/// - Warning: This function is used by Swift Package Manager. Do not call it
///   directly.
@discardableResult
public func __swiftPlayEntryPoint(_ args: [String]) async -> Int {
  var listOption = false
  var oneShotOption = false
  var playgroundDescription = ""

  // Parse arguments
  for arg in args {
    if arg == "--list" {
      listOption = true
    }
    else if arg == "--one-shot" {
      oneShotOption = true
    }
    else {
      playgroundDescription = arg
    }
  }

  func printListOfPlaygrounds(_ playgrounds: [__Playground]) {
    for playground in playgrounds.sorted(by: playgroundSort) {
      let playgroundName = {
        if let name = playground.__name {
          return name
        }
        return "(unnamed)"
      }()
      print("* \(playground.__id.__fileID):\(playground.__id.__line) \(playgroundName)")
    }
  }

  if listOption {
    // List playgrounds only
    let playgrounds = __Playground.__allPlaygrounds()
    print("Found \(playgrounds.count) Playground\(playgrounds.count==1 ? "" : "s")")
    printListOfPlaygrounds(playgrounds)
    return 0
  }

  let playgrounds = __Playground.__findPlaygrounds(describedBy: playgroundDescription)
  guard playgrounds.count > 0 else {
    print("Unknown Playground \"\(playgroundDescription)\"")
    return 1
  }

  guard playgrounds.count == 1 else {
    print("Multiple playgrounds match the given description \"\(playgroundDescription)\"")
    printListOfPlaygrounds(playgrounds)
    return 1
  }

  let playground = playgrounds[0]

  print("---- Running Playground \"\(playground.__displayName)\" - Hit ^C to quit ----")

  do {
    try await playground.__run()
  } catch {
    print("Playground stopped with error: \(error)")
  }

  if oneShotOption {
    // Exit immediately after one-shot execution
    return 0
  }

  // Wait forever so Playground can continue executing any asynchronous calls.
  do {
    while true {
      let sleepTime: UInt64 = 2_000_000_000_000 // an arbitrary amount of many seconds
      try await Task.sleep(nanoseconds: sleepTime)
    }
  } catch {
    print("\(error)")
  }

  return 0
}

/// Sort playgrounds by file/line/column.
private func playgroundSort(_ lhs: __Playground, _ rhs: __Playground) -> Bool {
  if lhs.__id.__fileID == rhs.__id.__fileID {
    if lhs.__id.__line == rhs.__id.__line {
      return lhs.__id.__column < rhs.__id.__column
    }
    else {
      return lhs.__id.__line < rhs.__id.__line
    }
  }
  else {
    return  lhs.__id.__fileID < rhs.__id.__fileID
  }
}
