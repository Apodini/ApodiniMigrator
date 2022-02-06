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

class ProtoGRPCEnum: SomeGRPCEnum, Changeable {
    let descriptor: EnumDescriptor
    let context: ProtoFileContext

    let fullName: String
    let relativeName: String
    var sourceCodeComments: String?

    var unavailable = false
    var containsRootTypeChange = false

    var enumCases: [GRPCEnumCase] = []
    var uniquelyNamedValues: [GRPCEnumCase] = []

    var defaultValue: GRPCEnumCase

    init(descriptor: EnumDescriptor, context: ProtoFileContext) {
        precondition(descriptor.values.count <= 500, "We don't support generating very large enums. See https://github.com/apple/swift-protobuf/issues/904.")

        self.descriptor = descriptor
        self.context = context

        fullName = context.namer.fullName(enum: descriptor)
        relativeName = context.namer.relativeName(enum: descriptor)
        sourceCodeComments = descriptor.protoSourceComments()

        var protoEnumCases: [ProtoGRPCEnumCase] = []
        for enumCase in descriptor.values where enumCase.aliasOf == nil {
            protoEnumCases.append(ProtoGRPCEnumCase(descriptor: enumCase, context: context))
        }

        enumCases = protoEnumCases
            .map { GRPCEnumCase($0) }

        uniquelyNamedValues = context.namer
            .uniquelyNamedValues(enum: descriptor)
            .map { descriptor in
                // this ensure that `uniquelyNamedValues` contains the same reference values as in `enumCases`
                // this is required to be consistent with modifications to `enumCases` (e.g. UpdateChange or RemovalChange)
                guard let enumCase = protoEnumCases.first(where: { ObjectIdentifier($0.descriptor) == ObjectIdentifier(descriptor) }) else {
                    fatalError("Failed to find reference for \(descriptor.fullName) enum case!")
                }

                return GRPCEnumCase(enumCase)
            }

        self.defaultValue = GRPCEnumCase(
            ProtoGRPCEnumCase(descriptor: descriptor.defaultValue, context: context)
        )
    }

    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        switch change.updated {
        case .rootType:
            containsRootTypeChange = true // root type changes are unsupported!
        case .property:
            fatalError("Tried updating enum with message-only change type!")
        case let .case(`case`):
            if let renamedEnumCase = `case`.modeledIdentifierChange {
                enumCases
                    .filter { $0.name == renamedEnumCase.from.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCEnumCase.self) }
                    .forEach { $0.applyIdChange(renamedEnumCase) }
            } else if let caseAddition = `case`.modeledAdditionChange {
                let addedCase = GRPCEnumCase(ApodiniEnumCase(caseAddition.added))

                enumCases.append(addedCase)
                uniquelyNamedValues.append(addedCase)
            } else if let caseRemoval = `case`.modeledRemovalChange {
                enumCases
                    .filter { $0.name == caseRemoval.id.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCEnumCase.self) }
                    .forEach { $0.applyRemovalChange(caseRemoval) }
            } else if let caseUpdate = `case`.modeledUpdateChange {
                enumCases
                    .filter { $0.name == caseUpdate.id.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCEnumCase.self) }
                    .forEach { $0.applyUpdateChange(caseUpdate) }
            }
        case .identifier:
            // TODO do we support any identifier changes?
            break
        case .rawValueType:
            // no need to handle this. if we generate a enum it is one without associated values
            // and cases are only encoded via their proto number. Therefore, it isn't relevant
            // if the server interprets the value of the enum case differently.
            break
        }
    }

    func applyRemovalChange(_ change: ModelChange.RemovalChange) {
        unavailable = true
    }
}
