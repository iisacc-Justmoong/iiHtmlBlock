# iiHtmlBlock

`iiHtmlBlock`은 `iiXml` 입력을 HTML 블록으로 변환하고 조작하기 위한 Qt6.8.3/C++20
공유 라이브러리이다. 공개 C++ API는 `iiHtmlBlock` 네임스페이스 아래에 둔다.

## GetTagInfo

`Src/Parser/GetTagInfo.*`는 XML 문자열을 받아 `iiXml::Parser::TagParser`와 호환되는
방식으로 첫 루트 태그의 값과 필드를 내부 상태로 저장한다. 전체 태그 계층은
`GetTags()`/`GetRoot()`로 조회하고, 첫 루트 태그의 값과 필드는 `GetValue()`와
`GetFields()`로 조회한다. 교차 종료처럼 트리만으로 표현하기 어려운 iiXml 구조는
`GetRanges()`의 원본 offset range로 보존한다. 본문 태그 앞의 XML 선언과 DOCTYPE은
태그 range가 아니므로 파싱 전에 제거한다.

상세 내용은 `Docs/get_tag_info.md`를 참고한다.

## GetHTML

`Src/Parser/GetHTML.*`는 `iiXml`을 비롯한 XML 문자열을 받아 HTML 태그 문자열로
판정한다. 태그명 변환은 하지 않으며, `paragraph`, `XML`, `CustomTag` 같은 태그도
그 이름 그대로 커스텀 HTML 태그로 반환한다. 알 수 없는 태그도
입력 이름 그대로 유지한다. 예를 들어 `unknownName`은 `<unknownName>...</unknownName>`,
`OtherWidget`은 `<OtherWidget>...</OtherWidget>`로 반환한다.

상세 내용은 `Docs/get_html.md`를 참고한다.

## iiXmlToHTML

`Src/Modifier/iiXmlToHTML.*`는 `GetHTML`의 판정 규칙을 사용해 iiXml/XML 입력을 HTML
문자열로 변환한다. 태그명은 변환하지 않고 입력 이름 그대로 유지한다.

상세 내용은 `Docs/iixml_to_html.md`를 참고한다.

## DivideBlock

`Src/Modifier/DivideBlock.*`는 `GetTagInfo`가 파싱한 태그 range를 기준으로 각 요소가
블록 단위인지 판정한다. 기본 HTML 블록 태그를 인식하고, `style="display: block"`이나
`display=block` 같은 명시적 display 값은 기본 태그 판정보다 우선한다. 알 수 없는
커스텀 태그는 명시적 display 값이 있을 때만 블록으로 본다.

상세 내용은 `Docs/divide_block.md`를 참고한다.

## DeleteBlock

`Src/Modifier/DeleteBlock.*`는 `DivideBlock`으로 나뉜 블록 목록에서 지정한 블록을
원본 HTML/iiXml 문자열에서 제거한다. 삭제 후 남은 문서를 다시 파싱해 현재 블록 목록을
갱신하고, 삭제된 블록 스냅샷은 `GetDeletedBlocks()`로 조회할 수 있다.

상세 내용은 `Docs/delete_block.md`를 참고한다.

## CombineBlock

`Src/Modifier/CombineBlock.*`는 `DivideBlock`으로 나뉜 블록 목록에서 여러 블록을
선택하고, 선택 묶음을 하나의 논리 블록으로 병합 취급한다. 병합은 원본 HTML을
재작성하지 않고 선택 인덱스와 선택된 블록 스냅샷을 `CombinedBlock`으로 저장한다.

상세 내용은 `Docs/combine_block.md`를 참고한다.

## FlattenBlock

`Src/Modifier/FlattenBlock.*`는 문서의 모든 블록을 유지한 채 하나의 상위 그룹 블록
레이어로 묶는다. 각 블록은 개별 `ElementInfo`로 남아 있으면서, 동시에 단일
`LayerBlock` 그룹에 포함된 블록으로 취급된다.

상세 내용은 `Docs/flatten_block.md`를 참고한다.

## 설치

`install.sh`는 iiXml과 같은 방식으로 빌드, 테스트, 설치를 한 번에 수행하며
iiHtmlBlock을 `~/.local/iiHtmlBlock` 아래에 설치한다.
설치 후 소비 프로젝트는 일반 설치 레이아웃에서 `iiXml` prefix를 별도로 추가하지 않고
`find_package(iiHtmlBlock CONFIG REQUIRED)` 또는 설치 config 파일 직접 `include()`로
가져올 수 있다.

상세 내용은 `Docs/install.md`를 참고한다.

## 사용 예시

```cpp
#include <iiHtmlBlock>

iiHtmlBlock::GetHTML html;
iiHtmlBlock::DivideBlock divider;
iiHtmlBlock::DeleteBlock deleter;
```

실행 가능한 예제는 `Example/ParsedXmlHtmlExample.cpp`에 있으며, 파싱된 XML range,
HTML 변환 결과, 블록 분할, 블록 삭제, 선택 병합, 전체 레이어링 흐름을 함께 보여준다.
상세 내용은 `Docs/examples.md`를 참고한다.

## 검증

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```
