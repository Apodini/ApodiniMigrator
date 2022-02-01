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
        var this = self
        this.updatedName = change.to.rawValue
        assert(self.updatedName != nil, "Some of our assumptions broke")
    }

    func applyUpdateChange(_ change: PropertyChange.UpdateChange) {
        var this = self

        switch change.updated {
        case let .necessity(from, to, necessityMigration):
            this.necessityUpdate = (from, to, necessityMigration)
            assert(self.necessityUpdate != nil, "AnyObject inheritance assumption for Changeable broke")
        case let .type(from, to, forwardMigration, backwardMigration, _):
            this.typeUpdate = (
                migration.typeStore.construct(from: from),
                migration.typeStore.construct(from: to),
                forwardMigration,
                backwardMigration
            )
            assert(self.typeUpdate != nil, "AnyObject inheritance assumption for Changeable broke")
        case .identifier:
            // TODO implement identifier changes!
            break
        }
    }

    func applyRemovalChange(_ change: PropertyChange.RemovalChange) {
        var this = self

        this.unavailable = true
        this.fallbackValue = change.fallbackValue

        assert(self.unavailable, "AnyObject inheritance assumption for Changeable broke")
        assert(self.fallbackValue == change.fallbackValue, "AnyObject inheritance assumption for Changeable broke")
    }
}
