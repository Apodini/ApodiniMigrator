//
//  File.swift
//  
//
//  Created by Eldi Cano on 14.06.21.
//

import Foundation

struct ParameterComparator: Comparator {
    let lhs: Parameter
    let rhs: Parameter
    let changes: ChangeContextNode
    let configuration: EncoderConfiguration
    var lhsEndpoint: Endpoint?
    
    private var element: ChangeElement {
        guard let lhsEndpoint = lhsEndpoint else {
            fatalError("Endpoint of `lhs` parameter not injected")
        }
        return .for(endpoint: lhsEndpoint, target: .target(for: lhs))
    }
    
    private var targetID: DeltaIdentifier {
        lhs.deltaIdentifier
    }
    
    init(lhs: Parameter, rhs: Parameter, changes: ChangeContextNode, configuration: EncoderConfiguration, lhsEndpoint: Endpoint) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
        self.lhsEndpoint = lhsEndpoint
    }
    
    func compare() {
        if lhs.necessity != rhs.necessity {
            changes.add(
                UpdateChange(
                    element: element,
                    from: .element(lhs.necessity),
                    to: .element(rhs.necessity),
                    targetID: targetID,
                    necessityValue: rhs.necessity == .required ? .value(from: rhs.typeInformation, with: configuration, changes: changes) : nil,
                    parameterTarget: .necessity,
                    breaking: rhs.necessity == .required,
                    solvable: true
                )
            )
        }
        
        if lhs.parameterType != rhs.parameterType {
            changes.add(
                UpdateChange(
                    element: element,
                    from: .element(lhs.parameterType),
                    to: .element(rhs.parameterType),
                    targetID: targetID,
                    parameterTarget: .kind,
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        let lhsType = lhs.typeInformation
        let rhsType = rhs.typeInformation
        
        if typesNeedConvert(lhs: lhsType, rhs: rhsType) {
            let jsScriptBuilder = JSScriptBuilder(from: lhsType, to: rhsType, changes: changes, encoderConfiguration: configuration)
            changes.add(
                UpdateChange(
                    element: element,
                    from: .element(reference(lhsType)),
                    to: .element(reference(rhsType)),
                    targetID: targetID,
                    convertFromTo: changes.store(script: jsScriptBuilder.convertFromTo),
                    convertionWarning: jsScriptBuilder.hint,
                    parameterTarget: .typeInformation,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
