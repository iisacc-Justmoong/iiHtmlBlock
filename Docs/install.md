# 설치

`install.sh`는 iiHtmlBlock을 `~/.local/iiHtmlBlock` 아래에 설치한다. 설치 위치는
고정이며 다른 prefix를 받지 않는다.

## 전제 조건

- Qt 6.8.3은 `~/Qt/6.8.3/macos` 아래에 설치되어 있어야 한다.
- iiXml은 `~/.local/iiXml` 아래에 설치되어 있어야 한다. iiXml이 기존 `~/.local`
  prefix에 설치되어 있어도 CMakeLists의 기존 검색 경로는 유지한다.

## 실행

```sh
./install.sh
```

스크립트는 항상 루트의 `build/` 디렉터리를 사용한다.

1. `cmake -S . -B build`로 구성한다.
2. `cmake --build build`로 빌드한다.
3. `ctest --test-dir build --output-on-failure`로 테스트를 실행한다.
4. 이전 설치의 `~/.local/iiHtmlBlock/include/iiHtmlBlock/` 디렉터리가 있으면 제거한다.
5. `cmake --install build --prefix ~/.local/iiHtmlBlock`로 설치한다.

## 설치 결과

- `~/.local/iiHtmlBlock/lib`: iiHtmlBlock 공유 라이브러리
- `~/.local/iiHtmlBlock/include/iiHtmlBlock`: `#include <iiHtmlBlock>`용 umbrella 헤더
- `~/.local/iiHtmlBlock/include/iiHtmlBlock.h`: 기존 파일명 기반 공개 헤더
- `~/.local/iiHtmlBlock/include/Src`: 모듈별 공개 헤더
- `~/.local/iiHtmlBlock/lib/cmake/iiHtmlBlock`: `iiHtmlBlockConfig.cmake`와 export target 파일

## CMake 사용 예

설치 후 다른 Qt 프로젝트에서는 다음처럼 가져온다.

```cmake
list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/.local/iiHtmlBlock")
list(PREPEND CMAKE_PREFIX_PATH "$ENV{HOME}/.local/iiXml")

find_package(iiHtmlBlock CONFIG REQUIRED)

add_executable(app main.cpp)
target_link_libraries(app PRIVATE iiHtmlBlock::iiHtmlBlock)
```

코드에서는 다음처럼 단일 umbrella 헤더를 사용할 수 있다.

```cpp
#include <iiHtmlBlock>
```

저장소의 `umbrella_header_test`도 이 angle-bracket include 형태를 직접 컴파일해
공개 헤더 진입점을 검증한다.

`iiHtmlBlock::iiHtmlBlock` imported target은 include path, Qt `Core`, iiXml 링크
의존성을 함께 제공한다.
