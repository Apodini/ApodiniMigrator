//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct MetaDataComparator: Comparator {
    let lhs: MetaData
    let rhs: MetaData
    let changes: ChangeContainer
    
    var configuration: EncoderConfiguration
    
    init(lhs: MetaData, rhs: MetaData, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
    }
    
    func compare() {
        let element: ChangeElement = .networking
        
        if lhs.versionedServerPath != rhs.versionedServerPath {
            changes.add(
                ValueChange(
                    element: element,
                    target: .serverPath,
                    from: .string(lhs.versionedServerPath),
                    to: .string(rhs.versionedServerPath),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        let lhsEncoderConfig = lhs.encoderConfiguration
        let rhsEncoderConfig = rhs.encoderConfiguration
        
        if lhsEncoderConfig != rhsEncoderConfig {
            changes.add(
                ValueChange(
                    element: element,
                    target: .encoderConfiguration,
                    from: .json(of: lhsEncoderConfig),
                    to: .json(of: rhsEncoderConfig),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        let lhsDecoderConfig = lhs.decoderConfiguration
        let rhsDecoderConfig = rhs.decoderConfiguration
        
        if lhsDecoderConfig != rhsDecoderConfig {
            changes.add(
                ValueChange(
                    element: element,
                    target: .decoderConfiguration,
                    from: .json(of: lhsDecoderConfig),
                    to: .json(of: rhsDecoderConfig),
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
