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

# Platform-specific definitions.
if(APPLE)
  add_compile_definitions("SWP_TARGET_OS_APPLE")
endif()
