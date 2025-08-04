# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

# Settings intended to be applied to every Swift target in this project.
# Analogous to project-level build settings in an Xcode project.
add_compile_options(
  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-package-name org.swift.play>")
#add_compile_options(
#  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -require-explicit-sendable>")
#add_compile_options(
#  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -enable-experimental-feature -Xfrontend AccessLevelOnImport>")
#add_compile_options(
#  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -enable-upcoming-feature -Xfrontend ExistentialAny>"
#  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -enable-upcoming-feature -Xfrontend InternalImportsByDefault>"
#  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -enable-upcoming-feature -Xfrontend MemberImportVisibility>"
#  "SHELL:$<$<COMPILE_LANGUAGE:Swift>:-Xfrontend -enable-upcoming-feature -Xfrontend InferIsolatedConformances>")

# Platform-specific definitions.
if(APPLE)
  add_compile_definitions("SWP_TARGET_OS_APPLE")
endif()
#set(SWP_NO_EXIT_TESTS_LIST "iOS" "watchOS" "tvOS" "visionOS" "WASI" "Android")
#if(CMAKE_SYSTEM_NAME IN_LIST SWP_NO_EXIT_TESTS_LIST)
#  add_compile_definitions("SWP_NO_EXIT_TESTS")
#endif()
#set(SWP_NO_PROCESS_SPAWNING_LIST "iOS" "watchOS" "tvOS" "visionOS" "WASI" "Android")
#if(CMAKE_SYSTEM_NAME IN_LIST SWP_NO_PROCESS_SPAWNING_LIST)
#  add_compile_definitions("SWP_NO_PROCESS_SPAWNING")
#endif()
#if(NOT APPLE)
#  add_compile_definitions("SWP_NO_SNAPSHOT_TYPES")
#  add_compile_definitions("SWP_NO_FOUNDATION_FILE_COORDINATION")
#endif()
#if(CMAKE_SYSTEM_NAME STREQUAL "WASI")
#  add_compile_definitions("SWP_NO_DYNAMIC_LINKING")
#  add_compile_definitions("SWP_NO_PIPES")
#endif()
