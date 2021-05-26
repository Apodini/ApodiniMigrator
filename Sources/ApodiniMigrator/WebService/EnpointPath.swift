//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

public enum PathComponent: CustomStringConvertible, Value {
    case string(String)
    case parameter(String)
    
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
    
    public init(from decoder: Decoder) throws {
        self = Self(stringValue: try decoder.singleValueContainer().decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
}

public typealias Components = [Int: PathComponent]

public struct EndpointPath: Value, CustomStringConvertible {
    /// Separator of components
    private static let separator = "/"
    
    /// Components of the path
    let components: Components
    
    /// Only indexed string components of the path
    var stringComponents: Components {
        components.filter { $0.value.isString }.filter { $0.key != 0 }
    }
    
    /// String representation of the path
    public var description: String {
        Self.separator + components.sorted(by: \.key)
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
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try container.encode(description)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self = Self(try container.decode(String.self))
    }
    
    public static func == (lhs: EndpointPath, rhs: EndpointPath) -> Bool {
        lhs.stringComponents == rhs.stringComponents
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stringComponents)
    }
}

extension String {
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
