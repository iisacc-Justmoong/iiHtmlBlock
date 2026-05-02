# 설치

`install.sh`는 iiHtmlBlock을 `~/.local/iiHtmlBlock` 아래에 설치한다. 설치 위치는
고정이며 다른 prefix를 받지 않는다.

## 전제 조건

- Qt 6.8.3은 `~/Qt/6.8.3/macos` 아래에 설치되어 있어야 한다.
- iiXml은 `~/.local/iiXml` 아래에 설치되어 있어야 한다.

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

find_package(iiHtmlBlock CONFIG REQUIRED)

add_executable(app main.cpp)
target_link_libraries(app PRIVATE iiHtmlBlock::iiHtmlBlock)
```

`iiHtmlBlockConfig.cmake`는 자기 설치 prefix의 sibling `../iiXml`과 기본
`~/.local/iiXml`을 먼저 탐색 경로에 추가한다. 따라서 표준 설치 레이아웃에서는
소비 프로젝트가 iiXml prefix를 별도로 추가하지 않아도 `find_package(iiHtmlBlock)`만으로
`iiXml::iiXml` 의존성이 함께 해결된다.

config 파일을 직접 포함하는 방식도 지원한다.

```cmake
include("$ENV{HOME}/.local/iiHtmlBlock/lib/cmake/iiHtmlBlock/iiHtmlBlockConfig.cmake")

add_executable(app main.cpp)
target_link_libraries(app PRIVATE iiHtmlBlock::iiHtmlBlock)
```

Qt 또는 iiXml을 기본 위치가 아닌 곳에 설치했다면 해당 prefix는 소비 프로젝트에서
명시적으로 `CMAKE_PREFIX_PATH`에 추가해야 한다.

코드에서는 다음처럼 단일 umbrella 헤더를 사용할 수 있다.

```cpp
#include <iiHtmlBlock>

iiHtmlBlock::GetHTML html;
```

저장소의 `umbrella_header_test`도 이 angle-bracket include 형태를 직접 컴파일해
공개 헤더 진입점과 `iiHtmlBlock` 네임스페이스 사용을 검증한다.

`iiHtmlBlock::iiHtmlBlock` imported target은 include path, Qt `Core`, iiXml 링크
의존성을 함께 제공한다.
