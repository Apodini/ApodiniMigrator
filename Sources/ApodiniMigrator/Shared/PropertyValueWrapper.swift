//
//  File.swift
//  
//
//  Created by Eldi Cano on 29.03.21.
//

import Foundation

/// A protocol used to restrict values passed to `PropertyValueWrapper`
public protocol PropertyProtocol: Value {}

extension String: PropertyProtocol {}
extension Bool: PropertyProtocol {}
extension Int: PropertyProtocol {}

open class PropertyValueWrapper<P: PropertyProtocol>: Value {
    public let value: P

    public init(_ value: P) {
        self.value = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    public required init(from decoder: Decoder) throws {
        value = try decoder.singleValueContainer().decode(P.self)
    }
}

extension PropertyValueWrapper: Comparable where P: Comparable {
    public static func < (lhs: PropertyValueWrapper, rhs: PropertyValueWrapper) -> Bool {
        lhs.value < rhs.value
    }
}

public extension PropertyValueWrapper {
    static func == (lhs: PropertyValueWrapper<P>, rhs: PropertyValueWrapper<P>) -> Bool {
        lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
