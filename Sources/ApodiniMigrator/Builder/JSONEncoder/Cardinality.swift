//
//  Cardinality.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

enum Cardinality {
    case exactlyOne(Any.Type)
    case repeated(Any.Type)
    case optional(Any.Type)
    case dictionary(key: Any.Type, value: Any.Type)
    
    var nestedType: Any.Type {
        switch self {
        case let .exactlyOne(type):
            return type
        case let .optional(type):
            return type
        case let .repeated(type):
            return type
        case let .dictionary(_, value):
            return value
        }
    }
    
    var isExactlyOne: Bool {
        if case .exactlyOne = self {
            return true
        }
        return false
    }
    
    var isRepeated: Bool {
        if case .repeated = self {
            return true
        }
        return false
    }
    
    var isOptional: Bool {
        if case .optional = self {
            return true
        }
        return false
    }
    
    var isDictionary: Bool {
        if case .dictionary = self {
            return true
        }
        return false
    }
    
    func primitive() throws -> TypeInformation? {
        switch self {
        case let .exactlyOne(type):
            if let primitiveType = PrimitiveType(type) {
                return .scalar(primitiveType)
            }
        case let .repeated(type):
            if let primitiveType = PrimitiveType(type) {
                return .repeated(element: .scalar(primitiveType))
            }
        case let .optional(type):
            if let primitiveType = PrimitiveType(type) {
                return .optional(wrappedValue: .scalar(primitiveType))
            }
        case .dictionary(key: let key, value: let value):
            guard let primitiveKey = PrimitiveType(key) else {
                throw TypeInformation.TypeInformationError.notSupportedDictionaryKeyType
            }
            if let primitiveValue = PrimitiveType(value) {
                return .dictionary(key: primitiveKey, value: .scalar(primitiveValue))
            }
        }
        return nil
    }
}


// MARK: - CustomStringConvertible + CustomDebugStringConvertible
extension Cardinality: CustomStringConvertible, CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .exactlyOne(let type):
            return String(describing: type)
        case .optional(let type):
            return ".optional(\(String(describing: type)))"
        case .repeated(let type):
            return ".repeated(\(String(describing: type)))"
        case .dictionary(key: let key, value: let value):
            return ".dictionary(key: \(String(describing: key)), value: \(String(describing: value)))"
        }
    }
    
    public var description: String {
        debugDescription
    }
}

// MARK: - Equatable
extension Cardinality: Equatable {
    static func == (lhs: Cardinality, rhs: Cardinality) -> Bool {
        switch (lhs, rhs) {
        case let (.exactlyOne(lhsType), .exactlyOne(rhsType)):
            return lhsType == rhsType
        case let (.repeated(lhsType), .repeated(rhsType)):
            return lhsType == rhsType
        case let (.optional(lhsType), .optional(rhsType)):
            return lhsType == rhsType
        case let (.dictionary(lhsKeyType, lhsValueType), .dictionary(rhsKeyType, rhsValueType)):
            return lhsKeyType == rhsKeyType && lhsValueType == rhsValueType
        default: return false
        }
    }
}
