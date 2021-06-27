//
//  Comparator.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation


protocol Comparator {
    associatedtype Element: Value
    
    var lhs: Element { get }
    var rhs: Element { get }
    
    var changes: ChangeContextNode { get }
    
    var configuration: EncoderConfiguration { get }
    
    func compare()
}

extension Comparator {
    var includeProviderSupport: Bool {
        changes.compareConfiguration?.includeProviderSupport == true
    }
    
    var allowEndpointIdentifierUpdate: Bool {
        changes.compareConfiguration?.allowEndpointIdentifierUpdate == true
    }
    
    var allowTypeRename: Bool {
        changes.compareConfiguration?.allowTypeRename == true
    }
    
    func sameNestedTypes(lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        if lhs.typeName.name == rhs.typeName.name {
            return true
        }
        return allowTypeRename ? changes.typesAreRenamings(lhs: lhs, rhs: rhs) : false
    }
    
    func typesNeedConvert(lhs: TypeInformation, rhs: TypeInformation) -> Bool {
        let sameNestedType = sameNestedTypes(lhs: lhs, rhs: rhs)
        return (sameNestedType && !lhs.sameType(with: rhs)) || !sameNestedType
    }
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
        case .reference: fatalError("Attempted to reference a reference")
        }
    }
}
