//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation


// MARK: IdChange
public extension Change {
    struct IdentifierChange {
        public let from: DeltaIdentifier
        public let to: DeltaIdentifier
        public let similarity: Double?
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledIdentifierChange: IdentifierChange? {
        guard case let .idChange(from, to, similarity, breaking, solvable) = self else {
            return nil
        }
        return IdentifierChange(from: from, to: to, similarity: similarity, breaking: breaking, solvable: solvable)
    }

    init(from model: IdentifierChange) {
        self = .idChange(from: model.from, to: model.to, similarity: model.similarity, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: AdditionChange
public extension Change {
    struct AdditionChange {
        public let id: DeltaIdentifier
        public let added: Element
        public let defaultValue: Int?
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledAdditionChange: AdditionChange? {
        guard case let .addition(id, added, defaultValue, breaking, solvable) = self else {
            return nil
        }
        return AdditionChange(id: id, added: added, defaultValue: defaultValue, breaking: breaking, solvable: solvable)
    }

    init(from model: AdditionChange) {
        self = .addition(id: model.id, added: model.added, defaultValue: model.defaultValue, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: RemovalChange
public extension Change {
    struct RemovalChange {
        public let id: DeltaIdentifier
        public let removed: Element?
        public let fallbackValue: Int?
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledRemovalChange: RemovalChange? {
        guard case let .removal(id, removed, fallbackValue, breaking, solvable) = self else {
            return nil
        }
        return RemovalChange(id: id, removed: removed, fallbackValue: fallbackValue, breaking: breaking, solvable: solvable)
    }

    init(from model: RemovalChange) {
        self = .removal(id: model.id, removed: model.removed, fallbackValue: model.fallbackValue, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: UpdateChange
public extension Change {
    struct UpdateChange {
        public let id: DeltaIdentifier
        public let updated: Element.Update
        public let breaking: Bool
        public let solvable: Bool
    }

    var modeledUpdateChange: UpdateChange? {
        guard case let .update(id, updated, breaking, solvable) = self else {
            return nil
        }
        return UpdateChange(id: id, updated: updated, breaking: breaking, solvable: solvable)
    }

    init(from model: UpdateChange) {
        self = .update(id: model.id, updated: model.updated, breaking: model.breaking, solvable: model.solvable)
    }
}
