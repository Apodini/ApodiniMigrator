// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// ``Change`` type which is related to an `Endpoint`.
/// `.update` changes are encoded as ``EndpointUpdateChange``.
public typealias EndpointChange = Change<Endpoint>

extension Endpoint: ChangeableElement {
    public typealias Update = EndpointUpdateChange
}

public enum EndpointUpdateChange: Equatable {
    /// Describes an update change related to `EndpointIdentifier`s (e.g. Operation, Path or HandlerName).
    /// - Parameters:
    ///   - identifier: The ``EndpointIdentifierChange``.
    case identifier(identifier: ElementIdentifierChange)

    /// Describes an update to the `CommunicationPattern` of the `Endpoint`.
    case communicationPattern(
        from: CommunicationPattern,
        to: CommunicationPattern
    )

    /// Describes an update to the response type of the `Endpoint`.
    /// - Parameters:
    ///   - from: The original `TypeInformation`.
    ///   - to: The updated `TypeInformation`.
    ///   - backwardsMigration: An integer identifier to a json script which provides backwards migration between those types.
    ///   - migrationWarning: An optional textual warning for the migration.
    /// - Note: The TypeInformation are either some sort of `.reference` type (e.g. also repeated types) or a `.scalar`.
    case response(
        from: TypeInformation,
        to: TypeInformation,
        backwardsMigration: Int,
        migrationWarning: String? = nil
    )

    /// Describes an update to a parameter of the `Endpoint`.
    case parameter(
        parameter: ParameterChange
    )
}

extension EndpointUpdateChange: UpdateChangeWithNestedChange {
    public var isNestedChange: Bool {
        if case .parameter = self {
            return true
        }
        return false
    }

    public var nestedBreakingClassification: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        switch self {
        case let .parameter(parameter):
            return parameter.breaking
        default:
            return nil
        }
    }

    public var nestedSolvableClassification: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        switch self {
        case let .parameter(parameter):
            return parameter.solvable
        default:
            return nil
        }
    }
}

extension EndpointUpdateChange: Codable {
    private enum UpdateType: String, Codable {
        case identifier
        case communicationPattern
        case response
        case parameter
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case identifier

        case from
        case to

        case backwardsMigration
        case migrationWarning

        case parameter
    }

    private var type: UpdateType {
        switch self {
        case .identifier:
            return .identifier
        case .communicationPattern:
            return .communicationPattern
        case .response:
            return .response
        case .parameter:
            return .parameter
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(UpdateType.self, forKey: .type)
        switch type {
        case .identifier:
            self = .identifier(
                identifier: try container.decode(ElementIdentifierChange.self, forKey: .identifier)
            )
        case .communicationPattern:
            self = .communicationPattern(
                from: try container.decode(CommunicationPattern.self, forKey: .from),
                to: try container.decode(CommunicationPattern.self, forKey: .to)
            )
        case .response:
            self = .response(
                from: try container.decode(TypeInformation.self, forKey: .from),
                to: try container.decode(TypeInformation.self, forKey: .to),
                backwardsMigration: try container.decode(Int.self, forKey: .backwardsMigration),
                migrationWarning: try container.decodeIfPresent(String.self, forKey: .migrationWarning)
            )
        case .parameter:
            self = .parameter(
                parameter: try container.decode(ParameterChange.self, forKey: .parameter)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        switch self {
        case let .identifier(identifier):
            try container.encode(identifier, forKey: .identifier)
        case let .communicationPattern(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        case let .response(from, to, backwardsMigration, migrationWarning):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encode(backwardsMigration, forKey: .backwardsMigration)
            try container.encodeIfPresent(migrationWarning, forKey: .migrationWarning)
        case let .parameter(parameter):
            try container.encode(parameter, forKey: .parameter)
        }
    }
}
