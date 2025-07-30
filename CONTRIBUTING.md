# Contributing to Swift Play Experimental

## Trying out #Playground with the “swift play” prototype

An experimental Swift Package Manager branch implements a new "swift play" command, which provides an easy way to list and run `#Playground` instances found in package library targets.

"swift play" is currently supported on macOS and Linux. With partial support for Windows.

### Swift Package Manager prototype branch build

Checkout and build the swift-package-manager branch `eng/chrismiles/swift-play-prototype` first.

    $ git clone git@github.com:chrismiles/swift-package-manager.git
    $ cd swift-package-manager
    $ git checkout eng/chrismiles/swift-play-prototype
    $ swift build

A successful build should produce a new `swift-play` executable.

    $ ls .build/arm64-apple-macosx/debug/swift-play
    .build/arm64-apple-macosx/debug/swift-play

Note the path of the executable for later.

### Try out "swift play"

Open any new or existing package containing a library target.

Add a package dependency to swift-play-experimental branch `main`.

    dependencies: [
        .package(url: "https://github.com/apple/swift-play-experimental", branch: "main"),
    ],

Add a Playgrounds dependency to any library targets that you want to use `#Playground` in.

    dependencies: [
        .product(name: "Playgrounds", package: "swift-play-experimental"),
    ]

You may also need to set a minimum platform version.  If so, you can add an entry like:

    platforms: [
        .macOS(.v10_15)
    ],

In a terminal, add the swiftpm debug products path to $PATH. Example:

    export PATH=~/swift-package-manager/.build/arm64-apple-macosx/debug:$PATH

Or, if using Swiftly which doesn't take PATH into account, you can instead create a symlink to the swift-play executable. For example, on Linux:

    ln -s ~/swift-package-manager/.build/aarch64-unknown-linux-gnu/debug/swift-play ~/.local/share/swiftly/toolchains/6.1.2/usr/bin/swift-play

Change directory to the package and use `swift play --list` to verify everything works with no code modifications. The package should build and you should see “Found 0 Playgrounds”. Example:

    $ swift play --list
    Building for debugging...
    Build of product 'Dice__REPL' complete! (32.61s)
    Found 0 Playgrounds

Problems at this point?

* If you see a build error “error: no such module 'Playgrounds’” then the Playgrounds package dependency isn’t properly configured.
* If you see any other build errors, make sure the package builds with the standard swift build first. If it only fails to build with swift play then submit a bug report.

Now you can import the Playgrounds module and add some `#Playground` declarations to your code. For example:

    $ cat <<EOF >> Sources/MyGame/Dice.swift
    import Playgrounds
    
    #Playground("d20") {
        let roll = Int.random(in: 1...20)
        print("d20 rolled \(roll)")
    }
    EOF
    $ swift play d20
    Building for debugging...
    ---- Running Playground "d20" - Hit ^C to quit ----
    d20 rolled 6
    ^C

Use `swift play <playground_name>` to run a playground, as shown in the example above.


## Reporting issues

Issues are tracked using the project's
[GitHub Issue Tracker](https://github.com/apple/swift-play-experimental/issues).

Fill in the fields of the relevant template form offered on that page when
creating new issues. For bug report issues, please include a minimal example
which reproduces the issue. Where possible, attach the example as a Swift
package, or include a URL to the package hosted on GitHub or another public
hosting service.

## Setting up the development environment

First, clone the Swift Play Experimental repository from
[https://github.com/apple/swift-play-experimental](https://github.com/apple/swift-play-experimental).

If you're preparing to make a contribution, you should fork the repository first
and clone the fork which will make opening PRs easier.

### Using Xcode (easiest)

1. Install Xcode 16 or newer from the [Apple Developer](https://developer.apple.com/xcode/)
   website.
1. Open the `Package.swift` file from the cloned Swift Play Experimental repository in
   Xcode.
1. Select the `swift-play` scheme (if not already selected) and the
   "My Mac" run destination.
1. Use Xcode to inspect, edit, build, or test the code.

### Using the command line

If you are using macOS and have Xcode installed, you can use Swift from the
command line immediately.

If you aren't using macOS or do not have Xcode installed, you need to download
and install a toolchain.

#### Installing a toolchain

1. Download a toolchain. A recent **6.0 development snapshot** toolchain is
   required to build the playgrounds library. Visit
   [swift.org](http://swift.org/install) and download the most recent toolchain
   from the section titled **release/6.0** under **Development Snapshots** on
   the page for your platform.

   Be aware that development snapshot toolchains aren't intended for day-to-day
   development and may contain defects that affect the programs built with them.
1. Install the toolchain and confirm it can be located successfully:

   **macOS with Xcode installed**:
   
   ```bash
   $> export TOOLCHAINS=swift
   $> xcrun --find swift
   /Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin/swift
   ```
   
   **Non-macOS or macOS without Xcode**:
   
   ```bash
   $> export PATH=/path/to/swift-toolchain/usr/bin:"${PATH}"
   $> which swift
   /path/to/swift-toolchain/usr/bin/swift
   ```

## Local development

With a Swift toolchain installed you are ready to make changes and test them locally.

### Building

```bash
$> swift build
```

### Testing

```bash
$> swift test
```
