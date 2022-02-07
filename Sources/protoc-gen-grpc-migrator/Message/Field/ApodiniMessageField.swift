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

class ApodiniMessageField: SomeGRPCMessageField, ChangeableGRPCField {
    private let property: TypeProperty
    let context: ProtoFileContext
    let migration: MigrationContext

    var hasFieldPresence: Bool

    var name: String
    var privateName: String {
        "_" + name
    }
    var storedProperty: String {
        hasFieldPresence ? privateName : name
    }
    var propertyHasName: String {
        "has" + name.upperFirst
    }
    var funcClearName: String {
        "clear" + name.upperFirst
    }

    var type: Google_Protobuf_FieldDescriptorProto.TypeEnum

    var typeName: String
    var storageType: String
    var defaultValue: String
    var traitsType: String
    var protoGenericType: String

    var sourceCodeComments: String?

    var number: Int

    var fieldMapNames: String {
        ".same(proto: \"\(name)\")"
    }

    var isMap: Bool
    var isPacked: Bool
    var isRepeated: Bool

    var updatedName: String?
    var unavailable = false
    var fallbackValue: Int?
    var necessityUpdate: (from: Necessity, to: Necessity, necessityMigration: Int)?
    var typeUpdate: (from: TypeInformation, to: TypeInformation, forwardMigration: Int, backwardMigration: Int)?

    init(_ property: TypeProperty, defaultValue: Int? = nil, context: ProtoFileContext, migration: MigrationContext) {
        // we ignore fluent property annotations

        self.property = property
        self.context = context
        self.migration = migration

        let identifiers = property.context.get(valueFor: TypeInformationIdentifierContextKey.self)

        self.name = property.name
        self.type = .init(rawValue: Int(identifiers.identifier(for: GRPCFieldType.self).type))
            ?? property.protoType

        self.typeName = property.swiftType(namer: context.namer)
        self.storageType = property.swiftStorageType(namer: context.namer)
        if let defaultValue = defaultValue {
            self.defaultValue = "(try! \(typeName).instance(from: \(defaultValue)))"
        } else {
            self.defaultValue = property.swiftDefaultValue(namer: context.namer)
        }
        self.traitsType = property.traitsType(namer: context.namer)
        self.protoGenericType = property.deriveProtoGenericType()

        self.sourceCodeComments = nil

        self.number = Int(identifiers.identifier(for: GRPCNumber.self).number)

        let type = property.type
        self.hasFieldPresence = property.hasPresence
        self.isMap = type.isDictionary
        self.isPacked = false
        self.isRepeated = type.isRepeated
    }
}
