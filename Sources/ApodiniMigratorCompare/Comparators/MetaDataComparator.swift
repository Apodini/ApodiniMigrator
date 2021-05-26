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
    var changes: ChangeContainer
    
    init(lhs: MetaData, rhs: MetaData, changes: ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    func compare() {
        let element = ChangeElement.networking
        
        if lhs.serverPath != rhs.serverPath {
            changes.add(ValueChange(element: element, target: .serverPath, from: .string(lhs.serverPath), to: .string(rhs.serverPath)))
        }
        
        if lhs.version.differentDescription(from: rhs.version) {
            changes.add(ValueChange(element: element, target: .version, from: .jsonString(lhs.version), to: .jsonString(rhs.version)))
        }
        
        let lhsEncoderConfig = lhs.encoderConfiguration
        let rhsEncoderConfig = rhs.encoderConfiguration
        
        if lhsEncoderConfig != rhsEncoderConfig {
            changes.add(ValueChange(element: element, target: .encoderConfiguration, from: .jsonString(lhsEncoderConfig), to: .jsonString(rhsEncoderConfig)))
        }
        
        let lhsDecoderConfig = lhs.decoderConfiguration
        let rhsDecoderConfig = rhs.decoderConfiguration
        
        if lhsDecoderConfig != rhsDecoderConfig {
            changes.add(ValueChange(element: element, target: .decoderConfiguration, from: .jsonString(lhsDecoderConfig), to: .jsonString(rhsDecoderConfig)))
        }
    }
}
