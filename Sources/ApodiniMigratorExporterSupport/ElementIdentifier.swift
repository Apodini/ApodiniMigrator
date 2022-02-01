//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Some sort of string based identifier of some element.
///
/// Currently supported `ElementIdentifier` implementations:
/// * ``EndpointIdentifier``
/// * ``TypeInformationIdentifier``
public protocol ElementIdentifier: RawRepresentable where Self.RawValue == String {
    static var type: IdentifierType { get }
    /// A string identifier, to uniquely identify this ``EndpointIdentifier``.
    static var identifierType: String { get }
}

public extension ElementIdentifier {
    /// Default implementation. Uses the type name.
    static var identifierType: String {
        "\(Self.self)"
    }
}

public enum IdentifierType: String, Codable, Hashable {
    case typeInformation
    case endpoint
}

public struct AnyElementIdentifier: Hashable {
    public let type: IdentifierType
    public let identifier: String
    public let value: String

    public init(type: IdentifierType, identifier: String, value: String) {
        self.type = type
        self.identifier = identifier
        self.value = value
    }

    public init<Identifier: ElementIdentifier>(from identifier: Identifier) {
        self.init(type: Identifier.type, identifier: Identifier.identifierType, value: identifier.rawValue)
    }

    public func typed<Identifier: ElementIdentifier>(of identifier: Identifier.Type = Identifier.self) -> Identifier {
        guard self.type == Identifier.type else {
            fatalError("Tried to convert identifier of type \(self.type) to \(type)!")
        }

        guard self.identifier == Identifier.identifierType else {
            fatalError("Tired to cast \(self) to \(type) with non matching id \(Identifier.identifierType)!")
        }

        guard let typedValue = Identifier(rawValue: value) else {
            fatalError("Unexpected error when creating typed version of \(Identifier.self) from \(self)!")
        }
        return typedValue
    }
}

// MARK: Codable
extension AnyElementIdentifier: Codable {
    private enum CodingKeys: String, CodingKey {
        case type // TODO optional decoding
        case identifier = "id" // legacy naming
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decodeIfPresent(IdentifierType.self, forKey: .type)
            ?? .endpoint // backwards compatibility. Before there was a dedicated `AnyEndpointIdentifier`
        identifier = try container.decode(String.self, forKey: .identifier)
        value = try container.decode(String.self, forKey: .value)
    }
}
