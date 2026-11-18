if(NOT DEFINED SOURCE_DIR OR NOT DEFINED BUILD_DIR OR NOT DEFINED DATA_DIR)
    message(FATAL_ERROR "SOURCE_DIR, BUILD_DIR and DATA_DIR are required")
endif()

set(_prefix "${BUILD_DIR}/license-install-test")
if(EXISTS "${_prefix}")
    file(REMOVE_RECURSE "${_prefix}")
endif()

execute_process(COMMAND "${CMAKE_COMMAND}" --install "${BUILD_DIR}" --prefix "${_prefix}"
    RESULT_VARIABLE _result OUTPUT_VARIABLE _output ERROR_VARIABLE _error)
if(NOT _result EQUAL 0)
    message(FATAL_ERROR "License installation failed: ${_output}\n${_error}")
endif()

set(_pairs
    "LICENSE|LICENSE"
    "NOTICE|NOTICE"
    "docs/License.md|Docs/License.md")
foreach(_pair IN LISTS _pairs)
    string(REPLACE "|" ";" _parts "${_pair}")
    list(GET _parts 0 _relative)
    list(GET _parts 1 _source)
    set(_document "${_prefix}/${DATA_DIR}/iiHtmlBlock/${_relative}")
    if(NOT EXISTS "${_document}")
        message(FATAL_ERROR "The installed ${_relative} is missing")
    endif()
    file(SHA256 "${SOURCE_DIR}/${_source}" _expected)
    file(SHA256 "${_document}" _actual)
    if(NOT _actual STREQUAL _expected)
        message(FATAL_ERROR "The installed ${_relative} differs from the maintained source")
    endif()
endforeach()

file(READ "${_prefix}/${DATA_DIR}/iiHtmlBlock/LICENSE" _license)
file(READ "${_prefix}/${DATA_DIR}/iiHtmlBlock/NOTICE" _notice)
string(FIND "${_license}" "Apache License" _apache_at)
string(FIND "${_license}" "Version 2.0, January 2004" _version_at)
string(FIND "${_notice}" "Copyright (c) 2026 iisacc" _copyright_at)
if(_apache_at EQUAL -1 OR _version_at EQUAL -1 OR _copyright_at EQUAL -1)
    message(FATAL_ERROR "Installed LICENSE or NOTICE does not carry the Apache-2.0 grant")
endif()

message(STATUS "Installed LICENSE, NOTICE, and Korean license statement match the maintained files")
