cmake_minimum_required(VERSION 4.1)
project(iiHtmlBlock VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

if(EXISTS "$ENV{HOME}/Qt/6.8.3/macos/lib/cmake/Qt6/Qt6Config.cmake")
    list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/Qt/6.8.3/macos")
endif()

if(EXISTS "$ENV{HOME}/.local/iiXml/lib/cmake/iiXml/iiXmlConfig.cmake")
    list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/.local/iiXml")
endif()

if(EXISTS "$ENV{HOME}/.local/lib/cmake/iiXml/iiXmlConfig.cmake")
    list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/.local")
endif()

find_package(Qt6 6.8.3 EXACT REQUIRED COMPONENTS Core)
find_package(iiXml 0.1.0 REQUIRED CONFIG)

add_library(iiHtmlBlock SHARED iiHtmlBlock.cpp
        Src/Parser/GetHTML.cpp
        Src/Parser/GetHTML.h
        Src/Parser/GetTagInfo.cpp
        Src/Parser/GetTagInfo.h
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
