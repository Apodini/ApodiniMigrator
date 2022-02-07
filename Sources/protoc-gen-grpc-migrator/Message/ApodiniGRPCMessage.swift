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

class ApodiniGRPCMessage: SomeGRPCMessage, ChangeableGRPCMessage {
    let context: ProtoFileContext
    var migration: MigrationContext

    let name: String
    let relativeName: String
    let fullName: String

    var fields: [GRPCMessageField]

    // those two fields may be populated in `GRPCMessage`
    var nestedEnums: OrderedCollections.OrderedDictionary<String, GRPCEnum> = [:]
    var nestedMessages: OrderedCollections.OrderedDictionary<String, GRPCMessage> = [:]

    var unavailable = false
    var containsRootTypeChange = false

    init(of type: TypeInformation, context: ProtoFileContext, migration: MigrationContext) {
        precondition(type.isObject, "Cannot instantiate a GRPCMessage from a non object: \(type.rootType) \(type.typeName)")

        // swiftlint:disable:next force_unwrapping
        let identifiers = type.context!.get(valueFor: TypeInformationIdentifierContextKey.self)

        self.context = context
        self.migration = migration

        let grpcName = identifiers.identifier(for: GRPCName.self)
            .parsed()

        self.name = grpcName.typeName
        self.fullName = context.namer.fullName(message: grpcName)
        self.relativeName = context.namer.relativeName(message: grpcName)

        fields = type.objectProperties
            .map { GRPCMessageField(ApodiniMessageField($0, context: context, migration: migration)) }
    }
}
