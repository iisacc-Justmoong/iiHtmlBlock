# iiHtmlBlock

`iiHtmlBlock`은 `iiXml` 입력을 HTML 블록으로 변환하고 조작하기 위한 Qt6.8.3/C++20
공유 라이브러리이다.

## GetTagInfo

`Src/Parser/GetTagInfo.*`는 XML 문자열을 받아 `iiXml::parser::tag_parser`와 호환되는
방식으로 첫 루트 태그의 값과 필드를 내부 상태로 저장한다. 전체 태그 계층은
`GetTags()`/`GetRoot()`로 조회하고, 첫 루트 태그의 값과 필드는 `GetValue()`와
`GetFields()`로 조회한다. 교차 종료처럼 트리만으로 표현하기 어려운 iiXml 구조는
`GetRanges()`의 원본 offset range로 보존한다.

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

## 검증

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build --output-on-failure
```
