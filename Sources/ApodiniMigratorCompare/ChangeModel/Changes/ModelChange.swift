//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// ``Change`` type which is related to a Model/`TypeInformation`.
/// `.update` changes are encoded as `ModelUpdateChange`.
/// The type of `TypeInformation` (e.g. enum or object) might be derived from the `APIDocument`.
public typealias ModelChange = Change<TypeInformation>

extension TypeInformation: ChangeableElement {
    public typealias Update = ModelUpdateChange
}

public enum ModelUpdateChange: Equatable {
    // common
    /// Describes a change to the `RootType` of a `TypeInformation` (e.g. object to enum).
    case rootType(
        from: TypeInformation.RootType,
        to: TypeInformation.RootType,
        newModel: TypeInformation
    )

    // .object
    /// Describes a change to the properties of a `.object`.
    case property(property: PropertyChange)

    // .enum
    /// Describes a change to the cases of an `.enum`.
    case `case`(case: EnumCaseChange)

    /// Describes a change to the raw value **type** of an `.enum`.
    /// - Note: This is either a reference or a scalar.
    case rawValueType(
        from: TypeInformation,
        to: TypeInformation
    )

    case identifier(
        identifier: ElementIdentifierChange
    )
}

extension ModelUpdateChange: UpdateChangeWithNestedChange {
    public var isNestedChange: Bool {
        switch self {
        case .property, .case:
            return true
        default:
            return false
        }
    }

    public var nestedBreakingClassification: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        switch self {
        case let .property(property):
            return property.breaking
        case let .case(`case`):
            return `case`.breaking
        default:
            return nil
        }
    }

    public var nestedSolvableClassification: Bool? { // swiftlint:disable:this discouraged_optional_boolean
        switch self {
        case let .property(property):
            return property.solvable
        case let .case(`case`):
            return `case`.solvable
        default:
            return nil
        }
    }
}

extension ModelUpdateChange: Codable {
    private enum UpdateType: String, Codable {
        case rootType
        case property
        case `case`
        case rawValueType
        case identifier
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case from
        case to
        case newModel

        case property

        case `case`

        case identifier
    }

    private var type: UpdateType {
        switch self {
        case .rootType:
            return .rootType
        case .property:
            return .property
        case .case:
            return .case
        case .rawValueType:
            return .rawValueType
        case .identifier:
            return .identifier
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(UpdateType.self, forKey: .type)
        switch type {
        case .rootType:
            self = .rootType(
                from: try container.decode(TypeInformation.RootType.self, forKey: .from),
                to: try container.decode(TypeInformation.RootType.self, forKey: .to),
                newModel: try container.decode(TypeInformation.self, forKey: .newModel)
            )
        case .property:
            self = .property(
                property: try container.decode(PropertyChange.self, forKey: .property)
            )
        case .case:
            self = .case(
                case: try container.decode(EnumCaseChange.self, forKey: .case)
            )
        case .rawValueType:
            self = .rawValueType(
                from: try container.decode(TypeInformation.self, forKey: .from),
                to: try container.decode(TypeInformation.self, forKey: .to)
            )
        case .identifier:
            self = .identifier(
                identifier: try container.decode(ElementIdentifierChange.self, forKey: .identifier)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        switch self {
        case let .rootType(from, to, newModel):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
            try container.encode(newModel, forKey: .newModel)
        case let .property(property):
            try container.encode(property, forKey: .property)
        case let .case(`case`):
            try container.encode(`case`, forKey: .case)
        case let .rawValueType(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        case let .identifier(identifier):
            try container.encode(identifier, forKey: .identifier)
        }
    }
}
