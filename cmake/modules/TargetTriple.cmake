# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

# Ask the Swift compiler what target triple it will be compiling with today.
set(SWT_TARGET_INFO_COMMAND "${CMAKE_Swift_COMPILER}" -print-target-info)
if(CMAKE_Swift_COMPILER_TARGET)
  list(APPEND SWT_TARGET_INFO_COMMAND -target ${CMAKE_Swift_COMPILER_TARGET})
endif()
execute_process(COMMAND ${SWT_TARGET_INFO_COMMAND} OUTPUT_VARIABLE SWT_TARGET_INFO_JSON)
string(JSON SWT_TARGET_TRIPLE GET "${SWT_TARGET_INFO_JSON}" "target" "unversionedTriple")

# All done!
message(STATUS "Swift Play Experimental target triple: ${SWT_TARGET_TRIPLE}")
if(SWT_TARGET_TRIPLE)
  add_compile_definitions(
    "$<$<COMPILE_LANGUAGE:CXX>:SWT_TARGET_TRIPLE=\"${SWT_TARGET_TRIPLE}\">")
endif()
