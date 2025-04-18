# Swift Play Experimental

<!--
This source file is part of the Swift Play Experimental open source project

Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
Licensed under Apache License v2.0 with Runtime Library Exception

See https://swift.org/LICENSE.txt for license information
-->

## Feature overview

The Swift Play Experimental project contains a Playgrounds library
that provides a `#Playground` macro for declaring runnable blocks
of code in any Swift file. Being in the same file allows the
playground code to access private entities in the file.

```swift
$ cat Sources/Fibonacci/Fibonacci.swift
func fibonacci(_ n: Int) -> Int {
 ...
}

import Playgrounds

#Playground("Fibonacci") {
  for n in 0..<10 {
    print("fibonacci(\(n)) = \(fibonacci(n))")
  }
}
```

### Tools API

Swift tools and IDEs can use the provided tools-based API to
enumerate and run playgrounds found in a process.

```
let foundPlaygrounds = __Playground.__allPlaygrounds()
print("Found playgrounds:")
for playground in foundPlaygrounds {
    print("* \(playground.__displayName)")
}
    
if let playground = __Playground.__getPlayground(named: "Fibonacci") {
    try await playground.__run()
}
```

For example, a prototype Swift Package Manager branch adds a
`swift play` command which can be used to list and execute
playgrounds found in a package.

For example:
```
$ swift play --list  
Building for debugging...
Found 1 Playground
* Fibonacci/Fibonacci.swift:23 "Fibonacci"

$ swift play Fibonacci
Building for debugging...
---- Running Playground "Fibonacci" - Hit ^C to quit ----
Fibonacci(7) = 21
^C
```

See CONTRIBUTING.md for details on trying out Swift Play
Experimental with the Swift Package Manager "swift play"
prototype.

### Cross-platform support

macOS is supported. Other platforms to be supported soon. 
