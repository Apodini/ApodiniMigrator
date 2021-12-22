//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum Change<Element: ChangeableElement>: AnyChange, Equatable {
    // TODO provider support, addition/deletion pairs be treated as rename
    //   - update change be treated as deletion + addition

    /// TODO only present if `allowEndpointIdentifierUpdate` is enabled!
    case idChange(
        from: DeltaIdentifier,
        to: DeltaIdentifier,
        similarity: Double?, // TODO check why these are all optionals?
        breaking: Bool = false,
        solvable: Bool = true
        // TODO also a provider support thingy?
    )

    case addition(
        id: DeltaIdentifier, // TODO removable, included in element!
        added: Element,
        defaultValue: Int? = nil,
        breaking: Bool = false,
        solvable: Bool = true
        // TODO addition provider support
    )

    /// Describes a change where the element was completely removed.
    ///
    /// removed: Optional a description of the element which was removed.
    ///     Typically the based element is still in the original interface description document.
    case removal(
        id: DeltaIdentifier, // TODO this would be duplicate if below field is required!
        removed: Element? = nil,
        fallbackValue: Int? = nil,
        breaking: Bool = true,
        solvable: Bool = false
        // TODO addition provider support
    )

    case update(
        id: DeltaIdentifier,
        updated: Element.Update,
        breaking: Bool = true,
        solvable: Bool = true
        // TODO those are not encoded if the Update VALUE already contains those(?)
    )

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

        // TODO provider support
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
            self = .update(
                id: try container.decode(DeltaIdentifier.self, forKey: .id),
                updated: try container.decode(Element.Update.self, forKey: .updated),
                breaking: try container.decode(Bool.self, forKey: .breaking),
                solvable: try container.decode(Bool.self, forKey: .solvable)
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
            // TODO do not encode breaking/solvable if nested update?
            try container.encode(ChangeType.update, forKey: .type)

            try container.encode(id, forKey: .id)
            try container.encode(updated, forKey: .updated)
            try container.encode(breaking, forKey: .breaking)
            try container.encode(solvable, forKey: .solvable)
        }
    }
}
