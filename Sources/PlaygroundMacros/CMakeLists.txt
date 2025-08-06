# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

cmake_minimum_required(VERSION 3.19.6...3.29)

if(POLICY CMP0157)
  cmake_policy(SET CMP0157 NEW)
endif()

project(PlaygroundMacros
  LANGUAGES Swift)

list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_SOURCE_DIR}/../../cmake/modules/shared)

if(WIN32)
  add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
endif()

find_package(SwiftSyntax CONFIG GLOBAL)

if(SwiftPlay_BuildMacrosAsExecutables)
  # When building the macro plugin as an executable, clone and build
  # swift-syntax.
  include(FetchContent)
  set(FETCHCONTENT_BASE_DIR ${CMAKE_BINARY_DIR}/_d)
  FetchContent_Declare(SwiftSyntax
    GIT_REPOSITORY https://github.com/swiftlang/swift-syntax
    GIT_TAG 340f8400262d494c7c659cd838223990195d7fed) # 602.0.0-prerelease-2025-04-10
  FetchContent_MakeAvailable(SwiftSyntax)
endif()

# Include these modules _after_ swift-syntax is declared above, but _before_ the
# macro plugin target is declared below, so that its settings are not applied to
# the former but are applied to the latter.
include(AvailabilityDefinitions)
include(CompilerSettings)

if(SwiftPlay_BuildMacrosAsExecutables)
  # When swift-syntax is built locally, the macro plugin must be built as an
  # executable.
  add_executable(PlaygroundMacros)

  set_target_properties(PlaygroundMacros PROPERTIES
    ENABLE_EXPORTS TRUE)

  # Parse the module as a library, even though it's an executable, because it
  # uses an `@main` type to define its entry point.
  target_compile_options(PlaygroundMacros PRIVATE -parse-as-library)

  # Include the .swift file which contains its `@main` entry point type.
  target_compile_definitions(PlaygroundMacros PRIVATE SWP_NO_LIBRARY_MACRO_PLUGINS)

  install(TARGETS PlaygroundMacros
    RUNTIME DESTINATION bin)
else()
  add_library(PlaygroundMacros SHARED)

  target_link_options(PlaygroundMacros PRIVATE "-no-toolchain-stdlib-rpath")
  set_property(TARGET PlaygroundMacros PROPERTY BUILD_WITH_INSTALL_RPATH YES)

  if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(plugin_destination_dir "lib/swift/host/plugins/playgrounds")
    set_property(TARGET PlaygroundMacros PROPERTY INSTALL_RPATH)
  else()
    set(plugin_destination_dir "lib/swift/host/plugins")
    # RPATH 'lib/swift/{system}' and 'lib/swift/host'
    set_property(TARGET PlaygroundMacros PROPERTY
      INSTALL_RPATH "$ORIGIN/../../$<LOWER_CASE:${CMAKE_SYSTEM_NAME}>;$ORIGIN/..")
  endif()

  install(TARGETS PlaygroundMacros
    LIBRARY DESTINATION "${plugin_destination_dir}"
    RUNTIME DESTINATION bin)
endif()

target_sources(PlaygroundMacros PRIVATE
  PlaygroundMacrosMain.swift
  PlaygroundMacro.swift)

target_compile_options(PlaygroundMacros PRIVATE
  "SHELL:-Xfrontend -disable-implicit-string-processing-module-import")

target_link_libraries(PlaygroundMacros PRIVATE
  SwiftSyntax::SwiftSyntax
  SwiftSyntax::SwiftSyntaxMacroExpansion
  SwiftSyntax::SwiftSyntaxMacros)
if(SwiftPlay_BuildMacrosAsExecutables)
  # Link the 'SwiftCompilerPlugin' target, but only when built as an executable.
  target_link_libraries(PlaygroundMacros PRIVATE
    SwiftSyntax::SwiftCompilerPlugin)
endif()
