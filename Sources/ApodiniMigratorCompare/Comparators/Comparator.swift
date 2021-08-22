//
//  Comparator.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 23.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
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
