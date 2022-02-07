//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobuf
import SwiftProtobufPluginLibrary

extension TypeProperty: FieldDescriptorLike {
    var protoType: Google_Protobuf_FieldDescriptorProto.TypeEnum {
        type.protoType
    }

    var label: Google_Protobuf_FieldDescriptorProto.Label {
        if type.isRepeated {
            return .repeated
        } else if type.isOptional || necessity == .optional {
            return .optional
        } else {
            return .required
        }
    }

    var explicitDefaultValue: String? {
        // users can't provide explicit default value via the TypeInfo framework
        nil
    }

    var isMap: Bool {
        type.isMap
    }

    var hasPresence: Bool {
        type.isOptional || necessity == .optional
    }

    var mapKeyAndValueDescription: (key: FieldDescriptorLike, value: FieldDescriptorLike)? {
        type.mapKeyAndValueDescription
    }

    func retrieveFullName(namer: SwiftProtobufNamer) -> String? {
        type.retrieveFullName(namer: namer)
    }

    func enumDefaultValueDottedRelativeName(namer: SwiftProtobufNamer, for caseValue: String?) -> String? {
        type.enumDefaultValueDottedRelativeName(namer: namer, for: caseValue)
    }
}
