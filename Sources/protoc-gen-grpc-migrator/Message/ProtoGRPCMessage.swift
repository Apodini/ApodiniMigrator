//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator
import SwiftProtobufPluginLibrary
import OrderedCollections

class ProtoGRPCMessage: SomeGRPCMessage, Changeable {
    let descriptor: Descriptor
    let context: ProtoFileContext
    let migration: MigrationContext

    var name: String {
        descriptor.name
    }
    var relativeName: String
    var fullName: String

    var sourceCodeComments: String?

    var unavailable = false
    var containsRootTypeChange = false

    var fields: [GRPCMessageField] = []

    var nestedEnums: OrderedDictionary<String, GRPCEnum> = [:]
    var nestedMessages: OrderedDictionary<String, GRPCMessage> = [:]

    init(descriptor: Descriptor, context: ProtoFileContext, migration: MigrationContext) {
        self.descriptor = descriptor
        self.context = context
        self.migration = migration

        precondition(descriptor.extensionRanges.isEmpty, "proto extensions are unsupported by the migrator")

        self.relativeName = context.namer.relativeName(message: descriptor)
        self.fullName = context.namer.fullName(message: descriptor)

        self.sourceCodeComments = descriptor.protoSourceComments()

        for field in descriptor.fields {
            fields.append(GRPCMessageField(
                ProtoGRPCMessageField(descriptor: field, context: context, migration: migration))
            )
        }


        for `enum` in descriptor.enums {
            nestedEnums[`enum`.name] = GRPCEnum(
                ProtoGRPCEnum(descriptor: `enum`, context: context)
            )
        }

        for message in descriptor.messages {
            nestedMessages[message.name] = GRPCMessage(
                ProtoGRPCMessage(descriptor: message, context: context, migration: migration)
            )
        }
    }

    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        switch change.updated {
        case .rootType:
            containsRootTypeChange = true // root type changes are unsupported
        case let .property(property):
            if let renamedProperty = property.modeledIdentifierChange {
                fields
                    .filter { $0.name == renamedProperty.from.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCMessageField.self) }
                    .forEach { $0.applyIdChange(renamedProperty) }
            } else if let addedProperty = property.modeledAdditionChange {
                // TODO we currently GUESS the property number!
                let property = TypeProperty(
                    name: addedProperty.added.name,
                    type: migration.typeStore.construct(from: addedProperty.added.type),
                    annotation: addedProperty.added.annotation
                )

                fields.append(GRPCMessageField(
                    ApodiniMessageField(property, number: fields.count + 1, defaultValue: addedProperty.defaultValue, context: context)
                ))
            } else if let removedProperty = property.modeledRemovalChange {
                fields
                    .filter { $0.name == removedProperty.id.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCMessageField.self) }
                    .forEach { $0.applyRemovalChange(removedProperty) }
            } else if let updatedProperty = property.modeledUpdateChange {
                fields
                    .filter { $0.name == updatedProperty.id.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCMessageField.self) }
                    .forEach { $0.applyUpdateChange(updatedProperty) }
            }
        case .case, .rawValueType:
            fatalError("Tried updating message with enum-only change type!")
        }
    }

    func applyRemovalChange(_ change: ModelChange.RemovalChange) {
        unavailable = true
    }
}
