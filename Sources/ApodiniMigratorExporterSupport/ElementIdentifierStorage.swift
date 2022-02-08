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
    private var identifiers: OrderedDictionary<String, AnyElementIdentifier>

    public var values: OrderedDictionary<String, AnyElementIdentifier>.Values {
        identifiers.values
    }

    public init() {
        self.identifiers = [:]
    }
    
    public mutating func sort() {
        identifiers.sort()
    }

    public mutating func add<Identifier: ElementIdentifier>(identifier: Identifier) {
        self.identifiers[Identifier.identifierType] = AnyElementIdentifier(from: identifier)
    }

    public mutating func add(anyIdentifier: AnyElementIdentifier) {
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
            fatalError("Failed to retrieve required Identifier \(type) as it wasn't present on storage.")
        }

        return identifier
    }

    public static func == (lhs: ElementIdentifierStorage, rhs: ElementIdentifierStorage) -> Bool {
        guard lhs.identifiers.count == rhs.identifiers.count else {
            return false
        }

        var lhsIdentifiers = lhs.identifiers
        var rhsIdentifiers = rhs.identifiers
        lhsIdentifiers.sort()
        rhsIdentifiers.sort()

        return lhsIdentifiers == rhsIdentifiers
    }
}

extension ElementIdentifierStorage: Codable {
    private struct StringCodingKey: CodingKey {
        var stringValue: String
        let intValue: Int? = nil

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            nil
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)

        self.identifiers = [:]

        for key in container.allKeys {
            let value = try container.decode(String.self, forKey: key)
            self.identifiers[key.stringValue] = AnyElementIdentifier(identifier: key.stringValue, value: value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)

        var sortedIdentifiers = self.identifiers
        sortedIdentifiers.sort()

        for (key, value) in sortedIdentifiers {
            try container.encode(value.value, forKey: StringCodingKey(stringValue: key))
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
