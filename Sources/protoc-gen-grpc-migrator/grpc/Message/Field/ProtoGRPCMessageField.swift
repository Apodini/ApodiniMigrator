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

struct ProtoGRPCMessageField: SomeGRPCMessageField {
    let descriptor: FieldDescriptor

    let hasFieldPresence: Bool

    let name: String
    let privateName: String
    let storedProperty: String
    let propertyHasName: String
    let funcClearName: String

    let type: Google_Protobuf_FieldDescriptorProto.TypeEnum

    let typeName: String
    let storageType: String
    let defaultValue: String
    let traitsType: String
    let protoGenericType: String

    let sourceCodeComments: String?

    let number: Int

    var fieldMapNames: String { // TODO what kind of monstrosity is this?
        // Protobuf Text uses the unqualified group name for the field
        // name instead of the field name provided by protoc.  As far
        // as I can tell, no one uses the fieldName provided by protoc,
        // so let's just put the field name that Protobuf Text
        // actually uses here.
        let protoName: String
        if descriptor.type == .group {
            protoName = descriptor.messageType.name
        } else {
            protoName = descriptor.name
        }

        let jsonName = descriptor.jsonName ?? protoName
        if jsonName == protoName {
            // The proto and JSON names are identical:
            return ".same(proto: \"\(protoName)\")"
        } else {
            let libraryGeneratedJsonName = NamingUtils.toJsonFieldName(protoName)
            if jsonName == libraryGeneratedJsonName {
                // The library will generate the same thing protoc gave, so
                // we can let the library recompute this:
                return ".standard(proto: \"\(protoName)\")"
            } else {
                // The library's generation didn't match, so specify this explicitly.
                return ".unique(proto: \"\(protoName)\", json: \"\(jsonName)\")"
            }
        }
    }

    var isMap: Bool {
        descriptor.isMap
    }
    var isPacked: Bool {
        descriptor.isPacked
    }

    // Note: this could still be a map (since those are repeated message fields
    var isRepeated: Bool {
        descriptor.label == .repeated
    }

    init(descriptor: FieldDescriptor, context: ProtoFileContext) {
        self.descriptor = descriptor

        precondition(descriptor.realOneof == nil, "OneOfs aren't supported!")

        self.hasFieldPresence = descriptor.hasPresence && descriptor.realOneof == nil

        let names = context.namer.messagePropertyNames(field: descriptor, prefixed: "_", includeHasAndClear: hasFieldPresence)
        self.name = names.name
        self.privateName = names.prefixed
        self.storedProperty = hasFieldPresence ? privateName : name
        self.propertyHasName = names.has
        self.funcClearName = names.clear

        self.type = descriptor.type

        typeName = descriptor.swiftType(namer: context.namer)
        storageType = descriptor.swiftStorageType(namer: context.namer)
        defaultValue = descriptor.swiftDefaultValue(namer: context.namer)
        traitsType = descriptor.traitsType(namer: context.namer)
        protoGenericType = descriptor.protoGenericType

        sourceCodeComments = descriptor.protoSourceComments()
        
        self.number = Int(descriptor.number)
    }
}
