#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <sys/stat.h>

namespace {

int failures = 0;

std::string ReadFile(const std::string& path) {
    std::ifstream file(path);
    if (!file.is_open()) {
        return {};
    }

    std::ostringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

void ExpectContains(const std::string& content, const std::string& token, const char* message) {
    if (content.find(token) == std::string::npos) {
        std::cerr << message << '\n';
        ++failures;
    }
}

void ExpectNotContains(const std::string& content, const std::string& token, const char* message) {
    if (content.find(token) != std::string::npos) {
        std::cerr << message << '\n';
        ++failures;
    }
}

void ExpectExecutable(const std::string& path, const char* message) {
    struct stat info {};
    if (stat(path.c_str(), &info) != 0 || (info.st_mode & S_IXUSR) == 0) {
        std::cerr << message << '\n';
        ++failures;
    }
}

void ExpectExecutableScriptHeader(const std::string& content) {
    ExpectContains(content, "#!/usr/bin/env bash", "install.sh must be a bash script.");
    ExpectContains(content, "set -euo pipefail", "install.sh must fail on script errors.");
}

} // namespace

int main() {
    const std::string root = IIHTMLBLOCK_SOURCE_DIR;
    const std::string install_script_path = root + "/install.sh";
    const std::string install_script = ReadFile(install_script_path);
    const std::string cmake_lists = ReadFile(root + "/CMakeLists.txt");
    const std::string config_template = ReadFile(root + "/cmake/iiHtmlBlockConfig.cmake.in");
    const std::string docs = ReadFile(root + "/Docs/install.md");
    const std::string umbrella = ReadFile(root + "/iiHtmlBlock");
    const std::string public_header = ReadFile(root + "/iiHtmlBlock.h");
    const std::string umbrella_test = ReadFile(root + "/Test/umbrella_header_test.cpp");

    ExpectExecutableScriptHeader(install_script);
    ExpectExecutable(install_script_path, "install.sh must be executable.");
    ExpectContains(install_script, "PREFIX=\"${HOME}/.local/iiHtmlBlock\"",
        "install.sh must install to ~/.local/iiHtmlBlock.");
    ExpectContains(install_script, "BUILD_DIR=\"${ROOT_DIR}/build\"",
        "install.sh must use build/ as the build directory.");
    ExpectContains(install_script, "IIXML_PREFIX=\"${HOME}/.local/iiXml\"",
        "install.sh must look for the iiXml install prefix.");
    ExpectContains(install_script, "cmake --install \"${BUILD_DIR}\" --prefix \"${PREFIX}\"",
        "install.sh must run cmake install with the ~/.local/iiHtmlBlock prefix.");
    ExpectContains(install_script, "LEGACY_INCLUDE_DIR=\"${PREFIX}/include/iiHtmlBlock\"",
        "install.sh must detect the legacy include/iiHtmlBlock directory.");
    ExpectContains(install_script, "rm -rf \"${LEGACY_INCLUDE_DIR}\"",
        "install.sh must remove the legacy include/iiHtmlBlock directory before installing the <iiHtmlBlock> header.");

    ExpectContains(cmake_lists, "include(GNUInstallDirs)",
        "CMakeLists.txt must use GNUInstallDirs for install destinations.");
    ExpectContains(cmake_lists, "install(TARGETS iiHtmlBlock",
        "CMakeLists.txt must install the iiHtmlBlock library target.");
    ExpectContains(cmake_lists, "EXPORT iiHtmlBlockTargets",
        "CMakeLists.txt must export iiHtmlBlockTargets.");
    ExpectContains(cmake_lists, "NAMESPACE iiHtmlBlock::",
        "CMakeLists.txt must install the iiHtmlBlock:: imported target namespace.");
    ExpectContains(cmake_lists, "configure_package_config_file",
        "CMakeLists.txt must generate iiHtmlBlockConfig.cmake.");
    ExpectContains(cmake_lists, "install(FILES iiHtmlBlock iiHtmlBlock.h",
        "CMakeLists.txt must install the extensionless <iiHtmlBlock> umbrella header.");
    ExpectContains(cmake_lists, "install(DIRECTORY Src/",
        "CMakeLists.txt must install public module headers.");
    ExpectContains(cmake_lists, "DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/Src",
        "CMakeLists.txt must install module headers without occupying include/iiHtmlBlock.");

    ExpectContains(config_template, "find_dependency(Qt6 6.8.3 EXACT COMPONENTS Core)",
        "iiHtmlBlockConfig.cmake.in must declare the Qt 6.8.3 dependency.");
    ExpectContains(config_template, "find_dependency(iiXml 0.1.0 CONFIG REQUIRED)",
        "iiHtmlBlockConfig.cmake.in must declare the iiXml dependency.");
    ExpectContains(config_template, "PACKAGE_PREFIX_DIR}/../iiXml",
        "iiHtmlBlockConfig.cmake.in must search the sibling iiXml install prefix.");
    ExpectContains(config_template, "$ENV{HOME}/.local/iiXml",
        "iiHtmlBlockConfig.cmake.in must search the default ~/.local/iiXml install prefix.");
    ExpectContains(config_template, "list(PREPEND CMAKE_PREFIX_PATH",
        "iiHtmlBlockConfig.cmake.in must prepend dependency prefixes before find_dependency.");
    ExpectContains(config_template, "iiHtmlBlockTargets.cmake",
        "iiHtmlBlockConfig.cmake.in must include exported targets.");

    ExpectContains(umbrella, "#include \"iiHtmlBlock.h\"",
        "The extensionless iiHtmlBlock header must include iiHtmlBlock.h.");
    ExpectContains(public_header, "#include \"Src/Parser/GetHTML.h\"",
        "iiHtmlBlock.h must expose parser public headers.");
    ExpectContains(public_header, "#include \"Src/Modifier/DivideBlock.h\"",
        "iiHtmlBlock.h must expose modifier public headers.");
    ExpectNotContains(public_header, "void hello",
        "iiHtmlBlock.h must not expose the placeholder hello function.");
    ExpectContains(umbrella_test, "#include <iiHtmlBlock>",
        "umbrella_header_test.cpp must compile the public angle-bracket include.");
    ExpectContains(umbrella_test, "iiHtmlBlock::GetHTML",
        "umbrella_header_test.cpp must use the iiHtmlBlock namespace.");

    ExpectContains(docs, "./install.sh", "Docs/install.md must document the install script.");
    ExpectContains(docs, "~/.local/iiHtmlBlock",
        "Docs/install.md must document the fixed ~/.local/iiHtmlBlock install prefix.");
    ExpectContains(docs, "~/.local/iiXml",
        "Docs/install.md must document the iiXml dependency prefix.");
    ExpectContains(docs, "find_package(iiHtmlBlock CONFIG REQUIRED)",
        "Docs/install.md must document CMake package loading.");
    ExpectContains(docs, "include(\"$ENV{HOME}/.local/iiHtmlBlock/lib/cmake/iiHtmlBlock/iiHtmlBlockConfig.cmake\")",
        "Docs/install.md must document direct include loading.");
    ExpectContains(docs, "iiXml prefix를 별도로 추가하지 않아도",
        "Docs/install.md must document automatic iiXml dependency discovery.");
    ExpectContains(docs, "iiHtmlBlock::iiHtmlBlock",
        "Docs/install.md must document the imported target.");
    ExpectContains(docs, "#include <iiHtmlBlock>",
        "Docs/install.md must document extensionless umbrella include usage.");

    return failures == 0 ? 0 : 1;
}
