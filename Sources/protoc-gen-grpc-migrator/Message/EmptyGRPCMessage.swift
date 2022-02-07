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

/// Describes an empty grpc message.
/// We use this type in cases, where a added `TypeInformation` is nested into a type
/// which we don't control.
class EmptyGRPCMessage: SomeGRPCMessage {
    let context: ProtoFileContext
    let migration: MigrationContext

    var name: String
    var relativeName: String
    var fullName: String

    var fields: [GRPCMessageField] = []

    var nestedEnums: OrderedDictionary<String, GRPCEnum> = [:]
    var nestedMessages: OrderedDictionary<String, GRPCMessage> = [:]

    var unavailable = false
    var containsRootTypeChange = false

    init(name: String, nestedIn baseName: String?, context: ProtoFileContext, migration: MigrationContext) {
        self.context = context
        self.migration = migration

        self.name = name

        self.relativeName = GRPCNamingUtils.sanitize(messageName: name, forbiddenTypeNames: [context.namer.swiftProtobufModuleName])
        if let baseName = baseName, !baseName.isEmpty {
            self.fullName = baseName + "." + relativeName
        } else {
            self.fullName = GRPCNamingUtils.typePrefix(protoPackage: migration.lhsExporterConfiguration.packageName) + "." + relativeName
        }
    }
}
