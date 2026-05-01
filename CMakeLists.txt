cmake_minimum_required(VERSION 4.1)
project(iiHtmlBlock VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

if(EXISTS "$ENV{HOME}/Qt/6.8.3/macos/lib/cmake/Qt6/Qt6Config.cmake")
    list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/Qt/6.8.3/macos")
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
        Src/Modifier/CombineBlock.cpp
        Src/Modifier/CombineBlock.h
        Src/Modifier/FlattenBlock.cpp
        Src/Modifier/FlattenBlock.h
        Src/Modifier/iiXmlToHTML.cpp
        Src/Modifier/iiXmlToHTML.h)

target_include_directories(iiHtmlBlock PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

target_link_libraries(iiHtmlBlock PUBLIC
        Qt6::Core
        iiXml::iiXml)

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
