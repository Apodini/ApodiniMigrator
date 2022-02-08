//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation


// MARK: IdChange
public extension Change {
    /// A simple data structure/model to represent the `idChange` case of a ``Change``.
    /// This can be used to more easily pass changes around without the constant need to unwrap the enum cases.
    struct IdentifierChange {
        /// The previous identifier value.
        public let from: DeltaIdentifier
        /// The updated identifier value.
        public let to: DeltaIdentifier
        /// The similarity score [0-1] of the identifiers.
        public let similarity: Double?
        /// Breaking classification.
        public let breaking: Bool
        /// Solvable classification.
        public let solvable: Bool
    }

    /// A ``IdentifierChange`` model instance of the self ``Change``.
    /// Returns nil if the change is not a `.idChange` case.
    var modeledIdentifierChange: IdentifierChange? {
        guard case let .idChange(from, to, similarity, breaking, solvable) = self else {
            return nil
        }
        return IdentifierChange(from: from, to: to, similarity: similarity, breaking: breaking, solvable: solvable)
    }

    /// Initialize a ``Change`` enum case from a ``IdentifierChange``.
    init(from model: IdentifierChange) {
        self = .idChange(from: model.from, to: model.to, similarity: model.similarity, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: AdditionChange
public extension Change {
    /// A simple data structure/model to represent the `addition` case of a ``Change``.
    /// This can be used to more easily pass changes around without the constant need to unwrap the enum cases.
    struct AdditionChange {
        /// The identifier of the newly added `Element`
        public let id: DeltaIdentifier
        /// The added `Element`.
        public let added: Element
        /// Optionally and only if applicable, an int identifier to the json representation of a default value.
        public let defaultValue: Int?
        /// Breaking classification.
        public let breaking: Bool
        /// Solvable classification.
        public let solvable: Bool
    }

    /// A ``AdditionChange`` model instance of the self ``Change``.
    /// Returns nil if the change is not a `.addition` case.
    var modeledAdditionChange: AdditionChange? {
        guard case let .addition(id, added, defaultValue, breaking, solvable) = self else {
            return nil
        }
        return AdditionChange(id: id, added: added, defaultValue: defaultValue, breaking: breaking, solvable: solvable)
    }

    /// Initialize a ``Change`` enum case from a ``AdditionChange``.
    init(from model: AdditionChange) {
        self = .addition(id: model.id, added: model.added, defaultValue: model.defaultValue, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: RemovalChange
public extension Change {
    /// A simple data structure/model to represent the `removal` case of a ``Change``.
    /// This can be used to more easily pass changes around without the constant need to unwrap the enum cases.
    struct RemovalChange {
        /// The identifier of the removed `Element`.
        public let id: DeltaIdentifier
        /// Optionally, the description of the removed `Element`.
        /// Typically, this is not included as the element is part of the base `APIDocument`.
        public let removed: Element?
        /// Optionally and only if applicable, an int identifier to the json representation of a fallback value.
        public let fallbackValue: Int?
        /// Breaking classification.
        public let breaking: Bool
        /// Solvable classification.
        public let solvable: Bool
    }

    /// A ``RemovalChange`` model instance of the self ``Change``.
    /// Returns nil if the change is not a `.removal` case.
    var modeledRemovalChange: RemovalChange? {
        guard case let .removal(id, removed, fallbackValue, breaking, solvable) = self else {
            return nil
        }
        return RemovalChange(id: id, removed: removed, fallbackValue: fallbackValue, breaking: breaking, solvable: solvable)
    }

    /// Initialize a ``Change`` enum case from a ``RemovalChange``.
    init(from model: RemovalChange) {
        self = .removal(id: model.id, removed: model.removed, fallbackValue: model.fallbackValue, breaking: model.breaking, solvable: model.solvable)
    }
}

// MARK: UpdateChange
public extension Change {
    /// A simple data structure/model to represent the `update` case of a ``Change``.
    /// This can be used to more easily pass changes around without the constant need to unwrap the enum cases.
    struct UpdateChange {
        /// The identifier of the updated `Element`.
        public let id: DeltaIdentifier
        /// A structure which describes the update. How the update is structured is entirely defined
        /// by the `Element` itself. It may contain nested ``Changes``.
        public let updated: Element.Update
        /// Breaking classification.
        public let breaking: Bool
        /// Solvable classification.
        public let solvable: Bool
    }

    /// A ``UpdateChange`` model instance of the self ``Change``.
    /// Returns nil if the change is not a `.update` case.
    var modeledUpdateChange: UpdateChange? {
        guard case let .update(id, updated, breaking, solvable) = self else {
            return nil
        }
        return UpdateChange(id: id, updated: updated, breaking: breaking, solvable: solvable)
    }

    /// Initialize a ``Change`` enum case from a ``UpdateChange``.
    init(from model: UpdateChange) {
        self = .update(id: model.id, updated: model.updated, breaking: model.breaking, solvable: model.solvable)
    }
}
