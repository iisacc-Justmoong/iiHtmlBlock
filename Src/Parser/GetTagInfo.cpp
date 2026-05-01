#include "GetTagInfo.h"

#include <iiXml/Src/Parser/TagParser.h>

#include <QByteArray>
#include <QDebug>

#include <cstddef>
#include <exception>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace {

GetTagInfo::FieldType ConvertFieldType(iiXml::elements::inline_property_type type) {
    switch (type) {
        case iiXml::elements::inline_property_type::string_type:
            return GetTagInfo::FieldType::String;
        case iiXml::elements::inline_property_type::int_type:
            return GetTagInfo::FieldType::Int;
        case iiXml::elements::inline_property_type::float_type:
            return GetTagInfo::FieldType::Float;
        case iiXml::elements::inline_property_type::bool_type:
            return GetTagInfo::FieldType::Bool;
    }

    return GetTagInfo::FieldType::String;
}

std::string Slice(std::string_view source, std::size_t begin, std::size_t end) {
    if (begin > end || end > source.size()) {
        return {};
    }

    return std::string(source.substr(begin, end - begin));
}

std::vector<GetTagInfo::FieldInfo> ConvertFields(
    std::string_view xml,
    const std::vector<iiXml::parser::tag_field>& fields
) {
    std::vector<GetTagInfo::FieldInfo> converted;
    converted.reserve(fields.size());

    for (const iiXml::parser::tag_field& field : fields) {
        converted.push_back(GetTagInfo::FieldInfo{
            field.name,
            field.has_value ? Slice(xml, field.value_begin, field.value_end) : std::string{},
            field.has_value,
            ConvertFieldType(field.value_type),
            field.type_declared
        });
    }

    return converted;
}

GetTagInfo::TagInfo ConvertNode(std::string_view xml, const iiXml::parser::tag_node& node) {
    GetTagInfo::TagInfo converted{
        node.range.tag_name,
        Slice(xml, node.range.value_begin, node.range.value_end),
        Slice(xml, node.range.raw_begin, node.range.raw_end),
        ConvertFields(xml, node.fields),
        {}
    };

    converted.children.reserve(node.children.size());
    for (const iiXml::parser::tag_node& child : node.children) {
        converted.children.push_back(ConvertNode(xml, child));
    }

    return converted;
}

std::string ToUtf8String(const QString& value) {
    const QByteArray utf8 = value.toUtf8();
    return std::string(utf8.constData(), static_cast<std::size_t>(utf8.size()));
}

QString FromUtf8String(const std::string& value) {
    return QString::fromUtf8(value.data(), static_cast<qsizetype>(value.size()));
}

} // namespace

GetTagInfo::GetTagInfo(QObject* parent)
    : QObject(parent) {
    qDebug() << "GetTagInfo::GetTagInfo constructed";
}

bool GetTagInfo::Parse(const char* xml) {
    if (xml == nullptr) {
        Clear();
        error_ = "xml input is null";
        qDebug() << "GetTagInfo::Parse failed"
                 << "reason=" << QString::fromStdString(error_);
        return false;
    }

    return Parse(std::string_view(xml));
}

bool GetTagInfo::Parse(std::string_view xml) {
    qDebug() << "GetTagInfo::Parse begin"
             << "input_size=" << xml.size();
    try {
        Clear();

        if (!StoreParsedTags(xml)) {
            qDebug() << "GetTagInfo::Parse failed"
                     << "reason=" << QString::fromStdString(error_);
            return false;
        }

        qDebug() << "GetTagInfo::Parse parsed"
                 << "tag=" << QString::fromStdString(tag_name_)
                 << "value_size=" << value_.size()
                 << "field_count=" << fields_.size();
        return true;
    } catch (const std::exception& exception) {
        Clear();
        error_ = std::string("tag info parse exception: ") + exception.what();
        qDebug() << "GetTagInfo::Parse exception"
                 << "what=" << exception.what();
        return false;
    } catch (...) {
        Clear();
        error_ = "tag info parse exception: unknown";
        qDebug() << "GetTagInfo::Parse exception"
                 << "what=unknown";
        return false;
    }
}

bool GetTagInfo::Parse(const QString& xml) {
    const std::string bytes = ToUtf8String(xml);
    return Parse(std::string_view(bytes.data(), bytes.size()));
}

const std::vector<GetTagInfo::TagInfo>& GetTagInfo::GetTags() const {
    return tags_;
}

const GetTagInfo::TagInfo* GetTagInfo::GetRoot() const {
    if (tags_.empty()) {
        return nullptr;
    }

    return &tags_.front();
}

const std::string& GetTagInfo::GetTagName() const {
    return tag_name_;
}

const std::string& GetTagInfo::GetValue() const {
    return value_;
}

const std::string& GetTagInfo::GetRaw() const {
    return raw_;
}

const std::vector<GetTagInfo::FieldInfo>& GetTagInfo::GetFields() const {
    return fields_;
}

const std::string& GetTagInfo::GetError() const {
    return error_;
}

void GetTagInfo::ParseXml(const QString& xml) {
    if (Parse(xml)) {
        emit Parsed(FromUtf8String(tag_name_), FromUtf8String(value_));
        return;
    }

    emit ParseFailed(FromUtf8String(error_));
}

bool GetTagInfo::StoreParsedTags(std::string_view xml) {
    const iiXml::parser::tag_parser parser;
    const std::optional<std::vector<iiXml::parser::tag_node>> parsed = parser.parse_all(xml);
    if (!parsed.has_value()) {
        error_ = "iiXml tag parser rejected input";
        return false;
    }

    if (parsed->empty()) {
        error_ = "iiXml tag parser returned no tag";
        return false;
    }

    tags_.reserve(parsed->size());
    for (const iiXml::parser::tag_node& node : *parsed) {
        tags_.push_back(ConvertNode(xml, node));
    }

    const TagInfo& root = tags_.front();
    tag_name_ = root.tag_name;
    value_ = root.value;
    raw_ = root.raw;
    fields_ = root.fields;
    error_.clear();
    return true;
}

void GetTagInfo::Clear() {
    tags_.clear();
    tag_name_.clear();
    value_.clear();
    raw_.clear();
    fields_.clear();
    error_.clear();
}
