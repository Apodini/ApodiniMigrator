//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public struct NameStringInterpolation: StringInterpolationProtocol {
    public typealias StringLiteralType = String

    var components: [NameComponent]

    public init(literalCapacity: Int, interpolationCount: Int) {
        self.components = []
    }

    private mutating func appendString(_ string: String, name: String) {
        precondition(!string.contains("___"), "Placeholder replacements cannot be constructed via \(name)!")
        components.append(string)
    }

    public mutating func appendLiteral(_ literal: String) {
        appendString(literal, name: "string literals")
    }

    public mutating func appendInterpolation(_ value: Placeholder) {
        components.append(value)
    }

    public mutating func appendInterpolation<T: CustomStringConvertible>(_ value: T) {
        appendString(value.description, name: "CustomStringConvertible")
    }

    public mutating func appendInterpolation<T>(_ value: T) {
        appendString("\(value)", name: "\(T.self)")
    }

    public mutating func appendInterpolation(_ value: Any.Type) {
        appendString("\(value)", name: "\(type(of: value))")
    }
}
