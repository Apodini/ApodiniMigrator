//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftProtobuf
import SwiftProtobufPluginLibrary

extension FieldDescriptor: FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        type
    }

    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? {
        if let message = messageType,
           let map = message.mapKeyAndValue {
            return (map.key, map.value)
        }

        return nil
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        switch protoType {
        case .message,
             .group:
            return namer.fullName(message: messageType)
        case .enum:
            return namer.fullName(enum: enumType)
        default:
            return nil
        }
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        guard let enumType = enumType else {
            return nil
        }

        if let caseValue = caseValue {
            for value in enumType.values where value.name == caseValue {
                return namer.dottedRelativeName(enumValue: value)
            }
            return nil
        }

        return namer.dottedRelativeName(enumValue: enumType.defaultValue)
    }
}
