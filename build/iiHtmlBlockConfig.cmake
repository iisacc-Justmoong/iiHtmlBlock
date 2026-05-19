
####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was iiHtmlBlockConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

include(CMakeFindDependencyMacro)

get_filename_component(_iiHtmlBlockSiblingIiXmlPrefix "${PACKAGE_PREFIX_DIR}/../iiXml" ABSOLUTE)

foreach(_iiHtmlBlockDependencyPrefix IN ITEMS
    "${_iiHtmlBlockSiblingIiXmlPrefix}"
    "$ENV{HOME}/.local/iiXml"
    "$ENV{HOME}/Qt/6.8.3/macos"
)
    if(EXISTS "${_iiHtmlBlockDependencyPrefix}")
        list(PREPEND CMAKE_PREFIX_PATH "${_iiHtmlBlockDependencyPrefix}")
    endif()
endforeach()

unset(_iiHtmlBlockDependencyPrefix)
unset(_iiHtmlBlockSiblingIiXmlPrefix)

find_dependency(Qt6 6.8.3 EXACT COMPONENTS Core)
find_dependency(iiXml 0.1.0 CONFIG REQUIRED)

include("${CMAKE_CURRENT_LIST_DIR}/iiHtmlBlockTargets.cmake")
