# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

set(SwiftPlaygrounds_MACRO "<auto>" CACHE STRING
    "Path to SwiftPlaygrounds macro plugin, or '<auto>' for automatically building it")

if(SwiftPlaygrounds_MACRO STREQUAL "<auto>")
  # Macros must be built for the build machine, not the host.
  include(ExternalProject)
  if(NOT SwiftPlaygrounds_MACRO_MAKE_PROGRAM)
    set(SwiftPlaygrounds_MACRO_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM})
  endif()
  if(NOT SwiftPlaygrounds_MACRO_Swift_COMPILER)
    set(SwiftPlaygrounds_MACRO_Swift_COMPILER ${CMAKE_Swift_COMPILER})
  endif()
  if(NOT SwiftPlaygrounds_MACRO_Swift_FLAGS)
    set(SwiftPlaygrounds_MACRO_Swift_FLAGS ${CMAKE_Swift_FLAGS})
    set(SwiftPlaygrounds_MACRO_SWIFT_FLAGS_RELEASE ${CMAKE_Swift_FLAGS_RELEASE})
    set(SwiftPlaygrounds_MACRO_SWIFT_FLAGS_RELWITHDEBINFO ${CMAKE_Swift_FLAGS_RELWITHDEBINFO})
  endif()
  if(NOT SwiftPlaygrounds_MACRO_AR)
    set(SwiftPlaygrounds_MACRO_AR ${CMAKE_AR})
  endif()
  if(NOT SwiftPlaygrounds_MACRO_RANLIB)
    set(SwiftPlaygrounds_MACRO_RANLIB ${CMAKE_RANLIB})
  endif()
  if(NOT SwiftPlaygrounds_MACRO_BUILD_TYPE)
    set(SwiftPlaygrounds_MACRO_BUILD_TYPE ${CMAKE_BUILD_TYPE})
  endif()

  find_package(SwiftSyntax CONFIG GLOBAL)
  if(SwiftSyntax_FOUND)
    set(SwiftPlaygrounds_BuildMacrosAsExecutables NO)
  else()
    set(SwiftPlaygrounds_BuildMacrosAsExecutables YES)
  endif()

  # Build and install the plugin into the current build directry.
  set(SwiftPlaygrounds_MACRO_INSTALL_PREFIX "${CMAKE_BINARY_DIR}")

  ExternalProject_Add(PlaygroundMacros
    PREFIX "pm"
    SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/PlaygroundMacros"
    BUILD_ALWAYS ON
    CMAKE_ARGS
      -DCMAKE_MAKE_PROGRAM=${SwiftPlaygrounds_MACRO_MAKE_PROGRAM}
      -DCMAKE_Swift_COMPILER=${SwiftPlaygrounds_MACRO_Swift_COMPILER}
      -DCMAKE_Swift_FLAGS=${SwiftPlaygrounds_MACRO_Swift_FLAGS}
      -DCMAKE_Swift_FLAGS_RELEASE=${SwiftPlaygrounds_MACRO_Swift_FLAGS_RELEASE}
      -DCMAKE_Swift_FLAGS_RELWITHDEBINFO=${SwiftPlaygrounds_MACRO_Swift_FLAGS_RELWITHDEBINFO}
      -DCMAKE_AR=${SwiftPlaygrounds_MACRO_AR}
      -DCMAKE_RANLIB=${SwiftPlaygrounds_MACRO_RANLIB}
      -DCMAKE_BUILD_TYPE=${CSwiftPlaygrounds_MACRO_BUILD_TYPE}
      -DSwiftPlaygrounds_BuildMacrosAsExecutables=${SwiftPlaygrounds_BuildMacrosAsExecutables}
      -DSwiftSyntax_DIR=${SwiftSyntax_DIR}
      -DCMAKE_INSTALL_PREFIX=${SwiftPlaygrounds_MACRO_INSTALL_PREFIX})

  # Hardcode the known file names based on system name as a workaround since
  # PlaygroundMacros uses `ExternalProject` and we cannot directly query the
  # properties of its targets here.
  if(NOT SwiftPlaygrounds_BuildMacrosAsExecutables)
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
      set(SwiftPlaygrounds_MACRO_PATH "${SwiftPlaygrounds_MACRO_INSTALL_PREFIX}/lib/swift/host/plugins/playgrounds/libPlaygroundMacros.dylib")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_HOST_SYSTEM_NAME STREQUAL "FreeBSD")
      set(SwiftPlaygrounds_MACRO_PATH "${SwiftPlaygrounds_MACRO_INSTALL_PREFIX}/lib/swift/host/plugins/libPlaygroundMacros.so")
    elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      set(SwiftPlaygrounds_MACRO_PATH "${SwiftPlaygrounds_MACRO_INSTALL_PREFIX}/bin/PlaygroundMacros.dll")
    else()
      message(FATAL_ERROR "Unable to determine the library name for PlaygroundMacros based on system name: ${CMAKE_HOST_SYSTEM_NAME}")
    endif()
  else()
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
      set(SwiftPlaygrounds_MACRO_PATH "${SwiftPlaygrounds_MACRO_INSTALL_PREFIX}/bin/PlaygroundMacros.exe")
    else()
      set(SwiftPlaygrounds_MACRO_PATH "${SwiftPlaygrounds_MACRO_INSTALL_PREFIX}/bin/PlaygroundMacros")
    endif()
  endif()
elseif(SwiftPlaygrounds_MACRO)
  # Use the passed-in plugin path.
  set(SwiftPlaygrounds_MACRO_PATH "${SwiftPlaygrounds_MACRO}")
  add_custom_target(PlaygroundMacros DEPENDS "${SwiftPlaygrounds_MACRO_PATH}")
else()
  # If it's explicitly "NO", do not compile the library with macros.
  add_custom_target(PlaygroundMacros)
endif()

if(NOT SwiftPlaygrounds_MACRO_PATH)
  message(STATUS "PlaygroundMacros: (none)")
elseif(SwiftPlaygrounds_MACRO_PATH)
  if(SwiftPlaygrounds_MACRO_PATH MATCHES [[\.(dylib|so|dll)$]])
    message(STATUS "PlaygroundMacros: ${SwiftPlaygrounds_MACRO_PATH} (shared library)")
    add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-load-plugin-library \"${SwiftPlaygrounds_MACRO_PATH}\">")
  else()
    message(STATUS "PlaygroundMacros: ${SwiftPlaygrounds_MACRO_PATH} (executable)")
    add_compile_options("$<$<COMPILE_LANGUAGE:Swift>:SHELL:-load-plugin-executable \"${SwiftPlaygrounds_MACRO_PATH}#PlaygroundMacros\">")
  endif()
endif()

include(AvailabilityDefinitions)
include(CompilerSettings)
add_subdirectory(Playgrounds)
