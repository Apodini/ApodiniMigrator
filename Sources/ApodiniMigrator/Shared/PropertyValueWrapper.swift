//
//  PropertyValueWrapper.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// A protocol used to restrict values passed to `PropertyValueWrapper`
public protocol PropertyProtocol: Value {}

extension String: PropertyProtocol {}
extension Bool: PropertyProtocol {}
extension Int: PropertyProtocol {}

public class PropertyValueWrapper<P: PropertyProtocol>: Value {
    /// Value
    public let value: P

    /// Initializes self from a value
    public init(_ value: P) {
        self.value = value
    }
    
    /// Encodes self into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    public required init(from decoder: Decoder) throws {
        value = try decoder.singleValueContainer().decode(P.self)
    }
}

extension PropertyValueWrapper: Comparable where P: Comparable {
    /// :nodoc:
    public static func < (lhs: PropertyValueWrapper, rhs: PropertyValueWrapper) -> Bool {
        lhs.value < rhs.value
    }
}

public extension PropertyValueWrapper {
    /// :nodoc:
    static func == (lhs: PropertyValueWrapper<P>, rhs: PropertyValueWrapper<P>) -> Bool {
        lhs.value == rhs.value
    }

    /// :nodoc:
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
