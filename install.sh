#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ROOT_DIR}/build"
PREFIX="${HOME}/.local/SDK/iiHtmlBlock"
INSTALL_PLATFORMS="${IIHTMLBLOCK_INSTALL_PLATFORMS:-macos,ios,android,wasm}"
QT_ROOT="${IIHTMLBLOCK_QT_ROOT:-${HOME}/Qt/6.8.3}"
MACOS_QT_PREFIX="${IIHTMLBLOCK_MACOS_QT_PREFIX:-${QT_ROOT}/macos}"
IOS_QT_PREFIX="${IIHTMLBLOCK_IOS_QT_PREFIX:-${QT_ROOT}/ios}"
ANDROID_QT_PREFIX="${IIHTMLBLOCK_ANDROID_QT_PREFIX:-${QT_ROOT}/android_arm64_v8a}"
WASM_QT_PREFIX="${IIHTMLBLOCK_WASM_QT_PREFIX:-}"
IIXML_PREFIX="${HOME}/.local/SDK/iiXml"
IOS_IIXML_PREFIX="${HOME}/.local/SDK/iiXml/platforms/ios"
IOS_IIXML_DIR="${IOS_IIXML_PREFIX}/lib/cmake/iiXml"
ANDROID_IIXML_PREFIX="${HOME}/.local/SDK/iiXml/platforms/android"
ANDROID_IIXML_DIR="${ANDROID_IIXML_PREFIX}/lib/cmake/iiXml"
WASM_IIXML_PREFIX="${HOME}/.local/SDK/iiXml/platforms/wasm"
WASM_IIXML_DIR="${WASM_IIXML_PREFIX}/lib/cmake/iiXml"
MACOS_BUILD_DIR="${BUILD_DIR}"
IOS_BUILD_DIR="${BUILD_DIR}/platforms/ios"
ANDROID_BUILD_DIR="${BUILD_DIR}/platforms/android"
WASM_BUILD_DIR="${BUILD_DIR}/platforms/wasm"
MACOS_PREFIX="${PREFIX}"
MACOS_PLATFORM_PREFIX="${PREFIX}/platforms/macos"
IOS_PREFIX="${PREFIX}/platforms/ios"
ANDROID_PREFIX="${PREFIX}/platforms/android"
WASM_PREFIX="${PREFIX}/platforms/wasm"
IOS_TOOLCHAIN_FILE="${IOS_QT_PREFIX}/lib/cmake/Qt6/qt.toolchain.cmake"

cmake_cache_value() {
    local cache_file="$1"
    local key="$2"

    awk -F= -v key="${key}" \
        '$1 == key || $1 ~ ("^" key ":") { print substr($0, index($0, "=") + 1); exit }' \
        "${cache_file}"
}

remove_stale_build_dir() {
    local build_dir="$1"
    local cache_file="${build_dir}/CMakeCache.txt"

    if [[ ! -f "${cache_file}" ]]; then
        return
    fi

    local cached_source
    local cached_build
    local stale_cache=false

    cached_source="$(cmake_cache_value "${cache_file}" "CMAKE_HOME_DIRECTORY")"
    cached_build="$(cmake_cache_value "${cache_file}" "CMAKE_CACHEFILE_DIR")"

    if [[ -n "${cached_source}" && "${cached_source}" != "${ROOT_DIR}" ]]; then
        stale_cache=true
    fi

    if [[ -n "${cached_build}" && "${cached_build}" != "${build_dir}" ]]; then
        stale_cache=true
    fi

    if [[ "${stale_cache}" == true ]]; then
        echo "Removing stale CMake build directory: ${build_dir}"
        echo "  cached source: ${cached_source:-unknown}"
        echo "  current source: ${ROOT_DIR}"
        rm -rf "${build_dir}" || rm -rf "${build_dir}"
    fi
}

join_prefixes() {
    local IFS=';'
    echo "$*"
}

require_dir() {
    local path="$1"
    local message="$2"

    if [[ ! -d "${path}" ]]; then
        echo "${message}: ${path}" >&2
        exit 1
    fi
}

require_file() {
    local path="$1"
    local message="$2"

    if [[ ! -f "${path}" ]]; then
        echo "${message}: ${path}" >&2
        exit 1
    fi
}

latest_child_dir() {
    local root="$1"
    [[ -d "${root}" ]] || return 0
    find "${root}" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1
}

detect_android_sdk_root() {
    local candidate
    for candidate in \
        "${ANDROID_SDK_ROOT:-}" \
        "${ANDROID_HOME:-}" \
        "${HOME}/Library/Android/sdk" \
        "/opt/homebrew/share/android-commandlinetools" \
        "/usr/local/share/android-commandlinetools" \
        "/opt/android/sdk"; do
        if [[ -n "${candidate}" && -d "${candidate}" ]]; then
            echo "${candidate}"
            return
        fi
    done
}

detect_android_ndk_root() {
    local sdk_root="$1"
    local sdk_ndk
    local candidate
    sdk_ndk="$(latest_child_dir "${sdk_root}/ndk")"
    for candidate in \
        "${ANDROID_NDK_ROOT:-}" \
        "${ANDROID_NDK_HOME:-}" \
        "${CMAKE_ANDROID_NDK:-}" \
        "${sdk_ndk}" \
        "/opt/homebrew/share/android-ndk" \
        "/usr/local/share/android-ndk"; do
        if [[ -n "${candidate}" && -d "${candidate}" ]]; then
            echo "${candidate}"
            return
        fi
    done
}

resolve_wasm_qt_prefix() {
    local candidate
    for candidate in \
        "${WASM_QT_PREFIX}" \
        "${QT_ROOT}/wasm_multithread" \
        "${QT_ROOT}/wasm_singlethread" \
        "${QT_ROOT}/wasm_32" \
        "${QT_ROOT}/wasm"; do
        if [[ -n "${candidate}" && -d "${candidate}/lib/cmake/Qt6" ]]; then
            echo "${candidate}"
            return
        fi
    done
}

resolve_emscripten_toolchain() {
    local root
    local candidate
    for candidate in \
        "${IIHTMLBLOCK_EMSCRIPTEN_TOOLCHAIN_FILE:-}" \
        "${QT_CHAINLOAD_TOOLCHAIN_FILE:-}"; do
        if [[ -n "${candidate}" && -f "${candidate}" ]]; then
            echo "${candidate}"
            return
        fi
    done
    for root in \
        "${IIHTMLBLOCK_EMSDK_ROOT:-}" \
        "${EMSDK:-}" \
        "${HOME}/emsdk" \
        "${HOME}/.local/emsdk" \
        "/opt/emsdk"; do
        candidate="${root}/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake"
        if [[ -n "${root}" && -f "${candidate}" ]]; then
            echo "${candidate}"
            return
        fi
    done
}

verify_library() {
    local platform="$1"
    local install_prefix="$2"
    local extension
    case "${platform}" in
        macos|ios) extension="dylib" ;;
        android) extension="so" ;;
        wasm) extension="a" ;;
        *) return 1 ;;
    esac
    require_file "${install_prefix}/lib/libiiHtmlBlock.${extension}" \
        "iiHtmlBlock ${platform} shared library was not installed"
    require_file "${install_prefix}/lib/cmake/iiHtmlBlock/iiHtmlBlockConfig.cmake" \
        "iiHtmlBlock ${platform} CMake package was not installed"
    echo "Verified iiHtmlBlock ${platform}: ${install_prefix}/lib/libiiHtmlBlock.${extension}"
}

remove_legacy_include_dir() {
    local install_prefix="$1"
    local legacy_include_dir="${install_prefix}/include/iiHtmlBlock"

    if [[ -d "${legacy_include_dir}" && ( -f "${legacy_include_dir}/iiHtmlBlock.h" || -d "${legacy_include_dir}/Src" ) ]]; then
        echo "Removing legacy iiHtmlBlock include directory: ${legacy_include_dir}"
        rm -rf "${legacy_include_dir}"
    fi
}

install_macos() {
    require_dir "${MACOS_QT_PREFIX}/lib/cmake/Qt6" "Qt macOS package is required"
    require_dir "${IIXML_PREFIX}/lib/cmake/iiXml" "iiXml macOS package is required"

    remove_stale_build_dir "${MACOS_BUILD_DIR}"

    local cmake_prefix_path
    cmake_prefix_path="$(join_prefixes "${MACOS_QT_PREFIX}" "${IIXML_PREFIX}")"

    echo "Configuring iiHtmlBlock for macOS install prefix: ${MACOS_PREFIX}"
    cmake --fresh \
        -S "${ROOT_DIR}" \
        -B "${MACOS_BUILD_DIR}" \
        -DCMAKE_INSTALL_PREFIX="${MACOS_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${cmake_prefix_path}"

    echo "Building iiHtmlBlock for macOS in ${MACOS_BUILD_DIR}"
    cmake --build "${MACOS_BUILD_DIR}"

    echo "Running iiHtmlBlock macOS tests"
    ctest --test-dir "${MACOS_BUILD_DIR}" --output-on-failure

    remove_legacy_include_dir "${MACOS_PREFIX}"
    echo "Installing iiHtmlBlock macOS package into ${MACOS_PREFIX}"
    cmake --install "${MACOS_BUILD_DIR}" --prefix "${MACOS_PREFIX}"

    remove_legacy_include_dir "${MACOS_PLATFORM_PREFIX}"
    echo "Installing iiHtmlBlock macOS platform package into ${MACOS_PLATFORM_PREFIX}"
    cmake --install "${MACOS_BUILD_DIR}" --prefix "${MACOS_PLATFORM_PREFIX}"
    cmake -E copy_if_different \
        "${MACOS_BUILD_DIR}/iiHtmlBlockConfigVersionRoot.cmake" \
        "${PREFIX}/lib/cmake/iiHtmlBlock/iiHtmlBlockConfigVersion.cmake"
    verify_library macos "${MACOS_PREFIX}"
    verify_library macos "${MACOS_PLATFORM_PREFIX}"
}

install_ios() {
    require_dir "${IOS_QT_PREFIX}/lib/cmake/Qt6" "Qt iOS package is required"
    require_file "${IOS_TOOLCHAIN_FILE}" "Qt iOS toolchain file is required"
    require_dir "${IOS_IIXML_DIR}" "iiXml iOS package is required"

    remove_stale_build_dir "${IOS_BUILD_DIR}"

    local cmake_prefix_path
    cmake_prefix_path="$(join_prefixes "${IOS_QT_PREFIX}" "${MACOS_QT_PREFIX}" "${IOS_IIXML_PREFIX}")"

    echo "Configuring iiHtmlBlock for iOS install prefix: ${IOS_PREFIX}"
    cmake --fresh \
        -S "${ROOT_DIR}" \
        -B "${IOS_BUILD_DIR}" \
        -G Xcode \
        -DCMAKE_TOOLCHAIN_FILE="${IOS_TOOLCHAIN_FILE}" \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_SYSROOT=iphoneos \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_INSTALL_PREFIX="${IOS_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${cmake_prefix_path}" \
        -DiiXml_DIR="${IOS_IIXML_DIR}" \
        -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED=NO \
        -DCMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED=NO

    echo "Building iiHtmlBlock for iOS in ${IOS_BUILD_DIR}"
    cmake --build "${IOS_BUILD_DIR}" --config Release --target iiHtmlBlock

    remove_legacy_include_dir "${IOS_PREFIX}"
    echo "Installing iiHtmlBlock iOS platform package into ${IOS_PREFIX}"
    cmake --install "${IOS_BUILD_DIR}" --prefix "${IOS_PREFIX}" --config Release
    verify_library ios "${IOS_PREFIX}"
}

install_android() {
    local toolchain="${ANDROID_QT_PREFIX}/lib/cmake/Qt6/qt.toolchain.cmake"
    require_file "${toolchain}" "Qt Android toolchain file is required"
    require_dir "${ANDROID_IIXML_DIR}" "iiXml Android package is required"

    local sdk_root
    local ndk_root
    sdk_root="$(detect_android_sdk_root)"
    ndk_root="$(detect_android_ndk_root "${sdk_root}")"
    require_dir "${sdk_root}" "Android SDK root is required"
    require_dir "${ndk_root}" "Android NDK root is required"
    remove_stale_build_dir "${ANDROID_BUILD_DIR}"

    local cmake_prefix_path
    cmake_prefix_path="$(join_prefixes "${ANDROID_QT_PREFIX}" "${MACOS_QT_PREFIX}" "${ANDROID_IIXML_PREFIX}")"
    local android_env=(
        "ANDROID_SDK_ROOT=${sdk_root}"
        "ANDROID_HOME=${sdk_root}"
        "ANDROID_NDK_ROOT=${ndk_root}"
        "ANDROID_NDK_HOME=${ndk_root}"
    )

    echo "Configuring iiHtmlBlock for Android install prefix: ${ANDROID_PREFIX}"
    env "${android_env[@]}" cmake --fresh \
        -S "${ROOT_DIR}" \
        -B "${ANDROID_BUILD_DIR}" \
        -DCMAKE_TOOLCHAIN_FILE="${toolchain}" \
        -DQT_HOST_PATH="${MACOS_QT_PREFIX}" \
        -DANDROID_ABI=arm64-v8a \
        -DANDROID_PLATFORM=android-23 \
        -DANDROID_SDK_ROOT="${sdk_root}" \
        -DCMAKE_ANDROID_NDK="${ndk_root}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${ANDROID_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${cmake_prefix_path}" \
        -DiiXml_DIR="${ANDROID_IIXML_DIR}"

    env "${android_env[@]}" cmake --build "${ANDROID_BUILD_DIR}" --target iiHtmlBlock -j2
    remove_legacy_include_dir "${ANDROID_PREFIX}"
    env "${android_env[@]}" cmake --install "${ANDROID_BUILD_DIR}" --prefix "${ANDROID_PREFIX}"
    verify_library android "${ANDROID_PREFIX}"
}

install_wasm() {
    local qt_prefix
    local emscripten_toolchain
    qt_prefix="$(resolve_wasm_qt_prefix)"
    require_dir "${qt_prefix}/lib/cmake/Qt6" "Qt WASM package is required"
    emscripten_toolchain="$(resolve_emscripten_toolchain)"
    require_file "${emscripten_toolchain}" "Emscripten toolchain file is required"
    require_dir "${WASM_IIXML_DIR}" "iiXml WASM package is required"
    remove_stale_build_dir "${WASM_BUILD_DIR}"

    local cmake_prefix_path
    cmake_prefix_path="$(join_prefixes "${qt_prefix}" "${MACOS_QT_PREFIX}" "${WASM_IIXML_PREFIX}")"

    echo "Configuring iiHtmlBlock for WASM install prefix: ${WASM_PREFIX}"
    cmake --fresh \
        -S "${ROOT_DIR}" \
        -B "${WASM_BUILD_DIR}" \
        -DCMAKE_TOOLCHAIN_FILE="${qt_prefix}/lib/cmake/Qt6/qt.toolchain.cmake" \
        -DQT_CHAINLOAD_TOOLCHAIN_FILE="${emscripten_toolchain}" \
        -DQT_HOST_PATH="${MACOS_QT_PREFIX}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${WASM_PREFIX}" \
        -DCMAKE_PREFIX_PATH="${cmake_prefix_path}" \
        -DiiXml_DIR="${WASM_IIXML_DIR}"

    cmake --build "${WASM_BUILD_DIR}" --target iiHtmlBlock -j2
    remove_legacy_include_dir "${WASM_PREFIX}"
    rm -f "${WASM_PREFIX}/lib/libiiHtmlBlock.so"
    cmake --install "${WASM_BUILD_DIR}" --prefix "${WASM_PREFIX}"
    verify_library wasm "${WASM_PREFIX}"
}

run_platform_install() {
    local platform="$1"

    case "${platform}" in
        macos)
            install_macos
            ;;
        ios)
            install_ios
            ;;
        android)
            install_android
            ;;
        wasm)
            install_wasm
            ;;
        "")
            ;;
        *)
            echo "Unsupported iiHtmlBlock install platform: ${platform}" >&2
            echo "Supported platforms: macos, ios, android, wasm" >&2
            exit 1
            ;;
    esac
}

IFS=',;' read -ra requested_platforms <<< "${INSTALL_PLATFORMS}"

echo "Installing iiHtmlBlock for platforms: ${INSTALL_PLATFORMS}"
for platform in "${requested_platforms[@]}"; do
    platform="$(echo "${platform}" | xargs)"
    run_platform_install "${platform}"
done

echo "iiHtmlBlock installed for platforms: ${INSTALL_PLATFORMS}."
