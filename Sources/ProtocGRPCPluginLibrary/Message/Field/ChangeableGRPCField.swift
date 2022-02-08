//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

protocol ChangeableGRPCField: Changeable, SomeGRPCMessageField where Element == TypeProperty {}

extension ChangeableGRPCField {
    func applyIdChange(_ change: PropertyChange.IdentifierChange) {
        precondition(change.from.rawValue == name, "Identifier change isn't in sync with property name!")
        self.updatedName = change.to.rawValue
    }

    func applyUpdateChange(_ change: PropertyChange.UpdateChange) {
        switch change.updated {
        case let .necessity(from, to, necessityMigration):
            self.necessityUpdate = (from, to, necessityMigration)
        case let .type(from, to, forwardMigration, backwardMigration, _):
            self.typeUpdate = (
                migration.typeStore.construct(from: from),
                migration.typeStore.construct(from: to),
                forwardMigration,
                backwardMigration
            )
            grpcFieldTypeSanityCheck()
        case let .identifier(identifier):
            switch identifier.id.rawValue {
            case GRPCNumber.identifierType:
                guard let identifierUpdate = identifier.modeledUpdateChange else {
                    preconditionFailure("Encountered unexpected update type for `\(GRPCNumber.self)` identifier: \(identifier)")
                }

                self.number = Int(identifierUpdate.updated.to.typed(of: GRPCNumber.self).number)
            case GRPCFieldType.identifierType:
                guard let identifierUpdate = identifier.modeledUpdateChange else {
                    preconditionFailure("Encountered unexpected update type for `\(GRPCFieldType.self)` identifier: \(identifier)")
                }

                self.protoFieldTypeUpdate = .init(rawValue: Int(identifierUpdate.updated.to.typed(of: GRPCFieldType.self).type))
                grpcFieldTypeSanityCheck()
            default:
                break
            }
        }
    }

    func applyRemovalChange(_ change: PropertyChange.RemovalChange) {
        self.unavailable = true
        self.fallbackValue = change.fallbackValue
    }

    private func grpcFieldTypeSanityCheck() {
        guard let typeUpdate = typeUpdate,
              let protoFieldTypeUpdate = protoFieldTypeUpdate else {
            return
        }

        let type = typeUpdate.to.protoType

        if type != protoFieldTypeUpdate {
            FileHandle.standardError.write("WARN: Updated protoType \(type) for \(name) is different from the updated on expected on the server side: \(protoFieldTypeUpdate)".data(.utf8))
        }
    }
}
