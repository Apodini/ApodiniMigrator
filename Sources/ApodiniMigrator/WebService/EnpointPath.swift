//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
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
public struct EndpointPath: Value {
    /// Separator of components
    private static let separator = "/"
    
    /// Components of the path
    let components: Components
    
    /// Only indexed string components of the path (ignoring version path component of first position)
    var stringComponents: Components {
        components.filter { $0.value.isString }.filter { $0.key != 0 }
    }
    
    /// String representation of the path
    private var description: String {
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
        
        self = Self(try container.decode(String.self))
    }
    
    /// Checks equality between lhs and rhs based on respective string components
    public static func == (lhs: EndpointPath, rhs: EndpointPath) -> Bool {
        lhs.stringComponents == rhs.stringComponents
    }
    
    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stringComponents)
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
