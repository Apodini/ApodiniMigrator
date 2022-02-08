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

class ProtoGRPCEnumCase: SomeGRPCEnumCase, Changeable {
    let descriptor: EnumValueDescriptor

    var name: String
    var relativeName: String
    var dottedRelativeName: String

    var sourceCodeComments: String?

    var unavailable = false

    var number: Int

    var aliasOf: GRPCEnumCase?
    var aliases: [GRPCEnumCase]

    init(descriptor: EnumValueDescriptor, context: ProtoFileContext) {
        self.descriptor = descriptor

        self.name = descriptor.name
        self.relativeName = context.namer.relativeName(enumValue: descriptor)
        self.dottedRelativeName = context.namer.dottedRelativeName(enumValue: descriptor)

        self.sourceCodeComments = descriptor.protoSourceComments()

        self.number = Int(descriptor.number)

        self.aliasOf = descriptor.aliasOf
            .map { .init(ProtoGRPCEnumCase(descriptor: $0, context: context)) }
        self.aliases = descriptor.aliases
            .map { .init(ProtoGRPCEnumCase(descriptor: $0, context: context)) }
    }

    func applyUpdateChange(_ change: EnumCaseChange.UpdateChange) {
        // case statement is used to generate compiler error should enum be updated with new change types
        switch change.updated {
        case .rawValue:
            // same argument as in the `rawValueType` case
            break
        case let .identifier(identifier):
            guard identifier.id.rawValue == GRPCNumber.identifierType else {
                break
            }

            guard let identifierUpdate = identifier.modeledUpdateChange else {
                preconditionFailure("Encountered unexpected update type for `GRPCNumber` identifier: \(identifier)")
            }

            self.number = Int(identifierUpdate.updated.to.typed(of: GRPCNumber.self).number)
        }
    }

    func applyRemovalChange(_ change: EnumCaseChange.RemovalChange) {
        unavailable = true
    }
}
