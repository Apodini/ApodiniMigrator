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
    func applyUpdateChange(_ change: ModelChange.UpdateChange) {
        // we know that Changeable has class requirements. Its just Swift still doesn't allow
        // us to mutate state. And we can't carry the mutating state to the outside sadly.
        var this = self

        switch change.updated {
        case .rootType:
            this.containsRootTypeChange = true // root type changes are unsupported
            assert(self.containsRootTypeChange, "AnyObject inheritance assumption for Changeable broke")
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

                let previousCount = fields.count
                this.fields.append(GRPCMessageField(ApodiniMessageField(
                    property,
                    defaultValue: addedProperty.defaultValue,
                    context: context,
                    migration: migration
                )))
                assert(previousCount + 1 == self.fields.count, "AnyObject inheritance assumption for Changeable broke")
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
            // TODO handle e.g. property additions referencing the new name?
            break
        case .case, .rawValueType:
            fatalError("Tried updating message with enum-only change type!")
        }
    }

    func applyRemovalChange(_ change: ModelChange.RemovalChange) {
        var this = self
        this.unavailable = true
        assert(self.unavailable, "AnyObject inheritance assumption for Changeable broke")
    }
}
