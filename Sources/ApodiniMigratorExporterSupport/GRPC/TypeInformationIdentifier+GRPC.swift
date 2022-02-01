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

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public struct GRPCFieldType: TypeInformationIdentifier {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
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
        } else {
            return nil
        }
    }
}
