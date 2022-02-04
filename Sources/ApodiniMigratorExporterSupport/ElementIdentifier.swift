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
    /// A string identifier, to uniquely identify this ``EndpointIdentifier``.
    static var identifierType: String { get }
}

public extension ElementIdentifier {
    /// Default implementation. Uses the type name.
    static var identifierType: String {
        "\(Self.self)"
    }
}

public struct AnyElementIdentifier: Hashable {
    public let identifier: String
    public let value: String

    public init(identifier: String, value: String) {
        self.identifier = identifier
        self.value = value
    }

    public init<Identifier: ElementIdentifier>(from identifier: Identifier) {
        self.init(identifier: Identifier.identifierType, value: identifier.rawValue)
    }

    public func typed<Identifier: ElementIdentifier>(of identifier: Identifier.Type = Identifier.self) -> Identifier {
        guard self.identifier == Identifier.identifierType else {
            fatalError("Tired to cast \(self) to \(Identifier.self) with non matching id \(Identifier.identifierType)!")
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
        case identifier = "id" // legacy naming
        case value
    }
}
