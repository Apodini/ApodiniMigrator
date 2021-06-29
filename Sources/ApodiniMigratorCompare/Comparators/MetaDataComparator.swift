//
//  MetaDataComparator.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

struct MetaDataComparator: Comparator {
    let lhs: MetaData
    let rhs: MetaData
    let changes: ChangeContextNode
    var configuration: EncoderConfiguration
    
    func compare() {
        func element(_ target: NetworkingTarget) -> ChangeElement {
            .networking(target: target)
        }
        
        if lhs.versionedServerPath != rhs.versionedServerPath {
            changes.add(
                UpdateChange(
                    element: element(.serverPath),
                    from: .stringValue(lhs.versionedServerPath),
                    to: .stringValue(rhs.versionedServerPath),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        let lhsEncoderConfig = lhs.encoderConfiguration
        let rhsEncoderConfig = rhs.encoderConfiguration
        
        if lhsEncoderConfig != rhsEncoderConfig {
            changes.add(
                UpdateChange(
                    element: element(.encoderConfiguration),
                    from: .element(lhsEncoderConfig),
                    to: .element(rhsEncoderConfig),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        let lhsDecoderConfig = lhs.decoderConfiguration
        let rhsDecoderConfig = rhs.decoderConfiguration
        
        if lhsDecoderConfig != rhsDecoderConfig {
            changes.add(
                UpdateChange(
                    element: element(.decoderConfiguration),
                    from: .element(lhsDecoderConfig),
                    to: .element(rhsDecoderConfig),
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
