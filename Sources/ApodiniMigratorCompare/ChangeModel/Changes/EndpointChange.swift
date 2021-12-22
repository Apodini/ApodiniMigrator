// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public typealias EndpointChange = Change<Endpoint>

extension Endpoint: ChangeableElement {
    public typealias Update = EndpointUpdateChange
}

public enum EndpointUpdateChange: Equatable {
    /// type: see ``EndpointIdentifier``
    case identifier(identifier: EndpointIdentifierChange)

    case communicationalPattern(
        from: CommunicationalPattern,
        to: CommunicationalPattern
    )

    case response(
        // TODO checking, if this change is due to name change! (affects provider support!)
        from: TypeInformation,
        to: TypeInformation, // TODO annotate: reference or scalar
        backwardsConversion: Int, // TODO we only have conversion in one direction
        // TODO reanme "migration"
        conversionWarning: String? = nil
    )

    case parameter(
        parameter: ParameterChange
        // TODO anything other than that?
        // TODO this nesting duplicates required and solvable parameters!

    )

    // TODO errors?
}

extension EndpointUpdateChange: Codable {
    private enum UpdateType: String, Codable {
        case identifier
        case communicationalPattern
        case response
        case parameter
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case identifier

        case from
        case to

        case backwardsConversion
        case conversionWarning

        case parameter
    }

    private var type: UpdateType {
        switch self {
        case .identifier:
            return .identifier
        case .communicationalPattern:
            return .communicationalPattern
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
                identifier: try container.decode(EndpointIdentifierChange.self, forKey: .identifier)
            )
        case .communicationalPattern:
            self = .communicationalPattern(
                from: try container.decode(CommunicationalPattern.self, forKey: .from),
                to: try container.decode(CommunicationalPattern.self, forKey: .to)
            )
        case .response:
            self = .response(
                from: try container.decode(TypeInformation.self, forKey: .from),
                to: try container.decode(TypeInformation.self, forKey: .to),
                backwardsConversion: try container.decode(Int.self, forKey: .backwardsConversion),
                conversionWarning: try container.decodeIfPresent(String.self, forKey: .conversionWarning)
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
        case let .communicationalPattern(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        case let .response(from, to, backwardsConversion, conversionWarning):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encode(backwardsConversion, forKey: .backwardsConversion)
            try container.encodeIfPresent(conversionWarning, forKey: .conversionWarning)
        case let .parameter(parameter):
            try container.encode(parameter, forKey: .parameter)
        }
    }
}
