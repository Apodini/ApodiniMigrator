//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Represents distinct cases of a path component
private enum PathComponent: CustomStringConvertible {
    /// A string path component
    case string(String)
    /// A path parameter path component
    case parameter(String)
    
    /// String representation of self
    // swiftlint:disable:next lower_acl_than_parent
    public var description: String {
        switch self {
        case let .string(value): return value
        case let .parameter(value): return value.asPathParameterComponent
        }
    }
    
    /// Initializes `self` out of a string value
    init(stringValue: String) {
        self = stringValue.isPathParameterComponent ? .parameter(stringValue.dropCurlyBrackets) : .string(stringValue)
    }
}

/// A typealias for a dictionary with Int keys and PathComponent values
private typealias Components = [Int: PathComponent]

/// Represents an endpoint path
public struct EndpointPath: Value, CustomStringConvertible, EndpointIdentifier {
    /// Separator of components
    private static let separator = "/"
    
    /// Components of the path
    private let components: Components
    
    /// String representation of the path
    public var description: String {
        Self.separator + components
            .sorted(by: \.key)
            .map { "\($0.value)" }
            .joined(separator: Self.separator)
    }

    public var rawValue: String {
        description
    }

    public var resourcePath: String {
        components
            .sorted(by: \.key)
            .map { "\($0.value)" }
            .joined(separator: Self.separator)
    }

    public init(rawValue string: String) {
        self.init(string)
    }

    /// Initializes an instance out of string representation of the path e.g. `/v1/users/{id}`
    public init(_ string: String) {
        var components: Components = .init()
        string
            .split(separator: "/")
            .map { String($0) }
            .enumerated()
            .forEach { index, component in
                components[index] = PathComponent(stringValue: component)
            }
        self.components = components
    }
    
    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard string.starts(with: Self.separator) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Not an endpoint path value")
        }
        self = Self(string)
    }
    
    /// Checks equality between lhs and rhs based on respective string components
    public static func == (lhs: EndpointPath, rhs: EndpointPath) -> Bool {
        lhs.resourcePath == rhs.resourcePath
    }
    
    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        hasher.combine(resourcePath)
    }
}

// MARK: - String
private extension String {
    /// Indicates whether self is surrounded by curly brackets
    var isPathParameterComponent: Bool {
        first == "{" && last == "}"
    }
    
    /// Returns a version of self without surrounding curly brackets
    var dropCurlyBrackets: String {
        self
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
    }
    
    /// Returns a version of self with surrounding curly brackets
    var asPathParameterComponent: String {
        isPathParameterComponent ? self : "{" + self + "}"
    }
}
