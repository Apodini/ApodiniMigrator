//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct HTTPInformation: Value, LosslessStringConvertible {
    public var description: String {
        "\(hostname):\(port)"
    }

    let hostname: String
    let port: Int

    public init(hostname: String, port: Int = 80) {
        self.hostname = hostname
        self.port = port
    }

    public init?(_ description: String) {
        guard let colonIndex = description.lastIndex(of: ":") else {
            return nil
        }

        self.hostname = String(description[description.startIndex ... colonIndex])

        let portString = String(description[description.index(after: colonIndex) ... description.endIndex])
        guard let port = Int(portString) else {
            return nil
        }
        self.port = port
    }
}
