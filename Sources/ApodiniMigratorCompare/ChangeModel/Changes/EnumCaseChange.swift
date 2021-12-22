//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public typealias EnumCaseChange = Change<EnumCase>

extension EnumCase: ChangeableElement {
    public typealias Update = EnumCaseUpdateChange
}

public enum EnumCaseUpdateChange {
    case rawValue( // TODO string vs int?
        from: String,
        to: String
    )
}

extension EnumCaseUpdateChange: Codable, Equatable {
    private enum UpdateType: String, Codable {
        case rawValue
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case from
        case to
    }

    private var type: UpdateType {
        .rawValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(UpdateType.self, forKey: .type)
        switch type {
        case .rawValue:
            self = .rawValue(
                from: try container.decode(String.self, forKey: .from),
                to: try container.decode(String.self, forKey: .to)
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        switch self {
        case let .rawValue(from, to):
            try container.encode(from, forKey: .from)
            try container.encode(to, forKey: .to)
        }
    }
}