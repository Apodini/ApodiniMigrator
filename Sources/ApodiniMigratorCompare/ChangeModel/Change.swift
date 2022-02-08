//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Typed version of an ``AnyChange``.
public enum Change<Element: ChangeableElement>: AnyChange, Equatable {
    /// This case represents a change of the primary identifier (the ``DeltaIdentifier``) of the `Element`.
    /// - Parameters:
    ///   - from: The previous identifier value.
    ///   - to: The updated identifier value.
    ///   - similarity: The similarity score [0-1] of the identifiers.
    ///   - breaking: Breaking classification.
    ///   - solvable: Solvable classification.
    case idChange(
        from: DeltaIdentifier,
        to: DeltaIdentifier,
        similarity: Double?,
        breaking: Bool = false,
        solvable: Bool = true
    )

    /// Describes a change where a new instance of an `Element` was added.
    /// - Parameters:
    ///   - id: The identifier of the newly added `Element`.
    ///   - added: The added `Element`.
    ///   - defaultValue: Optionally and only if applicable, an int identifier to the json representation of a default value.
    ///   - breaking: Breaking classification.
    ///   - solvable: Solvable classification.
    case addition(
        id: DeltaIdentifier,
        added: Element,
        defaultValue: Int? = nil,
        breaking: Bool = false,
        solvable: Bool = true
    )

    /// Describes a change where a instance of an `Element` was completely removed.
    /// - Parameters:
    ///   - id: The identifier of the removed `Element`.
    ///   - removed: Optionally, the description of the removed `Element`.
    ///        Typically, this is not included as the element is part of the base `APIDocument`.
    ///   - fallbackValue: Optionally and only if applicable, an int identifier to the json representation of a fallback value.
    ///   - breaking: Breaking classification.
    ///   - solvable: Solvable classification.
    case removal(
        id: DeltaIdentifier,
        removed: Element? = nil,
        fallbackValue: Int? = nil,
        breaking: Bool = true,
        solvable: Bool = false
    )

    /// Describes some sort of update to an existing instance of an `Element`.
    /// - Parameters:
    ///   - id: The identifier of the updated `Element`.
    ///   - updated: A structure which describes the update. How the update is structured is entirely defined
    ///     by the `Element` itself. It may contain nested ``Changes``.
    ///   - breaking: Breaking classification.
    ///   - solvable: Solvable classification.
    case update(
        id: DeltaIdentifier,
        updated: Element.Update,
        breaking: Bool = true,
        solvable: Bool = true
    )

    /// The identifier of the `Element` this change is about.
    /// - Note: In the case of an `idChange` this property returns the "base" ``DeltaIdentifier``.
    public var id: DeltaIdentifier {
        switch self {
        case let .idChange(from, _, _, _, _):
            return from
        case let .addition(id, _, _, _, _):
            return id
        case let .removal(id, _, _, _, _):
            return id
        case let .update(id, _, _, _):
            return id
        }
    }

    /// The breaking classification of the change.
    public var breaking: Bool {
        switch self {
        case let .idChange(_, _, _, breaking, _):
            return breaking
        case let .addition(_, _, _, breaking, _):
            return breaking
        case let .removal(_, _, _, breaking, _):
            return breaking
        case let .update(_, _, breaking, _):
            return breaking
        }
    }

    /// The solvable classification of the change.
    public var solvable: Bool {
        switch self {
        case let .idChange(_, _, _, _, solvable):
            return solvable
        case let .addition(_, _, _, _, solvable):
            return solvable
        case let .removal(_, _, _, _, solvable):
            return solvable
        case let .update(_, _, _, solvable):
            return solvable
        }
    }
}

// MARK: Codable
extension Change: Codable {
    private enum CodingKeys: String, CodingKey {
        case type

        case id
        case breaking
        case solvable

        case from
        case to
        case similarity

        case added
        case defaultValue

        case removed
        case fallbackValue

        case updated
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(ChangeType.self, forKey: .type)

        switch type {
        case .idChange:
            self = .idChange(
                from: try container.decode(DeltaIdentifier.self, forKey: .from),
                to: try container.decode(DeltaIdentifier.self, forKey: .to),
                similarity: try container.decodeIfPresent(Double.self, forKey: .similarity),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        case .addition:
            self = .addition(
                id: try container.decode(DeltaIdentifier.self, forKey: .id),
                added: try container.decode(Element.self, forKey: .added),
                defaultValue: try container.decodeIfPresent(Int.self, forKey: .defaultValue),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        case .removal:
            self = .removal(
                id: try container.decode(DeltaIdentifier.self, forKey: .id),
                removed: try container.decodeIfPresent(Element.self, forKey: .removed),
                fallbackValue: try container.decodeIfPresent(Int.self, forKey: .fallbackValue),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
            )
        case .update:
            let id = try container.decode(DeltaIdentifier.self, forKey: .id)
            let updated = try container.decode(Element.Update.self, forKey: .updated)
            let breaking: Bool
            let solvable: Bool

            if let nestedChange = updated as? UpdateChangeWithNestedChange,
               let nestedBreaking = nestedChange.nestedBreakingClassification,
               let nestedSolvable = nestedChange.nestedSolvableClassification {
                breaking = nestedBreaking
                solvable = nestedSolvable
            } else {
                breaking = try container.decode(Bool.self, forKey: .breaking)
                solvable = try container.decode(Bool.self, forKey: .solvable)
            }

            self = .update(
                id: id,
                updated: updated,
                breaking: breaking,
                solvable: solvable
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .idChange(from, to, similarity, breaking, solvable):
            try container.encode(ChangeType.idChange, forKey: .type)

            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encodeIfPresent(similarity, forKey: .similarity)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        case let .addition(id, added, defaultValue, breaking, solvable):
            try container.encode(ChangeType.addition, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encode(added, forKey: .added)
            try container.encodeIfPresent(defaultValue, forKey: .defaultValue)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        case let .removal(id, removed, fallbackValue, breaking, solvable):
            try container.encode(ChangeType.removal, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encodeIfPresent(removed, forKey: .removed)
            try container.encodeIfPresent(fallbackValue, forKey: .fallbackValue)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        case let .update(id, updated, breaking, solvable):
            try container.encode(ChangeType.update, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encode(updated, forKey: .updated)
            if let nestedChange = updated as? UpdateChangeWithNestedChange,
               nestedChange.isNestedChange {
                // do nothing
            } else {
                try container.encode(breaking, forKey: .breaking)
                try container.encode(solvable, forKey: .solvable)
            }
        }
    }
}
