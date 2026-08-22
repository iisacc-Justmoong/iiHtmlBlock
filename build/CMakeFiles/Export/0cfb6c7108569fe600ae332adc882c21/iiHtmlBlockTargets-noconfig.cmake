#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "iiHtmlBlock::iiHtmlBlock" for configuration ""
set_property(TARGET iiHtmlBlock::iiHtmlBlock APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(iiHtmlBlock::iiHtmlBlock PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libiiHtmlBlock.so"
  IMPORTED_SONAME_NOCONFIG "libiiHtmlBlock.so"
  )

list(APPEND _cmake_import_check_targets iiHtmlBlock::iiHtmlBlock )
list(APPEND _cmake_import_check_files_for_iiHtmlBlock::iiHtmlBlock "${_IMPORT_PREFIX}/lib/libiiHtmlBlock.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
