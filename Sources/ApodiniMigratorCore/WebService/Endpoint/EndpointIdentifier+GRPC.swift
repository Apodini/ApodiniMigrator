//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct GRPCServiceName: EndpointIdentifier, CustomStringConvertible {
    public var rawValue: String {
        serviceName
    }

    public var description: String {
        serviceName
    }

    public let serviceName: String

    public init(_ serviceName: String) {
        self.serviceName = serviceName
    }

    public init(rawValue: String) {
        self.serviceName = rawValue
    }
}

public struct GRPCMethodName: EndpointIdentifier, CustomStringConvertible {
    public var rawValue: String {
        methodName
    }

    public var description: String {
        methodName
    }

    public let methodName: String

    public init(_ methodName: String) {
        self.methodName = methodName
    }

    public init(rawValue: String) {
        self.methodName = rawValue
    }
}
