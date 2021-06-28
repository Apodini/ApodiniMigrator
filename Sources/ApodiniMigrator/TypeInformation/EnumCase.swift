//
//  EnumCase.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation


public enum RawValueType: String, Value, CustomStringConvertible {
    case int
    case string
    
    public var description: String {
        rawValue.upperFirst
    }
    
    init<R: RawRepresentable>(_ rawRepresentable: R.Type) {
        let rawValueTypeString = String(describing: R.RawValue.self)
        if let rawValueType = Self(rawValue: rawValueTypeString.lowerFirst) {
            self = rawValueType
        } else {
            fatalError("\(R.RawValue.self) is currently not supported")
        }
    }
}

public struct EnumCase: Value {
    public let name: String
    public let rawValue: String
    
    public init(_ name: String) {
        self.name = name
        self.rawValue = name
    }
    
    public init(_ name: String, rawValue: String) {
        self.name = name
        self.rawValue = rawValue
    }
}

extension EnumCase: DeltaIdentifiable {
    public var deltaIdentifier: DeltaIdentifier { .init(name) }
}

public extension EnumCase {
    static func `case`(_ name: String) -> EnumCase {
        .init(name)
    }
}
