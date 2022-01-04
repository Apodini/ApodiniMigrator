//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// ``Change`` type which is related to a `TypeProperty`.
/// `.update` changes are encoded as ``PropertyUpdateChange``.
public typealias PropertyChange = Change<TypeProperty>

extension TypeProperty: ChangeableElement {
    public typealias Update = PropertyUpdateChange
}

public enum PropertyUpdateChange: Equatable {
    /// Describes an update to the property necessity.
    case necessity(
        from: Necessity,
        to: Necessity,
        necessityMigration: Int
    )

    /// Describes an update to the property type.
    case type(
        from: TypeInformation,
        to: TypeInformation,
        forwardMigration: Int,
        backwardMigration: Int,
        conversionWarning: String?
    )
}

extension PropertyUpdateChange: Codable {
    private enum UpdateType: String, Codable {
        case necessity
        case type
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case from
        case to
        case necessityMigration

        case forwardMigration
        case backwardMigration
        case conversionWarning
    }

    private var type: UpdateType {
        switch self {
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
                backwardMigration: try container.decode(Int.self, forKey: .backwardMigration),
                conversionWarning: try container.decodeIfPresent(String.self, forKey: .conversionWarning)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        switch self {
        case let .necessity(from, to, necessityMigration):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encode(necessityMigration, forKey: .necessityMigration)
        case let .type(from, to, forwardMigration, backwardMigration, conversionWarning):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encode(forwardMigration, forKey: .forwardMigration)
            try container.encode(backwardMigration, forKey: .backwardMigration)
            try container.encodeIfPresent(conversionWarning, forKey: .conversionWarning)
        }
    }
}
