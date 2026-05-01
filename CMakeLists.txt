cmake_minimum_required(VERSION 4.1)
project(iiHtmlBlock)

set(CMAKE_CXX_STANDARD 20)

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
