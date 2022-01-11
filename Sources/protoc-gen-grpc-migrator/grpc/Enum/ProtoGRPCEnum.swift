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

class ProtoGRPCEnum: SomeGRPCEnum {
    let descriptor: EnumDescriptor
    let context: ProtoFileContext

    let fullName: String
    let relativeName: String
    var sourceCodeComments: String?

    var unavailable = false // TODO set!
    var containsRootTypeChange = false // TODO use!

    var enumCases: [GRPCEnumCase] = []

    lazy var uniquelyNamedValues: [GRPCEnumCase] = {
        context.namer
            .uniquelyNamedValues(enum: descriptor)
            .map { .init(ProtoGRPCEnumCase(descriptor: $0, context: context)) }
    }()

    var defaultValue: GRPCEnumCase

    init(descriptor: EnumDescriptor, context: ProtoFileContext) {
        precondition(descriptor.values.count <= 500, "We don't support generating very large enums. See https://github.com/apple/swift-protobuf/issues/904.")

        self.descriptor = descriptor
        self.context = context

        fullName = context.namer.fullName(enum: descriptor)
        relativeName = context.namer.relativeName(enum: descriptor)
        sourceCodeComments = descriptor.protoSourceComments()

        for enumCase in descriptor.values where enumCase.aliasOf == nil {
            enumCases.append(GRPCEnumCase(
                ProtoGRPCEnumCase(descriptor: enumCase, context: context)
            ))
        }

        self.defaultValue = GRPCEnumCase(
            ProtoGRPCEnumCase(descriptor: descriptor.defaultValue, context: context)
        )
    }

    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        // TODO deltaIdentifier
        switch change.updated {
        case .rootType: // TODO model it as removal and addition?
            containsRootTypeChange = true // root type changes are unsupported!
        case .property:
            fatalError("Tried updating enum with message-only change type!")
        case let .case(`case`):
            // TODO we ignore additions right?
            if let caseAddition = `case`.modeledAdditionChange {
                // TODO how to derive the index/number?

                // TODO add a case!
            } else if let caseRemoval = `case`.modeledRemovalChange {
                // TODO deltaIdentifier match right?
                // TODO enumCases.removeAll(where: { $0.name == caseRemoval.id.rawValue })
                // TODO just mark them as removed (aka deprecated them!)
                // TODO prevent encoding of removed cases(?)
            } else if let caseUpdate = `case`.modeledUpdateChange {
                // case statement is used to generate compiler error should enum be updated with new change types
                switch caseUpdate.updated {
                case .rawValue:
                    // same argument as in the `rawValueType` case
                    break
                }
            }
        case .rawValueType:
            // no need to handle this. if we generate a enum it is one without associated values
            // and cases are only encoded via their proto number. Therefore, it isn't relevant
            // if the server interprets the value of the enum case differently.
            break
        }
    }
}
