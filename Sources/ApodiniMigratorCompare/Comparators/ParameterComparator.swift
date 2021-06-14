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
        return .for(endpoint: lhsEndpoint)
    }
    
    private var target: ChangeTarget {
        .target(for: lhs.parameterType)
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
    
    init(lhs: Parameter, rhs: Parameter, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
    }
    
    init(lhs: Parameter, rhs: Parameter, changes: ChangeContainer, configuration: EncoderConfiguration, lhsEndpoint: Endpoint) {
        self.init(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        self.lhsEndpoint = lhsEndpoint
    }
    
    func compare() {
        if lhs.necessity != rhs.necessity {
            changes.add(
                ParameterChange(
                    element: element,
                    target: target,
                    identifier: lhs.deltaIdentifier,
                    parameterTarget: .necessity,
                    from: .string(lhs.necessity.rawValue),
                    to: .string(lhs.necessity.rawValue),
                    breaking: rhs.necessity == .required,
                    solvable: true
                )
            )
        }
        
        if lhs.parameterType != rhs.parameterType {
            changes.add(
                ParameterChange(
                    element: element,
                    target: target,
                    identifier: lhs.deltaIdentifier,
                    parameterTarget: .kind,
                    from: .string(lhs.parameterType.rawValue),
                    to: .string(lhs.parameterType.rawValue),
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        if typeInformationHasChanged {
            changes.add(
                ParameterChange(
                    element: element,
                    target: target,
                    identifier: lhs.deltaIdentifier,
                    parameterTarget: .typeInformation,
                    from: .json(of: lhs.typeInformation),
                    to: .json(of: rhs.typeInformation),
                    convertFunction: "TODO Add js function",
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
}
