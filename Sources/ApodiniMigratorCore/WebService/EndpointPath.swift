//
//  EndpointPath.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents distinct cases of a path component
public enum PathComponent: CustomStringConvertible, Value {
    /// A string path component
    case string(String)
    /// A path parameter path component
    case parameter(String)
    
    /// String representation of self
    public var description: String {
        switch self {
        case let .string(value): return value
        case let .parameter(value): return value.asPathParameterComponent
        }
    }
    
    var isParameter: Bool {
        if case .parameter = self {
            return true
        }
        return false
    }
    
    var isString: Bool {
        !isParameter
    }
    
    init(stringValue: String) {
        self = stringValue.isPathParameterComponent ? .parameter(stringValue.dropCurlyBrackets) : .string(stringValue)
    }
    
    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public init(from decoder: Decoder) throws {
        self = Self(stringValue: try decoder.singleValueContainer().decode(String.self))
    }
    
    /// Encodes this value into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
}

/// A typealias for a dictionary with Int keys and PathComponent values
public typealias Components = [Int: PathComponent]

/// Represents an endpoint path
public struct EndpointPath: Value, CustomStringConvertible {
    /// Separator of components
    private static let separator = "/"
    
    /// Components of the path
    let components: Components
    
    /// String representation of the path
    public var description: String {
        Self.separator + components.sorted(by: \.key)
            .map { "\($0.value)" }
            .joined(separator: Self.separator)
    }
    
    /// Path excluding the first component which corresponds to the version of the web service
    public var resourcePath: String {
        components
            .filter { $0.key != 0 }
            .sorted(by: \.key)
            .map { "\($0.value)" }
            .joined(separator: Self.separator)
    }

    /// Initializes an instance out of string representation of the path e.g. `/v1/users/{id}`
    public init(_ string: String) {
        var components: Components = .init()
        string
            .split(string: Self.separator, ignoreEmptyComponents: true)
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

private extension String {
    var isPathParameterComponent: Bool {
        first == "{" && last == "}"
    }
    
    var dropCurlyBrackets: String {
        without("{").without("}")
    }
    
    var asPathParameterComponent: String {
        isPathParameterComponent ? self : "{" + self + "}"
    }
}
