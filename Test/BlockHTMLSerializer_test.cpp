#include "Src/Modifier/BlockHTMLSerializer.h"
#include "Src/Modifier/CombineBlock.h"
#include "Src/Modifier/DivideBlock.h"

#include <cassert>
#include <string>
#include <vector>

using namespace iiHtmlBlock;

namespace {

std::vector<DivideBlock::ElementInfo> ParseBlocks() {
    DivideBlock divider;
    assert(divider.Parse(
        "<XML>"
        "<section>"
        "<p>One</p>"
        "<p>Two</p>"
        "<span>tail</span>"
        "</section>"
        "</XML>"
    ));

    return divider.GetBlockElements();
}

CombineBlock::CombinedBlock CombineParagraphs(const std::vector<DivideBlock::ElementInfo>& blocks) {
    CombineBlock combiner;
    combiner.SetBlocks(blocks);
    assert(combiner.SelectRange(1, 2));
    assert(combiner.CombineSelected());
    assert(combiner.GetCombinedBlocks().size() == 1);
    return combiner.GetCombinedBlocks().front();
}

void SerializesSplitBlocksWithoutDuplicatingNestedRanges() {
    const std::vector<DivideBlock::ElementInfo> blocks = ParseBlocks();

    BlockHTMLSerializer serializer;
    assert(serializer.SerializeBlocks(blocks));
    assert(serializer.GetError().empty());
    assert(serializer.GetHTMLText() ==
        "<section><p>One</p><p>Two</p><span>tail</span></section>");
}

void SerializesCombinedBlocksAsLogicalFragments() {
    const std::vector<DivideBlock::ElementInfo> blocks = ParseBlocks();
    const CombineBlock::CombinedBlock combined = CombineParagraphs(blocks);

    BlockHTMLSerializer serializer;
    assert(serializer.SerializeCombinedBlocks({combined}));
    assert(serializer.GetError().empty());
    assert(serializer.GetHTMLText() == "<p>One</p><p>Two</p>");
}

void SerializesMergedBlocksWithCombinedGroupsApplied() {
    const std::vector<DivideBlock::ElementInfo> blocks = ParseBlocks();
    const CombineBlock::CombinedBlock combined = CombineParagraphs(blocks);

    BlockHTMLSerializer serializer;
    assert(serializer.SerializeMergedBlocks(blocks, {combined}));
    assert(serializer.GetError().empty());
    assert(serializer.GetHTMLText() ==
        "<section><p>One</p><p>Two</p><span>tail</span></section>");
}

void SerializesSiblingBlocksInDocumentOrder() {
    DivideBlock divider;
    assert(divider.Parse("<XML><p>One</p><p>Two</p></XML>"));

    BlockHTMLSerializer serializer;
    assert(serializer.SerializeBlocks(divider.GetBlockElements()));
    assert(serializer.GetHTMLText() == "<p>One</p><p>Two</p>");
}

void RejectsCombinedSourceIndexOutsideBlocks() {
    const std::vector<DivideBlock::ElementInfo> blocks = ParseBlocks();
    CombineBlock::CombinedBlock combined = CombineParagraphs(blocks);
    combined.source_indexes.push_back(99);

    BlockHTMLSerializer serializer;
    assert(!serializer.SerializeMergedBlocks(blocks, {combined}));
    assert(serializer.GetHTMLText().empty());
    assert(!serializer.GetError().empty());
}

} // namespace

int main() {
    SerializesSplitBlocksWithoutDuplicatingNestedRanges();
    SerializesCombinedBlocksAsLogicalFragments();
    SerializesMergedBlocksWithCombinedGroupsApplied();
    SerializesSiblingBlocksInDocumentOrder();
    RejectsCombinedSourceIndexOutsideBlocks();
    return 0;
}
