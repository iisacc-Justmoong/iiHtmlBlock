cmake_minimum_required(VERSION 4.1)
project(iiHtmlBlock)

set(CMAKE_CXX_STANDARD 20)

add_library(iiHtmlBlock SHARED iiHtmlBlock.cpp
        Src/Parser/GetHTML.cpp
        Src/Parser/GetHTML.h
        Src/Parser/GetTagInfo.cpp
        Src/Parser/GetTagInfo.h)
