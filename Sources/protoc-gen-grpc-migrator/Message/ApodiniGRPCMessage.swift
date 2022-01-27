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
        // TODO consider sanitizing, prefixing, sufixing the name etc (Generics Name to uniqueify)?

        self.context = context
        self.migration = migration

        let typeName = type.typeName
        self.name = typeName.mangledName // TODO generics?

        self.fullName = type.retrieveFullName(namer: context.namer)!
        self.relativeName = fullName
            .components(separatedBy: ".")
            .last
            .unsafelyUnwrapped

        fields = type.objectProperties
            .enumerated()
            .map { GRPCMessageField(ApodiniMessageField($1, number: $0, context: context, migration: migration)) }
    }
}
