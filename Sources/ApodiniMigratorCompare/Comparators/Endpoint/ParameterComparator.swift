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
    let changes: ChangeContainer
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
    
    // Since when comparing type information of parameters we might encounter complex types, the comparison
    // should not be done on the type information directly since that is being handled by ModelsComparator.
    // In the context of parameter comparison, the comparison is done on the type name of the parameter.
    // This means, if primitive types are involved, those are considered equal if the type names are equal
    // If complex types are involved, we perform a relaxed equatability on the typeNames allowing a degree
    // of similarity due to potential renamings. Only if this property returns true, a parameter change that
    // requires a javascript convert is registered
    private var typeInformationHasChanged: Bool {
        !(lhs.typeInformation.sameType(with: rhs.typeInformation) && (lhs.typeInformation.typeName ?= rhs.typeInformation.typeName))
    }
    
    init(lhs: Parameter, rhs: Parameter, changes: ChangeContainer, configuration: EncoderConfiguration, lhsEndpoint: Endpoint) {
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
        
        /// TODO request from change container whether the type has been renamed and check whether the name is not equal
        if typeInformationHasChanged {
            let jsConverter = JSScriptBuilder(from: lhs.typeInformation, to: rhs.typeInformation, changes: changes)
            changes.add(
                UpdateChange(
                    element: element,
                    from: .id(from: lhs),
                    to: .element(rhs.typeInformation),
                    targetID: targetID,
                    convertTo: jsConverter.convertFromTo,
                    parameterTarget: .typeInformation,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
