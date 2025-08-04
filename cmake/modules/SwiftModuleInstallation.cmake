# This source file is part of the Swift Play Experimental open source project
#
# Copyright (c) 2025 Apple Inc. and the Swift Play Experimental project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information

function(_swift_playgrounds_install_target module)
  install(TARGETS ${module}
    ARCHIVE DESTINATION "${SwiftPlaygrounds_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${SwiftPlaygrounds_INSTALL_LIBDIR}"
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

  get_target_property(type ${module} TYPE)
  if(type STREQUAL EXECUTABLE)
    return()
  endif()

  get_target_property(module_name ${module} Swift_MODULE_NAME)
  if(NOT module_name)
    set(module_name ${module})
  endif()

  set(module_dir ${SwiftPlaygrounds_INSTALL_SWIFTMODULEDIR}/${module_name}.swiftmodule)
  install(FILES $<TARGET_PROPERTY:${module},Swift_MODULE_DIRECTORY>/${module_name}.swiftdoc
    DESTINATION "${module_dir}"
    RENAME ${SwiftPlaygrounds_MODULE_TRIPLE}.swiftdoc)
  install(FILES $<TARGET_PROPERTY:${module},Swift_MODULE_DIRECTORY>/${module_name}.swiftinterface
    DESTINATION "${module_dir}"
    RENAME ${SwiftPlaygrounds_MODULE_TRIPLE}.swiftinterface)
endfunction()

# Install the specified .swiftcrossimport directory for the specified declaring
# module.
#
# Usage:
#   _swift_playgrounds_install_swiftcrossimport(module swiftcrossimport_dir)
#
# Arguments:
#   module: The name of the declaring module. This is used to determine where
#     the .swiftcrossimport directory should be installed, since it must be
#     adjacent to the declaring module's .swiftmodule directory.
#   swiftcrossimport_dir: The path to the source .swiftcrossimport directory
#     which will be installed.
#function(_swift_playgrounds_install_swiftcrossimport module swiftcrossimport_dir)
#  install(DIRECTORY "${swiftcrossimport_dir}"
#    DESTINATION "${SwiftPlaygrounds_INSTALL_SWIFTMODULEDIR}")
#endfunction()
