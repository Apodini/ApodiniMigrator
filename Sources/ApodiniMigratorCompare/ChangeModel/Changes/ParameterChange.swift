//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// ``Change`` type which is related to a `Parameter`.
/// `.update` changes are encoded as ``ParameterUpdateChange``.
public typealias ParameterChange = Change<Parameter>

extension Parameter: ChangeableElement {
    public typealias Update = ParameterUpdateChange
}

public enum ParameterUpdateChange: Equatable {
    /// Describes an update of the `ParameterType`
    case parameterType(
        from: ParameterType,
        to: ParameterType
    )

    /// Describes an update of the parameter `Necessity`.
    case necessity(
        from: Necessity,
        to: Necessity,
        necessityMigration: Int
    )

    /// Describes an update of the parameter type.
    case type(
        from: TypeInformation,
        to: TypeInformation,
        forwardMigration: Int,
        migrationWarning: String?
    )
}

extension ParameterUpdateChange: Codable {
    private enum UpdateType: String, Codable {
        case parameterType
        case necessity
        case type
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case from
        case to

        case necessityMigration

        case forwardMigration
        case conversionWarning
    }

    private var type: UpdateType {
        switch self {
        case .parameterType:
            return .parameterType
        case .necessity:
            return .necessity
        case .type:
            return .type
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(UpdateType.self, forKey: .type)
        switch type {
        case .parameterType:
            self = .parameterType(
                from: try container.decode(ParameterType.self, forKey: .from),
                to: try container.decode(ParameterType.self, forKey: .to)
            )
        case .necessity:
            self = .necessity(
                from: try container.decode(Necessity.self, forKey: .from),
                to: try container.decode(Necessity.self, forKey: .to),
                necessityMigration: try container.decode(Int.self, forKey: .necessityMigration)
            )
        case .type:
            self = .type(
                from: try container.decode(TypeInformation.self, forKey: .from),
                to: try container.decode(TypeInformation.self, forKey: .to),
                forwardMigration: try container.decode(Int.self, forKey: .forwardMigration),
                migrationWarning: try container.decodeIfPresent(String.self, forKey: .conversionWarning)
            )
        }
    }


    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        switch self {
        case let .parameterType(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        case let .necessity(from, to, necessityMigration):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encodeIfPresent(necessityMigration, forKey: .necessityMigration)
        case let .type(from, to, forwardMigration, migrationWarning):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encode(forwardMigration, forKey: .forwardMigration)
            try container.encodeIfPresent(migrationWarning, forKey: .conversionWarning)
        }
    }
}
