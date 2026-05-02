#include <iiHtmlBlock>

#include <cassert>

int main() {
    GetHTML html;
    GetTagInfo info;
    iiXmlToHTML converter;
    DivideBlock divider;
    CombineBlock combiner;
    FlattenBlock flattener;

    assert(html.GetHTMLText().empty());
    assert(info.GetTags().empty());
    assert(converter.GetHTMLText().empty());
    assert(divider.GetElements().empty());
    assert(combiner.GetBlocks().empty());
    assert(!flattener.HasLayer());
    return 0;
}
