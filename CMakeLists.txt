cmake_minimum_required(VERSION 3.24)
project(iiHtmlBlock VERSION 0.1.0 LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL AND CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(_sdk_home "$ENV{HOME}")
    if(_sdk_home STREQUAL "")
        set(_sdk_home "$ENV{USERPROFILE}")
    endif()
    set(CMAKE_INSTALL_PREFIX "${_sdk_home}/.local/SDK/iiHtmlBlock" CACHE PATH
        "Installation prefix for iiHtmlBlock." FORCE)
    unset(_sdk_home)
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

function(iihtmlblock_append_prefix_if_exists prefix)
    if(EXISTS "${prefix}")
        list(APPEND CMAKE_PREFIX_PATH "${prefix}")
        set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
    endif()
endfunction()

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    iihtmlblock_append_prefix_if_exists("/Volumes/Storage/Qt/6.8.3/ios")
    iihtmlblock_append_prefix_if_exists("$ENV{HOME}/.local/SDK/iiXml/platforms/ios")
    set(_iihtmlblock_platform_iixml_dir "$ENV{HOME}/.local/SDK/iiXml/platforms/ios/lib/cmake/iiXml")
elseif(ANDROID)
    iihtmlblock_append_prefix_if_exists("/Volumes/Storage/Qt/6.8.3/android_arm64_v8a")
    iihtmlblock_append_prefix_if_exists("$ENV{HOME}/.local/SDK/iiXml/platforms/android")
    set(_iihtmlblock_platform_iixml_dir "$ENV{HOME}/.local/SDK/iiXml/platforms/android/lib/cmake/iiXml")
elseif(EMSCRIPTEN)
    iihtmlblock_append_prefix_if_exists("/Volumes/Storage/Qt/6.8.3/wasm_multithread")
    iihtmlblock_append_prefix_if_exists("/Volumes/Storage/Qt/6.8.3/wasm_singlethread")
    iihtmlblock_append_prefix_if_exists("$ENV{HOME}/.local/SDK/iiXml/platforms/wasm")
    set(_iihtmlblock_platform_iixml_dir "$ENV{HOME}/.local/SDK/iiXml/platforms/wasm/lib/cmake/iiXml")
else()
    iihtmlblock_append_prefix_if_exists("/Volumes/Storage/Qt/6.8.3/macos")
    iihtmlblock_append_prefix_if_exists("$ENV{HOME}/.local/SDK/iiXml")
endif()

if(DEFINED _iihtmlblock_platform_iixml_dir)
    if(EXISTS "${_iihtmlblock_platform_iixml_dir}/iiXmlConfig.cmake"
            AND (NOT DEFINED iiXml_DIR OR iiXml_DIR STREQUAL "" OR iiXml_DIR MATCHES "-NOTFOUND$"))
        set(iiXml_DIR "${_iihtmlblock_platform_iixml_dir}" CACHE PATH
            "iiXml target platform package directory" FORCE)
    endif()
endif()

iihtmlblock_append_prefix_if_exists("$ENV{HOME}/.local/SDK")

find_package(Qt6 6.8.3 EXACT REQUIRED COMPONENTS Core)
find_package(iiXml 0.1.0 REQUIRED CONFIG)

set(IIHTMLBLOCK_LIBRARY_TYPE SHARED)
if(EMSCRIPTEN)
    set(IIHTMLBLOCK_LIBRARY_TYPE STATIC)
endif()

add_library(iiHtmlBlock ${IIHTMLBLOCK_LIBRARY_TYPE} iiHtmlBlock.cpp
        Src/Parser/GetHTML.cpp
        Src/Parser/GetHTML.h
        Src/Parser/GetTagInfo.cpp
        Src/Parser/GetTagInfo.h
        Src/Modifier/BlockHTMLSerializer.cpp
        Src/Modifier/BlockHTMLSerializer.h
        Src/Modifier/BlockRangeTracker.cpp
        Src/Modifier/BlockRangeTracker.h
        Src/Modifier/DivideBlock.cpp
        Src/Modifier/DivideBlock.h
        Src/Modifier/DeleteBlock.cpp
        Src/Modifier/DeleteBlock.h
        Src/Modifier/CombineBlock.cpp
        Src/Modifier/CombineBlock.h
        Src/Modifier/FlattenBlock.cpp
        Src/Modifier/FlattenBlock.h
        Src/Modifier/iiXmlToHTML.cpp
        Src/Modifier/iiXmlToHTML.h)

target_include_directories(iiHtmlBlock PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

target_link_libraries(iiHtmlBlock PUBLIC
        Qt6::Core
        iiXml::iiXml)

install(TARGETS iiHtmlBlock
        EXPORT iiHtmlBlockTargets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})

install(FILES iiHtmlBlock iiHtmlBlock.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(DIRECTORY Src/
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/Src
        FILES_MATCHING PATTERN "*.h")

install(EXPORT iiHtmlBlockTargets
        FILE iiHtmlBlockTargets.cmake
        NAMESPACE iiHtmlBlock::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/iiHtmlBlock)

configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/iiHtmlBlockConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/iiHtmlBlockConfig.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/iiHtmlBlock)

write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/iiHtmlBlockConfigVersion.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion)

write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/iiHtmlBlockConfigVersionRoot.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
        ARCH_INDEPENDENT)

install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/iiHtmlBlockConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/iiHtmlBlockConfigVersion.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/iiHtmlBlock)

enable_testing()

add_executable(GetTagInfo_test
        Test/GetTagInfo_test.cpp)

target_link_libraries(GetTagInfo_test PRIVATE
        iiHtmlBlock)

add_test(NAME Parser_GetTagInfo_ParsesValueAndFields COMMAND GetTagInfo_test)

add_executable(GetHTML_test
        Test/GetHTML_test.cpp)

target_link_libraries(GetHTML_test PRIVATE
        iiHtmlBlock)

add_test(NAME Parser_GetHTML_ReturnsHtmlTags COMMAND GetHTML_test)

add_executable(iiXmlToHTML_test
        Test/iiXmlToHTML_test.cpp)

target_link_libraries(iiXmlToHTML_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_iiXmlToHTML_ConvertsThroughGetHTML COMMAND iiXmlToHTML_test)

add_executable(DivideBlock_test
        Test/DivideBlock_test.cpp)

target_link_libraries(DivideBlock_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_DivideBlock_ClassifiesDisplayBlocks COMMAND DivideBlock_test)

add_executable(BlockRangeTracker_test
        Test/BlockRangeTracker_test.cpp)

target_link_libraries(BlockRangeTracker_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_BlockRangeTracker_TracksDocumentRanges COMMAND BlockRangeTracker_test)

add_executable(BlockHTMLSerializer_test
        Test/BlockHTMLSerializer_test.cpp)

target_link_libraries(BlockHTMLSerializer_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_BlockHTMLSerializer_SerializesBlockResults COMMAND BlockHTMLSerializer_test)

add_executable(DeleteBlock_test
        Test/DeleteBlock_test.cpp)

target_link_libraries(DeleteBlock_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_DeleteBlock_RemovesSelectedBlock COMMAND DeleteBlock_test)

add_executable(CombineBlock_test
        Test/CombineBlock_test.cpp)

target_link_libraries(CombineBlock_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_CombineBlock_MergesSelectedBlocks COMMAND CombineBlock_test)

add_executable(FlattenBlock_test
        Test/FlattenBlock_test.cpp)

target_link_libraries(FlattenBlock_test PRIVATE
        iiHtmlBlock)

add_test(NAME Modifier_FlattenBlock_LayersDocumentBlocks COMMAND FlattenBlock_test)

add_executable(install_layout_test
        Test/install_layout_test.cpp)

target_compile_definitions(install_layout_test PRIVATE
        IIHTMLBLOCK_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

add_test(NAME install_layout_test COMMAND install_layout_test)

add_executable(umbrella_header_test
        Test/umbrella_header_test.cpp)

target_link_libraries(umbrella_header_test PRIVATE
        iiHtmlBlock)

add_test(NAME umbrella_header_test COMMAND umbrella_header_test)

add_executable(ParsedXmlHtmlExample
        Example/ParsedXmlHtmlExample.cpp)

target_link_libraries(ParsedXmlHtmlExample PRIVATE
        iiHtmlBlock)

add_test(NAME Example_ParsedXmlHtml_HandlesParsedXmlAndHtml COMMAND ParsedXmlHtmlExample)

# These executable checks use assert for both validation and parser setup.
# Release must execute those expressions just as Debug does.
foreach(_test_target IN ITEMS
        GetTagInfo_test GetHTML_test iiXmlToHTML_test DivideBlock_test
        BlockRangeTracker_test BlockHTMLSerializer_test DeleteBlock_test
        CombineBlock_test FlattenBlock_test umbrella_header_test ParsedXmlHtmlExample)
    if(MSVC)
        target_compile_options(${_test_target} PRIVATE /UNDEBUG)
    else()
        target_compile_options(${_test_target} PRIVATE -UNDEBUG)
    endif()
endforeach()
