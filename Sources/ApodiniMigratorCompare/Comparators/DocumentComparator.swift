//
//  DocumentComparator.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

struct DocumentComparator: Comparator {
    let lhs: Document
    let rhs: Document
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    
    var currentEncoderConfiguration: EncoderConfiguration {
        rhs.metaData.encoderConfiguration
    }
    
    /// Perhaps consider comparing all models here already, olddoc.allModels, vs newDoc.allModels, Content compare can be skipped from endpoints
    func compare() {
        let metaDataComparator = MetaDataComparator(lhs: lhs.metaData, rhs: rhs.metaData, changes: changes, configuration: configuration)
        metaDataComparator.compare()
        
        let modelsComparator = ModelsComparator(
            lhs: lhs.allModels(),
            rhs: changes.set(rhsModels: rhs.allModels()),
            changes: changes,
            configuration: configuration
        )
        modelsComparator.compare()
        
        let endpointsComparator = EndpointsComparator(lhs: lhs.endpoints, rhs: rhs.endpoints, changes: changes, configuration: configuration)
        endpointsComparator.compare()
    }
}
