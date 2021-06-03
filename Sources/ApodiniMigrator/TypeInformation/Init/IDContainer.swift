//
//  File.swift
//  
//
//  Created by Eldi Cano on 01.06.21.
//

import Foundation

/// Use new PropertyTypeInfo
/// init(propertyTypeInfo) with assert that it is an id property

struct IDContainer: Hashable {
    let rootType: Any.Type
    let idType: Any.Type
    
    var rootTypeIdentifier: ObjectIdentifier { .init(rootType) }
    var idIdentifier: ObjectIdentifier { .init(idType) }
    
    static func == (lhs: IDContainer, rhs: IDContainer) -> Bool {
        lhs.rootTypeIdentifier == rhs.rootTypeIdentifier
            && lhs.idIdentifier == rhs.idIdentifier
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rootTypeIdentifier)
        hasher.combine(idIdentifier)
    }
}

typealias Storage = Set<IDContainer>

extension Storage {
    func idType(of rootType: Any.Type) -> Any.Type? {
        firstMatch(on: \.rootTypeIdentifier, with: ObjectIdentifier(rootType))?.idType
    }
}

