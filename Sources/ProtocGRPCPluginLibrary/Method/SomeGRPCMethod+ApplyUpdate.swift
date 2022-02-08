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

extension SomeGRPCMethod {
    func registerRemovalChange(_ change: EndpointChange.RemovalChange) {
        unavailable = true
    }

    func registerUpdateChange(_ change: EndpointChange.UpdateChange) {
        switch change.updated {
        case let .identifier(identifier):
            self.identifierChanges.append(identifier)
        case let .communicationPattern(from, to):
            self.communicationPatternChange = (from, to)
        case let .response(from, to, backwardsMigration, migrationWarning):
            self.responseChange = (
                migration.typeStore.construct(from: from),
                migration.typeStore.construct(from: to),
                backwardsMigration,
                migrationWarning
            )
        case let .parameter(parameter):
            if case .idChange = parameter { // we ignore parameter renames!
                break
            }

            guard let parameterUpdate = parameter.modeledUpdateChange else {
                fatalError("Encountered parameter change for grpc method \(methodPath) which wasn't mapped to a property update: \(change)")
            }

            // In grpc all parameters are combined into a single parameter.
            // Typically, this means all parameter updates are mapped to property updates of a newly introduced wrapper type.
            // However, this wrapper type is not introduced if the endpoint already has a single message-based parameter (which is not optional).
            // In those cases we want to handle a single parameter update for the single parameter.
            precondition(parameterChange == nil, "Encountered multiple parameter updates for \(methodPath) with single parameter!")

            switch parameterUpdate.updated {
            case .parameterType:
                break // parameter type is ignored
            case .necessity:
                break // grpc parameters are always required!
            case let .type(from, to, forwardMigration, migrationWarning):
                // a lot of endpoints will have wrapper types, which won't result in a type change!
                // though for endpoints were no wrapper type is introduced, there may still be a type change!
                self.parameterChange = (
                    migration.typeStore.construct(from: from),
                    migration.typeStore.construct(from: to),
                    forwardMigration,
                    migrationWarning
                )
            }
        }
    }
}
