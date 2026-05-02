#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
PREFIX="${HOME}/.local/iiHtmlBlock"
QT_PREFIX="${HOME}/Qt/6.8.3/macos"
IIXML_PREFIX="${HOME}/.local/iiXml"

cmake_args=(
    -S "${ROOT_DIR}"
    -B "${BUILD_DIR}"
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
)

cmake_prefixes=()
if [[ -d "${QT_PREFIX}/lib/cmake/Qt6" ]]; then
    cmake_prefixes+=("${QT_PREFIX}")
fi

if [[ -d "${IIXML_PREFIX}/lib/cmake/iiXml" ]]; then
    cmake_prefixes+=("${IIXML_PREFIX}")
fi

if [[ ${#cmake_prefixes[@]} -gt 0 ]]; then
    cmake_prefix_path="$(IFS=';'; echo "${cmake_prefixes[*]}")"
    cmake_args+=(-DCMAKE_PREFIX_PATH="${cmake_prefix_path}")
fi

echo "Configuring iiHtmlBlock for install prefix: ${PREFIX}"
cmake "${cmake_args[@]}"

echo "Building iiHtmlBlock in ${BUILD_DIR}"
cmake --build "${BUILD_DIR}"

echo "Running iiHtmlBlock tests"
ctest --test-dir "${BUILD_DIR}" --output-on-failure

LEGACY_INCLUDE_DIR="${PREFIX}/include/iiHtmlBlock"
if [[ -d "${LEGACY_INCLUDE_DIR}" && ( -f "${LEGACY_INCLUDE_DIR}/iiHtmlBlock.h" || -d "${LEGACY_INCLUDE_DIR}/Src" ) ]]; then
    echo "Removing legacy iiHtmlBlock include directory: ${LEGACY_INCLUDE_DIR}"
    rm -rf "${LEGACY_INCLUDE_DIR}"
fi

echo "Installing iiHtmlBlock into ${PREFIX}"
cmake --install "${BUILD_DIR}" --prefix "${PREFIX}"

echo "iiHtmlBlock installed."
