//
// Created by Andreas Bauer on 27.12.21.
//

import Foundation

public protocol EndpointIdentifier: RawRepresentable where Self.RawValue == String {
    static var identifierType: String { get }
}

public extension EndpointIdentifier {
    static var identifierType: String {
        "\(Self.self)"
    }
}

// MARK: Handler Name
extension TypeName: EndpointIdentifier {}


public struct AnyEndpointIdentifier: Value, DeltaIdentifiable, Hashable {
    public let id: String
    public let value: String

    public var deltaIdentifier: DeltaIdentifier {
        DeltaIdentifier(rawValue: id)
    }

    public init(id: String, value: String) {
        self.id = id
        self.value = value
    }

    public init<Identifier: EndpointIdentifier>(from identifier: Identifier) {
        self.id = Identifier.identifierType
        self.value = identifier.rawValue
    }

    public func typed<Identifier: EndpointIdentifier>(of type: Identifier.Type = Identifier.self) -> Identifier {
        guard id == Identifier.identifierType else {
            fatalError("Tired to cast \(self) to \(type) with non matching id \(Identifier.identifierType)!")
        }

        guard let typedValue = Identifier(rawValue: value) else {
            fatalError("Unexpected error when creating typed version of \(Identifier.self) from \(self)!")
        }
        return typedValue
    }
}
