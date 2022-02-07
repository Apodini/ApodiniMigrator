//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

protocol ChangeableGRPCMessage: Changeable, SomeGRPCMessage where Element == TypeInformation {}

extension ChangeableGRPCMessage {
    // disabled for the sake of compactness:
    // swiftlint:disable:next cyclomatic_complexity
    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        switch change.updated {
        case .rootType:
            self.containsRootTypeChange = true // root type changes are unsupported
        case let .property(property):
            if let renamedProperty = property.modeledIdentifierChange {
                for field in fields where field.name == renamedProperty.from.rawValue {
                    if let protoField = field.tryTyped(for: ProtoGRPCMessageField.self) {
                        protoField.applyIdChange(renamedProperty)
                    } else if let apodiniField = field.tryTyped(for: ApodiniMessageField.self) {
                        apodiniField.applyIdChange(renamedProperty)
                    } else {
                        fatalError("Renamed property isn't a updatable property. For update: \(change)!")
                    }
                }
            } else if let addedProperty = property.modeledAdditionChange {
                var property = addedProperty.added
                property.dereference(from: migration.typeStore)

                self.fields.append(GRPCMessageField(ApodiniMessageField(
                    property,
                    defaultValue: addedProperty.defaultValue,
                    context: context,
                    migration: migration
                )))
            } else if let removedProperty = property.modeledRemovalChange {
                for field in fields where field.name == removedProperty.id.rawValue {
                    if let protoField = field.tryTyped(for: ProtoGRPCMessageField.self) {
                        protoField.applyRemovalChange(removedProperty)
                    } else if let apodiniField = field.tryTyped(for: ApodiniMessageField.self) {
                        apodiniField.applyRemovalChange(removedProperty)
                    } else {
                        fatalError("Removed property isn't a updatable property. For update: \(change)!")
                    }
                }
            } else if let updatedProperty = property.modeledUpdateChange {
                for field in fields where field.name == updatedProperty.id.rawValue {
                    if let protoField = field.tryTyped(for: ProtoGRPCMessageField.self) {
                        protoField.applyUpdateChange(updatedProperty)
                    } else if let apodiniField = field.tryTyped(for: ApodiniMessageField.self) {
                        apodiniField.applyUpdateChange(updatedProperty)
                    } else {
                        fatalError("Updated property isn't a updatable property. For update: \(change)!")
                    }
                }
            }
        case .identifier:
            // identifier right now only consist of `GRPCName´. So we ignore those changes right now
            break
        case .case, .rawValueType:
            fatalError("Tried updating message with enum-only change type!")
        }
    }

    func applyRemovalChange(_ change: ModelChange.RemovalChange) {
        self.unavailable = true
    }
}
