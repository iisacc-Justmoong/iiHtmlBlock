set(fixture "${IIHTMLBLOCK_BINARY_DIR}/dependency-selection")
set(prefix "${fixture}/stage")
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
    string(APPEND prefix "/platforms/macos")
endif()
execute_process(COMMAND "${CMAKE_COMMAND}" --install "${IIHTMLBLOCK_BINARY_DIR}"
        --prefix "${prefix}" --config Release RESULT_VARIABLE installed
        OUTPUT_VARIABLE output ERROR_VARIABLE error)
if(NOT installed EQUAL 0)
    message(FATAL_ERROR "Package staging failed: ${output}\n${error}")
endif()
file(MAKE_DIRECTORY "${fixture}/source")
file(WRITE "${fixture}/source/CMakeLists.txt" [=[
cmake_minimum_required(VERSION 3.24)
project(SelectedXmlConsumer LANGUAGES CXX)
set(expected_xml "${iiXml_DIR}")
find_package(iiHtmlBlock CONFIG REQUIRED)
if(NOT iiXml_DIR STREQUAL expected_xml)
    message(FATAL_ERROR "iiHtmlBlock replaced selected iiXml: ${expected_xml} -> ${iiXml_DIR}")
endif()
]=])
execute_process(COMMAND "${CMAKE_COMMAND}" --fresh
        -S "${fixture}/source" -B "${fixture}/build"
        "-DiiHtmlBlock_DIR=${prefix}/lib/cmake/iiHtmlBlock"
        "-DiiXml_DIR=${IIXML_DIR}" "-DiiFileProvider_DIR=${IIFILEPROVIDER_DIR}"
        "-DQt6_DIR=${QT6_DIR}" "-DCMAKE_OSX_SYSROOT=${OSX_SYSROOT}"
        RESULT_VARIABLE configured OUTPUT_VARIABLE output ERROR_VARIABLE error)
if(NOT configured EQUAL 0)
    message(FATAL_ERROR "Installed dependency selection failed: ${output}\n${error}")
endif()
