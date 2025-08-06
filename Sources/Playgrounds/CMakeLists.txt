# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

if(NOT DEFINED SWIFT_TESTING_BUILD_DIR)
  # Assume a relative path to the swift-testing build directory, such as when building Swift
  set(SWIFT_TESTING_BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../swifttesting-${SwiftPlay_PLATFORM_SUBDIR}-${SwiftPlay_ARCH_SUBDIR}" CACHE PATH "Path to swift-testing build directory")
endif()

# Verify that the swift-testing build directory exists
if(NOT EXISTS "${SWIFT_TESTING_BUILD_DIR}")
  message(FATAL_ERROR "Swift Testing build directory not found at: ${SWIFT_TESTING_BUILD_DIR}")
endif()

# Check for required swift-testing components
if(NOT EXISTS "${SWIFT_TESTING_BUILD_DIR}/swift")
  message(FATAL_ERROR "Swift Testing swift directory not found at: ${SWIFT_TESTING_BUILD_DIR}/swift")
endif()

if(NOT EXISTS "${SWIFT_TESTING_BUILD_DIR}/lib")
  message(FATAL_ERROR "Swift Testing lib directory not found at: ${SWIFT_TESTING_BUILD_DIR}/lib")
endif()

add_library(Playgrounds
  Discoverable/PlaygroundContent+Discoverable.swift
  Discoverable/PlaygroundContent+Hashable.swift
  Discoverable/PlaygroundContent.swift
  ToolsAPI/EntryPoints/SwiftPMEntryPoint.swift
  ToolsAPI/Playground.swift
  Playgrounds.swift)

# Add compile options to find swift-testing modules
target_compile_options(Playgrounds PRIVATE
  -I${SWIFT_TESTING_BUILD_DIR}/swift)

# Add linker options to find swift-testing libraries
target_link_options(Playgrounds PRIVATE
  -L${SWIFT_TESTING_BUILD_DIR}/lib)

target_link_libraries(Playgrounds PRIVATE
  _TestDiscovery
  _TestingInternals)
if(NOT APPLE)
#  if(NOT CMAKE_SYSTEM_NAME STREQUAL WASI)
#    target_link_libraries(Playgrounds PUBLIC
#      dispatch)
#  endif()
  target_link_libraries(Playgrounds PUBLIC
    Foundation)
#  if (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
#    target_link_libraries(Playgrounds PUBLIC execinfo)
#  endif()
endif()
if(NOT BUILD_SHARED_LIBS)
  # When building a static library, tell clients to autolink the internal
  # libraries.
  target_compile_options(Playgrounds PRIVATE
    "SHELL:-Xfrontend -public-autolink-library -Xfrontend _TestDiscovery"
    "SHELL:-Xfrontend -public-autolink-library -Xfrontend _TestingInternals")
endif()
add_dependencies(Playgrounds
  PlaygroundMacros)
target_compile_options(Playgrounds PRIVATE
  -enable-library-evolution
  -emit-module-interface -emit-module-interface-path $<TARGET_PROPERTY:Playgrounds,Swift_MODULE_DIRECTORY>/Playgrounds.swiftinterface)

_swift_playgrounds_install_target(Playgrounds)
