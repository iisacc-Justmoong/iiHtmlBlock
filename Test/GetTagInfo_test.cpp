#include "Src/Parser/GetTagInfo.h"

#include <cassert>
#include <string>

namespace {

const GetTagInfo::FieldInfo* FindField(
    const std::vector<GetTagInfo::FieldInfo>& fields,
    const std::string& name
) {
    for (const GetTagInfo::FieldInfo& field : fields) {
        if (field.name == name) {
            return &field;
        }
    }

    return nullptr;
}

void ParsesRootValueAndFields() {
    const std::string xml =
        "<?xml version=\"1.0\"?>\n"
        "<!DOCTYPE XML>\n"
        "<XML id=\"main\" order=7 visible=true ratio=1.5><body>Hello</body></XML>";

    GetTagInfo info;
    assert(info.Parse(xml));
    assert(info.GetError().empty());
    assert(info.GetTagName() == "XML");
    assert(info.GetValue() == "<body>Hello</body>");
    assert(info.GetRaw() == "<XML id=\"main\" order=7 visible=true ratio=1.5><body>Hello</body></XML>");

    const GetTagInfo::TagInfo* root = info.GetRoot();
    assert(root != nullptr);
    assert(root->children.size() == 1);
    assert(root->children.front().tag_name == "body");
    assert(root->children.front().value == "Hello");

    const std::vector<GetTagInfo::FieldInfo>& fields = info.GetFields();
    assert(fields.size() == 4);

    const GetTagInfo::FieldInfo* id = FindField(fields, "id");
    assert(id != nullptr);
    assert(id->has_value);
    assert(id->value == "main");
    assert(id->type == GetTagInfo::FieldType::String);

    const GetTagInfo::FieldInfo* order = FindField(fields, "order");
    assert(order != nullptr);
    assert(order->has_value);
    assert(order->value == "7");
    assert(order->type == GetTagInfo::FieldType::Int);

    const GetTagInfo::FieldInfo* visible = FindField(fields, "visible");
    assert(visible != nullptr);
    assert(visible->has_value);
    assert(visible->value == "true");
    assert(visible->type == GetTagInfo::FieldType::Bool);

    const GetTagInfo::FieldInfo* ratio = FindField(fields, "ratio");
    assert(ratio != nullptr);
    assert(ratio->has_value);
    assert(ratio->value == "1.5");
    assert(ratio->type == GetTagInfo::FieldType::Float);
}

void ClearsStoredStateOnFailure() {
    GetTagInfo info;
    assert(info.Parse("<XML id=\"main\">value</XML>"));
    assert(!info.GetTags().empty());

    assert(!info.Parse("<XML id=\"main\">value"));
    assert(info.GetTags().empty());
    assert(info.GetRoot() == nullptr);
    assert(info.GetTagName().empty());
    assert(info.GetValue().empty());
    assert(!info.GetError().empty());
}

} // namespace

int main() {
    ParsesRootValueAndFields();
    ClearsStoredStateOnFailure();
    return 0;
}
