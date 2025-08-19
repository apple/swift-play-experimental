# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

# The current version of the Swift Play Experimental release. For release branches,
# remember to remove -dev.
set(SWP_PLAYGROUNDS_LIBRARY_VERSION "6.3-dev")

find_package(Git QUIET)
if(Git_FOUND)
  # Get the commit hash corresponding to the current build. Limit length to 15
  # to match `swift --version` output format.
  execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short=15 --verify HEAD
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET)

  # Check if there are local changes.
  execute_process(
    COMMAND ${GIT_EXECUTABLE} status -s
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_STATUS
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(GIT_STATUS)
    set(GIT_VERSION "${GIT_VERSION} - modified")
  endif()
endif()

# Combine the hard-coded Swift version with available Git information.
if(GIT_VERSION)
set(SWP_PLAYGROUNDS_LIBRARY_VERSION "${SWP_PLAYGROUNDS_LIBRARY_VERSION} (${GIT_VERSION})")
endif()

# All done!
message(STATUS "Swift Play Experimental version: ${SWP_PLAYGROUNDS_LIBRARY_VERSION}")
add_compile_definitions(
  "$<$<COMPILE_LANGUAGE:CXX>:SWP_PLAYGROUNDS_LIBRARY_VERSION=\"${SWP_PLAYGROUNDS_LIBRARY_VERSION}\">")
