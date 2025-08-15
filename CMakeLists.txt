# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

cmake_minimum_required(VERSION 3.19.6...3.29)

project(SwiftPlayExperimental
  LANGUAGES Swift)

include(GNUInstallDirs)

list(APPEND CMAKE_MODULE_PATH
  ${PROJECT_SOURCE_DIR}/cmake/modules
  ${PROJECT_SOURCE_DIR}/cmake/modules/shared)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_INSTALL_RPATH "$<IF:$<PLATFORM_ID:Darwin>,@loader_path/..,$ORIGIN>")
set(CMAKE_INSTALL_REMOVE_ENVIRONMENT_RPATH YES)

set(CMAKE_MSVC_RUNTIME_LIBRARY MultiThreadedDLL)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_Swift_LANGUAGE_VERSION 6)
set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

include(PlatformInfo)
include(SwiftModuleInstallation)

option(SwiftPlay_INSTALL_NESTED_SUBDIR "Install libraries under a platform and architecture subdirectory" NO)
set(SwiftPlay_INSTALL_LIBDIR "${CMAKE_INSTALL_LIBDIR}/swift$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:_static>/${SwiftPlay_PLATFORM_SUBDIR}$<$<AND:$<PLATFORM_ID:Darwin>,$<NOT:$<BOOL:${SwiftPlay_INSTALL_NESTED_SUBDIR}>>>:>$<$<BOOL:${SwiftPlay_INSTALL_NESTED_SUBDIR}>:/${SwiftPlay_ARCH_SUBDIR}>")
set(SwiftPlay_INSTALL_SWIFTMODULEDIR "${CMAKE_INSTALL_LIBDIR}/swift$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:_static>/${SwiftPlay_PLATFORM_SUBDIR}$<$<AND:$<PLATFORM_ID:Darwin>,$<NOT:$<BOOL:${SwiftPlay_INSTALL_NESTED_SUBDIR}>>>:>")

add_compile_options($<$<COMPILE_LANGUAGE:Swift>:-no-toolchain-stdlib-rpath>)

add_subdirectory(Sources)
