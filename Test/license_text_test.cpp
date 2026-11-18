#include <filesystem>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

namespace {

int failures = 0;

std::string ReadFile(const std::filesystem::path& path) {
    std::ifstream file(path);
    if (!file.is_open()) {
        std::cerr << "missing file: " << path << '\n';
        ++failures;
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

bool IsPolicyFile(const std::filesystem::path& root, const std::filesystem::path& path) {
    const std::filesystem::path relative = std::filesystem::relative(path, root);
    const std::string name = relative.generic_string();
    return name == "README.md"
        || name == "NOTICE"
        || name == "AGENTS.md"
        || name == "Docs/License.md"
        || name == "Test/license_text_test.cpp";
}

void RejectOtherLicenseClaims(const std::filesystem::path& root) {
    const std::string mit_heading = "MIT License";
    const std::string mit_spdx = "SPDX-License-Identifier: MIT";
    const std::string affero = "Affero";
    auto iterator = std::filesystem::recursive_directory_iterator(root);
    const auto end = std::filesystem::recursive_directory_iterator();
    for (; iterator != end; ++iterator) {
        const std::filesystem::path path = iterator->path();
        const std::string filename = path.filename().string();
        if (iterator->is_directory() && (filename == ".git" || filename == "build")) {
            iterator.disable_recursion_pending();
            continue;
        }
        if (!iterator->is_regular_file()) {
            continue;
        }
        const std::string relative = std::filesystem::relative(path, root).generic_string();
        if (relative == "LICENSE" || IsPolicyFile(root, path)) {
            continue;
        }
        const std::string content = ReadFile(path);
        if (content.find(mit_heading) != std::string::npos
                || content.find(mit_spdx) != std::string::npos
                || content.find(affero) != std::string::npos) {
            std::cerr << "unexpected license claim in " << relative << '\n';
            ++failures;
        }
    }
}

} // namespace

int main() {
    const std::filesystem::path root = IIHTMLBLOCK_SOURCE_DIR;
    const std::string license = ReadFile(root / "LICENSE");
    const std::string notice = ReadFile(root / "NOTICE");
    const std::string readme = ReadFile(root / "README.md");
    const std::string agents = ReadFile(root / "AGENTS.md");
    const std::string korean = ReadFile(root / "Docs" / "License.md");
    const std::string install_doc = ReadFile(root / "Docs" / "install.md");
    const std::string cmake_lists = ReadFile(root / "CMakeLists.txt");
    const std::string config_template = ReadFile(root / "cmake" / "iiHtmlBlockConfig.cmake.in");

    ExpectContains(license, "Apache License", "LICENSE must be the Apache License.");
    ExpectContains(license, "Version 2.0, January 2004", "LICENSE must be Apache License 2.0.");
    ExpectContains(license, "http://www.apache.org/licenses/", "LICENSE must cite the Apache license URL.");
    ExpectContains(license, "Grant of Patent License", "LICENSE must include the patent grant.");
    ExpectContains(license, "END OF TERMS AND CONDITIONS", "LICENSE must include the full terms.");
    ExpectContains(license, "APPENDIX: How to apply the Apache License to your work.",
        "LICENSE must include the Apache appendix.");
    ExpectNotContains(license, "MIT License", "LICENSE must not remain the MIT license.");
    ExpectNotContains(license, "Permission is hereby granted, free of charge",
        "LICENSE must not keep the MIT permission grant.");

    ExpectContains(notice, "Copyright (c) 2026 iisacc", "NOTICE must carry the iisacc copyright line.");
    ExpectContains(notice, "https://github.com/iisacc-Justmoong",
        "NOTICE must name the distribution owner.");
    ExpectContains(notice, "Apache License", "NOTICE must identify Apache-2.0.");
    ExpectContains(notice, "AGPL-3.0-or-later",
        "NOTICE must keep the product AGPL policy.");

    ExpectContains(readme, "SPDX-License-Identifier: Apache-2.0",
        "README must identify Apache-2.0.");
    ExpectContains(readme, "Copyright (c) 2026 iisacc", "README must state the copyright line.");
    ExpectContains(readme, "Docs/License.md", "README must link to the Korean license statement.");
    ExpectNotContains(readme, "SPDX-License-Identifier: MIT", "README must not keep the MIT SPDX identifier.");
    ExpectNotContains(readme, "MIT License", "README must not claim the MIT License.");

    ExpectContains(agents, "Apache License 2.0", "AGENTS.md must state Apache-2.0.");
    ExpectContains(agents, "Copyright (c) 2026 iisacc", "AGENTS.md must state the copyright line.");
    ExpectContains(agents, "Docs/License.md", "AGENTS.md must link to the Korean license statement.");

    ExpectContains(korean, "SPDX-License-Identifier: Apache-2.0",
        "Docs/License.md must identify Apache-2.0.");
    ExpectContains(korean, "Copyright (c) 2026 iisacc",
        "Docs/License.md must state the copyright line.");
    ExpectContains(korean, "AGPL-3.0-or-later",
        "Docs/License.md must keep the product AGPL policy.");

    ExpectContains(cmake_lists, "set(iiHtmlBlock_SPDX_LICENSE \"Apache-2.0\")",
        "CMakeLists.txt must record the package SPDX identifier.");
    ExpectContains(cmake_lists, "\"${CMAKE_CURRENT_SOURCE_DIR}/LICENSE\"",
        "CMakeLists.txt must install LICENSE.");
    ExpectContains(cmake_lists, "\"${CMAKE_CURRENT_SOURCE_DIR}/NOTICE\"",
        "CMakeLists.txt must install NOTICE.");
    ExpectContains(cmake_lists, "\"${CMAKE_CURRENT_SOURCE_DIR}/Docs/License.md\"",
        "CMakeLists.txt must install the Korean license statement.");
    ExpectContains(config_template, "set(iiHtmlBlock_SPDX_LICENSE \"Apache-2.0\")",
        "The package config must export iiHtmlBlock_SPDX_LICENSE.");
    ExpectContains(install_doc, "share/iiHtmlBlock/LICENSE",
        "Docs/install.md must document the installed LICENSE.");
    ExpectContains(install_doc, "IIHTMLBLOCK_SKIP_LIBRARY=ON",
        "Docs/install.md must document the dependency-free license test.");
    ExpectContains(cmake_lists, "IIHTMLBLOCK_SKIP_LIBRARY",
        "CMakeLists.txt must allow a dependency-free license test.");

    RejectOtherLicenseClaims(root);

    return failures == 0 ? 0 : 1;
}
