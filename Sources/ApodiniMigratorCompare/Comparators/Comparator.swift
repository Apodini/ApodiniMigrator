//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation


protocol Comparator {
    associatedtype Element: Value
    
    var lhs: Element { get }
    var rhs: Element { get }
    
    var changes: ChangeContainer { get }
    
    var configuration: EncoderConfiguration { get }
    
    func compare()
}

extension Comparator {
    
    func reference(_ typeInformation: TypeInformation) -> TypeInformation {
        switch typeInformation {
        case .scalar: return typeInformation
        case let .repeated(element):
            return .repeated(element: reference(element))
        case let .dictionary(key, value):
            return .dictionary(key: key, value: reference(value))
        case let .optional(wrappedValue):
            return .optional(wrappedValue: reference(wrappedValue))
        case .enum, .object:
            return .reference(.init(typeInformation.typeName.name))
        case .reference:
            fatalError("Attempted to reference a reference")
        }
    }
}
