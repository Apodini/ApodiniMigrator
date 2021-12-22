//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public typealias ModelChange = Change<TypeInformation>

extension TypeInformation: ChangeableElement {
    public typealias Update = ModelUpdateChange
}

public enum ModelUpdateChange: Equatable {
    // common
    case rootType(
        from: TypeInformation.RootType,
        to: TypeInformation.RootType,
        newModel: TypeInformation // TODO in MG migrations value UNSUPPORTED
    )

    // .object
    case property(property: PropertyChange)

    // .enum
    case `case`(case: EnumCaseChange)
    // TODO in MG migrations both types have value UNSUPPORTED0, UNSUPPORTED1
    case rawValueType(
        from: TypeInformation, // TODO annotate: reference or scalar
        to: TypeInformation
    )
}

extension ModelUpdateChange: Codable {
    private enum UpdateType: String, Codable {
        case rootType
        case property
        case `case`
        case rawValueType
    }

    private enum CodingKeys: String, CodingKey {
        case type

        case from
        case to
        case newModel

        case property

        case `case`
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
        }
    }
}
