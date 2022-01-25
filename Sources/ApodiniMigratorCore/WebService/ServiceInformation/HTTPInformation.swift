//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public enum HTTPProtocol: String, CustomStringConvertible, Value {
    case http
    case https

    public var description: String {
        "\(rawValue)://"
    }
}

public struct HTTPInformation: Value, CustomStringConvertible {
    public var description: String {
        "\(`protocol`)\(hostname):\(port)"
    }

    public let `protocol`: HTTPProtocol
    public let hostname: String
    public let port: Int

    public init(protocol: HTTPProtocol = .http, hostname: String, port: Int = 80) {
        self.protocol = `protocol`
        self.hostname = hostname
        self.port = port
    }
}
