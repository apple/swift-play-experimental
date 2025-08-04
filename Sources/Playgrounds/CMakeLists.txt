# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

add_library(Playgrounds
  Discoverable/PlaygroundContent+Discoverable.swift
  Discoverable/PlaygroundContent+Hashable.swift
  Discoverable/PlaygroundContent.swift
  ToolsAPI/EntryPoints/SwiftPMEntryPoint.swift
  ToolsAPI/Playground.swift
  Playgrounds.swift)
target_link_libraries(Playgrounds PRIVATE
  _TestDiscovery)
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
    "SHELL:-Xfrontend -public-autolink-library -Xfrontend _TestDiscovery")
endif()
add_dependencies(Playgrounds
  PlaygroundMacros)
target_compile_options(Playgrounds PRIVATE
  -enable-library-evolution
  -emit-module-interface -emit-module-interface-path $<TARGET_PROPERTY:Playgrounds,Swift_MODULE_DIRECTORY>/Playgrounds.swiftinterface)

_swift_playgrounds_install_target(Playgrounds)

## Install the Swift cross-import overlay directory.
#_swift_playgrounds_install_swiftcrossimport(Playgrounds
#  Playgrounds.swiftcrossimport)
