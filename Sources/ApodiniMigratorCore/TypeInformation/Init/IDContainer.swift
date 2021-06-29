//
//  IDContainer.swift
//  ApodiniMigratorCore
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

struct IDContainer: Hashable {
    let rootType: Any.Type
    let idType: Any.Type
    
    var rootTypeIdentifier: ObjectIdentifier { .init(rootType) }
    var idIdentifier: ObjectIdentifier { .init(idType) }
    
    init(_ propertyInfo: RuntimeProperty) {
        guard propertyInfo.isIDProperty else {
            fatalError("Attempted to initialize an IDContainer with a non ID property")
        }
        self.rootType = propertyInfo.ownerType
        self.idType = propertyInfo.genericTypes[1]
    }
    
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
    
    mutating func add(_ property: RuntimeProperty) {
        insert(.init(property))
    }
}
