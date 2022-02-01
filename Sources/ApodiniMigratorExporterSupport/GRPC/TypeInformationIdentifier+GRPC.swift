//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO documentation?

public struct GRPCName: TypeInformationIdentifier {
    public let rawValue: String

    // TODO do we need more context or can we just split it when processing?

    public init(_ name: String) {
        self.rawValue = name
    }

    public init(rawValue: String) {
        self.init(rawValue)
    }
}

public struct GRPCFieldType: TypeInformationIdentifier {
    public let type: Int32

    public var rawValue: String {
        "\(type)"
    }

    public init(type: Int32) {
        self.type = type
    }

    public init?(rawValue: String) {
        if let type = Int32(rawValue) {
            self.type = type
        }
    }
}

public struct GRPCNumber: TypeInformationIdentifier {
    public let number: Int32

    public var rawValue: String {
        "\(number)"
    }

    public init(number: Int32) {
        self.number = number
    }

    public init?(rawValue: String) {
        if let number = Int32(rawValue) {
            self.number = number
        }
    }
}
