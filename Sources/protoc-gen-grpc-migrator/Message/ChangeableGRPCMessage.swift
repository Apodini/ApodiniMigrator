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
                fields
                    .filter { $0.name == renamedProperty.from.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCMessageField.self) }
                    .forEach { $0.applyIdChange(renamedProperty) }
            } else if let addedProperty = property.modeledAdditionChange {
                // TODO we currently GUESS the property number!
                let property = TypeProperty(
                    name: addedProperty.added.name,
                    type: migration.typeStore.construct(from: addedProperty.added.type),
                    annotation: addedProperty.added.annotation
                )

                let previousCount = fields.count

                this.fields.append(GRPCMessageField(ApodiniMessageField(
                    property,
                    number: fields.count + 1,
                    defaultValue: addedProperty.defaultValue,
                    context: context,
                    migration: migration
                )))
                assert(previousCount + 1 == self.fields.count, "AnyObject inheritance assumption for Changeable broke")
            } else if let removedProperty = property.modeledRemovalChange {
                // TODO handle ApodiniFields!!!
                fields
                    .filter { $0.name == removedProperty.id.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCMessageField.self) }
                    .forEach { $0.applyRemovalChange(removedProperty) }
            } else if let updatedProperty = property.modeledUpdateChange {
                fields
                    .filter { $0.name == updatedProperty.id.rawValue }
                    .compactMap { $0.tryTyped(for: ProtoGRPCMessageField.self) }
                    .forEach { $0.applyUpdateChange(updatedProperty) }
            }
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
