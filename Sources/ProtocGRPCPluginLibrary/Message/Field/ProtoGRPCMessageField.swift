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

class ProtoGRPCMessageField: SomeGRPCMessageField, ChangeableGRPCField {
    let descriptor: FieldDescriptor
    let context: ProtoFileContext
    let migration: MigrationContext

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

    var number: Int

    var fieldMapNames: String {
        let protoName: String = descriptor.name
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

    var updatedName: String?
    var unavailable = false
    var fallbackValue: Int?
    var necessityUpdate: (from: Necessity, to: Necessity, necessityMigration: Int)?
    var typeUpdate: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, backwardMigration: Int)?
    var protoFieldTypeUpdate: Google_Protobuf_FieldDescriptorProto.TypeEnum?

    init(descriptor: FieldDescriptor, context: ProtoFileContext, migration: MigrationContext) {
        precondition(descriptor.protoType != .group, ".group field types are not supported!")
        self.descriptor = descriptor
        self.context = context
        self.migration = migration

        precondition(descriptor.realOneof == nil, "OneOfs aren't supported!")

        self.hasFieldPresence = descriptor.hasPresence && descriptor.realOneof == nil

        let names = context.namer.messagePropertyNames(field: descriptor, prefixed: "_", includeHasAndClear: hasFieldPresence)
        self.name = names.name
        self.privateName = names.prefixed
        self.storedProperty = hasFieldPresence ? privateName : name
        self.propertyHasName = names.has
        self.funcClearName = names.clear

        self.type = descriptor.protoType

        self.typeName = descriptor.swiftType(namer: context.namer)
        self.storageType = descriptor.swiftStorageType(namer: context.namer)
        self.defaultValue = descriptor.swiftDefaultValue(namer: context.namer)
        self.traitsType = descriptor.traitsType(namer: context.namer)
        self.protoGenericType = descriptor.deriveProtoGenericType()

        sourceCodeComments = descriptor.protoSourceComments()
        
        self.number = Int(descriptor.number)
    }
}
