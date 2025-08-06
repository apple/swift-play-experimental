# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

set(SwiftPlay_MACRO "<auto>" CACHE STRING
    "Path to Playgrounds macro plugin, or '<auto>' for automatically building it")

if(SwiftPlay_MACRO STREQUAL "<auto>")
  # Macros must be built for the build machine, not the host.
  include(ExternalProject)
  if(NOT SwiftPlay_MACRO_MAKE_PROGRAM)
    set(SwiftPlay_MACRO_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM})
  endif()
  if(NOT SwiftPlay_MACRO_Swift_COMPILER)
    set(SwiftPlay_MACRO_Swift_COMPILER ${CMAKE_Swift_COMPILER})
  endif()
  if(NOT SwiftPlay_MACRO_Swift_FLAGS)
    set(SwiftPlay_MACRO_Swift_FLAGS ${CMAKE_Swift_FLAGS})
    set(SwiftPlay_MACRO_SWIFT_FLAGS_RELEASE ${CMAKE_Swift_FLAGS_RELEASE})
    set(SwiftPlay_MACRO_SWIFT_FLAGS_RELWITHDEBINFO ${CMAKE_Swift_FLAGS_RELWITHDEBINFO})
  endif()
  if(NOT SwiftPlay_MACRO_AR)
    set(SwiftPlay_MACRO_AR ${CMAKE_AR})
  endif()
  if(NOT SwiftPlay_MACRO_RANLIB)
    set(SwiftPlay_MACRO_RANLIB ${CMAKE_RANLIB})
  endif()
  if(NOT SwiftPlay_MACRO_BUILD_TYPE)
    set(SwiftPlay_MACRO_BUILD_TYPE ${CMAKE_BUILD_TYPE})
  endif()

  find_package(SwiftSyntax CONFIG GLOBAL)
  if(SwiftSyntax_FOUND)
    set(SwiftPlay_BuildMacrosAsExecutables NO)
  else()
    set(SwiftPlay_BuildMacrosAsExecutables YES)
  endif()

  # Build and install the plugin into the current build directry.
  set(SwiftPlay_MACRO_INSTALL_PREFIX "${CMAKE_BINARY_DIR}")

  ExternalProject_Add(PlaygroundMacros
    PREFIX "pm"
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/PlaygroundMacros"
    BUILD_ALWAYS ON
    CMAKE_ARGS
      -DCMAKE_MAKE_PROGRAM=${SwiftPlay_MACRO_MAKE_PROGRAM}
      -DCMAKE_Swift_COMPILER=${SwiftPlay_MACRO_Swift_COMPILER}
      -DCMAKE_Swift_FLAGS=${SwiftPlay_MACRO_Swift_FLAGS}
      -DCMAKE_Swift_FLAGS_RELEASE=${SwiftPlay_MACRO_Swift_FLAGS_RELEASE}
      -DCMAKE_Swift_FLAGS_RELWITHDEBINFO=${SwiftPlay_MACRO_Swift_FLAGS_RELWITHDEBINFO}
      -DCMAKE_AR=${SwiftPlay_MACRO_AR}
      -DCMAKE_RANLIB=${SwiftPlay_MACRO_RANLIB}
      -DCMAKE_BUILD_TYPE=${CSwiftPlay_MACRO_BUILD_TYPE}
      -DSwiftPlay_BuildMacrosAsExecutables=${SwiftPlay_BuildMacrosAsExecutables}
      -DSwiftSyntax_DIR=${SwiftSyntax_DIR}
      -DCMAKE_INSTALL_PREFIX=${SwiftPlay_MACRO_INSTALL_PREFIX})

  # Hardcode the known file names based on system name as a workaround since
  # PlaygroundMacros uses `ExternalProject` and we cannot directly query the
  # properties of its targets here.
  if(NOT SwiftPlay_BuildMacrosAsExecutables)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(SwiftPlay_MACRO_PATH "${SwiftPlay_MACRO_INSTALL_PREFIX}/lib/swift/host/plugins/playgrounds/libPlaygroundMacros.dylib")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
      set(SwiftPlay_MACRO_PATH "${SwiftPlay_MACRO_INSTALL_PREFIX}/lib/swift/host/plugins/libPlaygroundMacros.so")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      set(SwiftPlay_MACRO_PATH "${SwiftPlay_MACRO_INSTALL_PREFIX}/bin/PlaygroundMacros.dll")
    else()
      message(FATAL_ERROR "Unable to determine the library name for PlaygroundMacros based on system name: ${CMAKE_HOST_SYSTEM_NAME}")
    endif()
  else()
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      set(SwiftPlay_MACRO_PATH "${SwiftPlay_MACRO_INSTALL_PREFIX}/bin/PlaygroundMacros.exe")
    else()
      set(SwiftPlay_MACRO_PATH "${SwiftPlay_MACRO_INSTALL_PREFIX}/bin/PlaygroundMacros")
    endif()
  endif()
elseif(SwiftPlay_MACRO)
  # Use the passed-in plugin path.
  set(SwiftPlay_MACRO_PATH "${SwiftPlay_MACRO}")
  add_custom_target(PlaygroundMacros DEPENDS "${SwiftPlay_MACRO_PATH}")
else()
  # If it's explicitly "NO", do not compile the library with macros.
  add_custom_target(PlaygroundMacros)
endif()

if(NOT SwiftPlay_MACRO_PATH)
  message(STATUS "PlaygroundMacros: (none)")
elseif(SwiftPlay_MACRO_PATH)
  if(SwiftPlay_MACRO_PATH MATCHES [[\.(dylib|so|dll)$]])
    message(STATUS "PlaygroundMacros: ${SwiftPlay_MACRO_PATH} (shared library)")
    add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-load-plugin-library \"${SwiftPlay_MACRO_PATH}\">")
  else()
    message(STATUS "PlaygroundMacros: ${SwiftPlay_MACRO_PATH} (executable)")
    add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-load-plugin-executable \"${SwiftPlay_MACRO_PATH}#PlaygroundMacros\">")
  endif()
endif()

include(AvailabilityDefinitions)
include(CompilerSettings)
add_subdirectory(Playgrounds)
