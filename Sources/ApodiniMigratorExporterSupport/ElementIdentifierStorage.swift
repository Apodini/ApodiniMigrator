//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OrderedCollections

public struct ElementIdentifierStorage: Hashable {
    private let expectedType: IdentifierType
    private var identifiers: OrderedDictionary<String, AnyElementIdentifier>

    public init(expecting expectedType: IdentifierType) {
        self.expectedType = expectedType
        self.identifiers = [:]
    }
    
    public mutating func sort() {
        identifiers.sort()
    }

    public mutating func add<Identifier: ElementIdentifier>(identifier: Identifier) {
        self.identifiers[Identifier.identifierType] = AnyElementIdentifier(from: identifier)
    }

    public mutating func add(anyIdentifier: AnyElementIdentifier) {
        precondition(anyIdentifier.type == expectedType, "Only \(expectedType) identifiers can be added to this IdentifierStorage. Tried adding \(anyIdentifier)")
        self.identifiers[anyIdentifier.identifier] = anyIdentifier
    }

    public func identifierIfPresent<Identifier: ElementIdentifier>(for type: Identifier.Type = Identifier.self) -> Identifier? {
        guard let rawValue = self.identifiers[Identifier.identifierType]?.value else {
            return nil
        }

        return Identifier(rawValue: rawValue)
    }

    public func identifier<Identifier: ElementIdentifier>(for type: Identifier.Type = Identifier.self) -> Identifier {
        guard let identifier = identifierIfPresent(for: Identifier.self) else {
            fatalError("Failed to retrieve required Identifier \(type) as it wasn't present on storage for \(expectedType).")
        }

        return identifier
    }
}

extension ElementIdentifierStorage: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case elements
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // backwards compatibility layer
        guard container.allKeys.contains(.type) && container.allKeys.contains(.elements) else {
            let container = try decoder.singleValueContainer()
            self.expectedType = .endpoint
            self.identifiers = try container.decode([String: String].self)
                .reduce(into: [:]) { result, entry in
                    result[entry.key] = AnyElementIdentifier(type: .endpoint, identifier: entry.key, value: entry.value)
                }
            return
        }

        let expectedType = try container.decode(IdentifierType.self, forKey: .type)
        self.expectedType = expectedType

        self.identifiers = try container.decode([String: String].self, forKey: .elements)
            .reduce(into: [:]) { result, entry in
                result[entry.key] = AnyElementIdentifier(type: expectedType, identifier: entry.key, value: entry.value)
            }
    }

    public func encode(to encoder: Encoder) throws {
        struct AnyCodingKey: CodingKey {
            var stringValue: String

            init(stringValue: String) {
                self.stringValue = stringValue
            }

            var intValue: Int? {
                fatalError("Can't access intValue for AnyCodingKey!")
            }

            init?(intValue: Int) {
                fatalError("Can't init from intValue for AnyCodingKey!")
            }
        }

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(expectedType, forKey: .type)

        var identifierContainer = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .elements)
        var sortedIdentifiers = self.identifiers
        sortedIdentifiers.sort()
        for (key, value) in sortedIdentifiers {
            try identifierContainer.encode(value.value, forKey: AnyCodingKey(stringValue: key))
        }
    }
}

// MARK: Sequence
extension ElementIdentifierStorage: Sequence {
    public typealias Iterator = OrderedDictionary<String, AnyElementIdentifier>.Values.Iterator

    public func makeIterator() -> Iterator {
        identifiers.values.makeIterator()
    }
}

// MARK: Collection
extension ElementIdentifierStorage: Collection {
    public typealias Index = OrderedDictionary<String, AnyElementIdentifier>.Index
    public typealias Element = OrderedDictionary<String, AnyElementIdentifier>.Value

    public var startIndex: Index {
        identifiers.values.startIndex
    }
    public var endIndex: Index {
        identifiers.values.endIndex
    }
    public subscript(position: Index) -> Element {
        identifiers.values[position]
    }

    public func index(after index: Index) -> Index {
        identifiers.values.index(after: index)
    }
}
