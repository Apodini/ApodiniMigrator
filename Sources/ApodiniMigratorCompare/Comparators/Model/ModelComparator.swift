//
//  ModelComparator.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

struct ModelComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    
    func compare() {
        guard lhs.rootType == rhs.rootType, [TypeInformation.RootType.enum, .object].contains(lhs.rootType) else {
            return changes.add(
                UnsupportedChange(
                    element: lhs.isObject ? .for(object: lhs, target: .`self`) : .for(enum: lhs, target: .`self`),
                    description: "ApodiniMigrator is not able to handle the migration of \(lhs.typeName.name). Change from enum to object or vice versa is currently not supported"
                )
            )
        }
        
        if lhs.rootType == .object {
            let objectComparator = ObjectComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
            objectComparator.compare()
        } else if lhs.rootType == .enum {
            let enumComparator = EnumComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
            enumComparator.compare()
        }
    }
}
