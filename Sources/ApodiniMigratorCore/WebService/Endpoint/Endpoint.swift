//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OrderedCollections

/// Represents an endpoint
public struct Endpoint: Value, DeltaIdentifiable {
    public static func deriveEndpointIdentifier(apodiniIdentifier: String, handlerName: TypeName) -> DeltaIdentifier {
        var identifier = apodiniIdentifier
        // checks for "x.x.x." style Apodini identifiers!
        if !identifier.split(separator: ".").compactMap({ Int($0) }).isEmpty {
            identifier = handlerName.buildName()
        }

        return DeltaIdentifier(identifier)
    }

    /// Identifier of the handler
    public let deltaIdentifier: DeltaIdentifier

    /// Storage structure for any kind of identifier of a ``Endpoint``.
    /// Use ``add(identifier:)`` to add any ``EndpointIdentifier``s.
    /// Every ``Endpoint`` has the following identifiers by standard:
    ///  - ``TypeName`` (for the handlerName)
    ///  - ``Operation``
    ///  - ``EndpointPath``
    ///
    /// Use ``identifier(for:)`` or ``identifierIfAvailable(for:)`` to retrieve an ``EndpointIdentifier``.
    /// Or use ``handlerName``, ``operation`` or ``path`` computed properties for quick access.
    public var identifiers: ElementIdentifierStorage

    /// The communication pattern of the endpoint.
    public let communicationPattern: CommunicationPattern
    /// Parameters of the endpoint
    public var parameters: [Parameter]
    /// The reference of the `typeInformation` of the response
    public var response: TypeInformation
    /// Errors
    public let errors: [ErrorCode]

    public var handlerName: TypeName {
        self.identifier()
    }

    public var operation: Operation {
        self.identifier()
    }

    public var path: EndpointPath {
        self.identifier()
    }
    
    /// Initializes a new endpoint instance
    public init(
        handlerName: String,
        deltaIdentifier: String,
        operation: Operation,
        communicationPattern: CommunicationPattern,
        absolutePath: String,
        parameters: [Parameter],
        response: TypeInformation,
        errors: [ErrorCode]
    ) {
        let typeName = TypeName(rawValue: handlerName)

        self.deltaIdentifier = Self.deriveEndpointIdentifier(apodiniIdentifier: deltaIdentifier, handlerName: typeName)
        self.identifiers = ElementIdentifierStorage()

        self.parameters = parameters
        self.communicationPattern = communicationPattern
        self.response = response
        self.errors = errors

        self.add(identifier: typeName)
        self.add(identifier: operation)
        self.add(identifier: EndpointPath(absolutePath))
    }

    /// Initializes a new endpoint instance
    public init(
        handlerName: TypeName,
        deltaIdentifier: String,
        operation: Operation,
        communicationPattern: CommunicationPattern,
        absolutePath: String,
        parameters: [Parameter],
        response: TypeInformation,
        errors: [ErrorCode]
    ) {
        self.init(
            handlerName: handlerName.rawValue,
            deltaIdentifier: deltaIdentifier,
            operation: operation,
            communicationPattern: communicationPattern,
            absolutePath: absolutePath,
            parameters: parameters,
            response: response,
            errors: errors
        )
    }

    public mutating func add<Identifier: EndpointIdentifier>(identifier: Identifier) {
        self.identifiers.add(identifier: identifier)
    }

    public mutating func add(anyIdentifier: AnyElementIdentifier) {
        self.identifiers.add(anyIdentifier: anyIdentifier)
    }

    public func identifierIfPresent<Identifier: EndpointIdentifier>(for type: Identifier.Type = Identifier.self) -> Identifier? {
        identifiers.identifierIfPresent(for: type)
    }

    public func identifier<Identifier: EndpointIdentifier>(for type: Identifier.Type = Identifier.self) -> Identifier {
        identifiers.identifier(for: type)
    }
    
    public mutating func dereference(in typeStore: TypesStore) {
        response = typeStore.construct(from: response)
        self.parameters = parameters.map {
            var param = $0
            param.dereference(in: typeStore)
            return param
        }
    }
    
    public mutating func reference(in typeStore: inout TypesStore) {
        response = typeStore.store(response)
        self.parameters = parameters.map {
            var param = $0
            param.reference(in: &typeStore)
            return param
        }
    }
    
    /// Returns a version of self where occurrences of type information (response or parameters) are references
    public func referencedTypes() -> Endpoint {
        var retValue = self
        var typesStore = TypesStore()
        retValue.reference(in: &typesStore)
        return retValue
    }
}

// MARK: Codable
extension Endpoint: Codable {
    private enum CodingKeys: String, CodingKey {
        case deltaIdentifier
        case identifiers
        case communicationPattern
        // To enable an import of previously encoded documents. Remove in the next version bump.
        case communicationalPattern
        case parameters
        case response
        case errors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.deltaIdentifier = try container.decode(DeltaIdentifier.self, forKey: .deltaIdentifier)
        self.identifiers = try container.decode(ElementIdentifierStorage.self, forKey: .identifiers)
        if container.allKeys.contains(.communicationalPattern) {
            self.communicationPattern = try container.decode(CommunicationPattern.self, forKey: .communicationalPattern)
        } else {
            self.communicationPattern = try container.decode(CommunicationPattern.self, forKey: .communicationPattern)
        }
        self.parameters = try container.decode([Parameter].self, forKey: .parameters)
        self.response = try container.decode(TypeInformation.self, forKey: .response)
        self.errors = try container.decode([ErrorCode].self, forKey: .errors)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(deltaIdentifier, forKey: .deltaIdentifier)
        try container.encode(identifiers, forKey: .identifiers)
        try container.encode(communicationPattern, forKey: .communicationPattern)
        try container.encode(parameters, forKey: .parameters)
        try container.encode(response, forKey: .response)
        try container.encode(errors, forKey: .errors)
    }
}

// MARK: Equatable
extension Endpoint: Equatable {
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        var lhsIdentifiers = lhs.identifiers
        var rhsIdentifiers = rhs.identifiers
        lhsIdentifiers.sort()
        rhsIdentifiers.sort()

        return lhs.deltaIdentifier == rhs.deltaIdentifier
            && lhsIdentifiers == rhsIdentifiers
            && lhs.communicationPattern == rhs.communicationPattern
            && lhs.parameters == rhs.parameters
            && lhs.response == rhs.response
            && lhs.errors == rhs.errors
    }
}
