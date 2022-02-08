//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import SwiftProtobufPluginLibrary

extension FieldDescriptorLike {
    // swiftlint:disable:next cyclomatic_complexity
    func swiftType(namer: SwiftProtobufNamer) -> String {
        if let (key, value) = mapKeyAndValueDescription {
            let keyType = key.swiftType(namer: namer)
            let valueType = value.swiftType(namer: namer)
            return "Dictionary<" + keyType + "," + valueType + ">"
        }

        let result: String
        switch protoType {
        case .double: result = "Double"
        case .float: result = "Float"
        case .int64: result = "Int64"
        case .uint64: result = "UInt64"
        case .int32: result = "Int32"
        case .fixed64: result = "UInt64"
        case .fixed32: result = "UInt32"
        case .bool: result = "Bool"
        case .string: result = "String"
        case .group: result = retrieveFullName(namer: namer).unsafelyUnwrapped
        case .message: result = retrieveFullName(namer: namer).unsafelyUnwrapped
        case .bytes: result = "Data"
        case .uint32: result = "UInt32"
        case .enum: result = retrieveFullName(namer: namer).unsafelyUnwrapped
        case .sfixed32: result = "Int32"
        case .sfixed64: result = "Int64"
        case .sint32: result = "Int32"
        case .sint64: result = "Int64"
        }

        if label == .repeated {
            return "[\(result)]"
        }
        return result
    }

    func deriveProtoGenericType() -> String { // swiftlint:disable:this cyclomatic_complexity
        precondition(!isMap)

        switch protoType {
        case .double: return "Double"
        case .float: return "Float"
        case .int64: return "Int64"
        case .uint64: return "UInt64"
        case .int32: return "Int32"
        case .fixed64: return "Fixed64"
        case .fixed32: return "Fixed32"
        case .bool: return "Bool"
        case .string: return "String"
        case .group: return "Group"
        case .message: return "Message"
        case .bytes: return "Bytes"
        case .uint32: return "UInt32"
        case .enum: return "Enum"
        case .sfixed32: return "SFixed32"
        case .sfixed64: return "SFixed64"
        case .sint32: return "SInt32"
        case .sint64: return "SInt64"
        }
    }

    func swiftStorageType(namer: SwiftProtobufNamer) -> String {
        let swiftType = self.swiftType(namer: namer)
        switch label {
        case .repeated:
            return swiftType
        case .optional, .required:
            // oneOfs aren't supported by us
            // guard realOneof == nil else {
            //     return swiftType
            // }
            if hasPresence {
                return "\(swiftType)?"
            } else {
                return swiftType
            }
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func swiftDefaultValue(namer: SwiftProtobufNamer) -> String {
        if isMap {
            return "[:]"
        }
        if label == .repeated {
            return "[]"
        }

        if let defaultValue = explicitDefaultValue {
            switch protoType {
            case .double:
                switch defaultValue {
                case "inf": return "Double.infinity"
                case "-inf": return "-Double.infinity"
                case "nan": return "Double.nan"
                default: return defaultValue
                }
            case .float:
                switch defaultValue {
                case "inf": return "Float.infinity"
                case "-inf": return "-Float.infinity"
                case "nan": return "Float.nan"
                default: return defaultValue
                }
            case .string:
                return stringToEscapedStringLiteral(defaultValue)
            case .bytes:
                return escapedToDataLiteral(defaultValue)
            case .enum:
                return enumDefaultValueDottedRelativeName(namer: namer, for: defaultValue).unsafelyUnwrapped
            default:
                return defaultValue
            }
        }

        switch protoType {
        case .bool: return "false"
        case .string: return "String()"
        case .bytes: return "Data()"
        case .group, .message:
            return retrieveFullName(namer: namer).unsafelyUnwrapped + "()"
        case .enum:
            return enumDefaultValueDottedRelativeName(namer: namer, for: nil).unsafelyUnwrapped
        default:
            return "0"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    func traitsType(namer: SwiftProtobufNamer) -> String {
        if let (key, value) = mapKeyAndValueDescription {
            let keyTraits = key.traitsType(namer: namer)
            let valueTraits = value.traitsType(namer: namer)
            switch value.protoType {
            case .message:  // Map's can't have a group as the value
                return "\(namer.swiftProtobufModuleName)._ProtobufMessageMap<\(keyTraits),\(valueTraits)>"
            case .enum:
                return "\(namer.swiftProtobufModuleName)._ProtobufEnumMap<\(keyTraits),\(valueTraits)>"
            default:
                return "\(namer.swiftProtobufModuleName)._ProtobufMap<\(keyTraits),\(valueTraits)>"
            }
        }
        switch protoType {
        case .double: return "\(namer.swiftProtobufModuleName).ProtobufDouble"
        case .float: return "\(namer.swiftProtobufModuleName).ProtobufFloat"
        case .int64: return "\(namer.swiftProtobufModuleName).ProtobufInt64"
        case .uint64: return "\(namer.swiftProtobufModuleName).ProtobufUInt64"
        case .int32: return "\(namer.swiftProtobufModuleName).ProtobufInt32"
        case .fixed64: return "\(namer.swiftProtobufModuleName).ProtobufFixed64"
        case .fixed32: return "\(namer.swiftProtobufModuleName).ProtobufFixed32"
        case .bool: return "\(namer.swiftProtobufModuleName).ProtobufBool"
        case .string: return "\(namer.swiftProtobufModuleName).ProtobufString"
        case .group, .message: return retrieveFullName(namer: namer).unsafelyUnwrapped
        case .bytes: return "\(namer.swiftProtobufModuleName).ProtobufBytes"
        case .uint32: return "\(namer.swiftProtobufModuleName).ProtobufUInt32"
        case .enum: return retrieveFullName(namer: namer).unsafelyUnwrapped
        case .sfixed32: return "\(namer.swiftProtobufModuleName).ProtobufSFixed32"
        case .sfixed64: return "\(namer.swiftProtobufModuleName).ProtobufSFixed64"
        case .sint32: return "\(namer.swiftProtobufModuleName).ProtobufSInt32"
        case .sint64: return "\(namer.swiftProtobufModuleName).ProtobufSInt64"
        }
    }
}


// swiftlint:disable identifier_name

/// The protoc parser emits byte literals using an escaped C convention.
/// Fortunately, it uses only a limited subset of the C escapse:
///  \n\r\t\\\'\" and three-digit octal escapes but nothing else.
// swiftlint:disable:next cyclomatic_complexity
func escapedToDataLiteral(_ s: String) -> String {
    if s.isEmpty {
        return "Data()"
    }
    var out = "Data(["
    var separator = ""
    var escape = false
    var octal = 0
    var octalAccumulator = 0
    for c in s.utf8 {
        if octal > 0 {
            precondition(c >= 48 && c < 56)
            octalAccumulator <<= 3
            octalAccumulator |= (Int(c) - 48)
            octal -= 1
            if octal == 0 {
                out += separator
                out += "\(octalAccumulator)"
                separator = ", "
            }
        } else if escape {
            switch c {
            case 110:
                out += separator
                out += "10"
                separator = ", "
            case 114:
                out += separator
                out += "13"
                separator = ", "
            case 116:
                out += separator
                out += "9"
                separator = ", "
            case 48..<56:
                octal = 2 // 2 more digits
                octalAccumulator = Int(c) - 48
            default:
                out += separator
                out += "\(c)"
                separator = ", "
            }
            escape = false
        } else if c == 92 { // backslash
            escape = true
        } else {
            out += separator
            out += "\(c)"
            separator = ", "
        }
    }
    out += "])"
    return out
}

/// Generate a Swift string literal suitable for including in
/// source code
private let hexdigits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]

func stringToEscapedStringLiteral(_ s: String) -> String {
    if s.isEmpty {
        return "String()"
    }
    var out = "\""
    for c in s.unicodeScalars {
        switch c.value {
        case 0:
            out += "\\0"
        case 1..<32:
            let n = Int(c.value)
            let hex1 = hexdigits[(n >> 4) & 15]
            let hex2 = hexdigits[n & 15]
            out += "\\u{" + hex1 + hex2 + "}"
        case 34:
            out += "\\\""
        case 92:
            out += "\\\\"
        default:
            out.append(String(c))
        }
    }
    return out + "\""
}
