# CMake generated Testfile for 
# Source directory: /home/ymy/Developer/iiHtmlBlock
# Build directory: /home/ymy/Developer/iiHtmlBlock/build
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
add_test(Parser_GetTagInfo_ParsesValueAndFields "/home/ymy/Developer/iiHtmlBlock/build/GetTagInfo_test")
set_tests_properties(Parser_GetTagInfo_ParsesValueAndFields PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;95;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Parser_GetHTML_ReturnsHtmlTags "/home/ymy/Developer/iiHtmlBlock/build/GetHTML_test")
set_tests_properties(Parser_GetHTML_ReturnsHtmlTags PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;103;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_iiXmlToHTML_ConvertsThroughGetHTML "/home/ymy/Developer/iiHtmlBlock/build/iiXmlToHTML_test")
set_tests_properties(Modifier_iiXmlToHTML_ConvertsThroughGetHTML PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;111;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_DivideBlock_ClassifiesDisplayBlocks "/home/ymy/Developer/iiHtmlBlock/build/DivideBlock_test")
set_tests_properties(Modifier_DivideBlock_ClassifiesDisplayBlocks PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;119;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_BlockRangeTracker_TracksDocumentRanges "/home/ymy/Developer/iiHtmlBlock/build/BlockRangeTracker_test")
set_tests_properties(Modifier_BlockRangeTracker_TracksDocumentRanges PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;127;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_BlockHTMLSerializer_SerializesBlockResults "/home/ymy/Developer/iiHtmlBlock/build/BlockHTMLSerializer_test")
set_tests_properties(Modifier_BlockHTMLSerializer_SerializesBlockResults PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;135;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_DeleteBlock_RemovesSelectedBlock "/home/ymy/Developer/iiHtmlBlock/build/DeleteBlock_test")
set_tests_properties(Modifier_DeleteBlock_RemovesSelectedBlock PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;143;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_CombineBlock_MergesSelectedBlocks "/home/ymy/Developer/iiHtmlBlock/build/CombineBlock_test")
set_tests_properties(Modifier_CombineBlock_MergesSelectedBlocks PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;151;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Modifier_FlattenBlock_LayersDocumentBlocks "/home/ymy/Developer/iiHtmlBlock/build/FlattenBlock_test")
set_tests_properties(Modifier_FlattenBlock_LayersDocumentBlocks PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;159;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(install_layout_test "/home/ymy/Developer/iiHtmlBlock/build/install_layout_test")
set_tests_properties(install_layout_test PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;167;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(umbrella_header_test "/home/ymy/Developer/iiHtmlBlock/build/umbrella_header_test")
set_tests_properties(umbrella_header_test PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;175;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
add_test(Example_ParsedXmlHtml_HandlesParsedXmlAndHtml "/home/ymy/Developer/iiHtmlBlock/build/ParsedXmlHtmlExample")
set_tests_properties(Example_ParsedXmlHtml_HandlesParsedXmlAndHtml PROPERTIES  _BACKTRACE_TRIPLES "/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;183;add_test;/home/ymy/Developer/iiHtmlBlock/CMakeLists.txt;0;")
