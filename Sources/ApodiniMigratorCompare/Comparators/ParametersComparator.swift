//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct ParametersComparator: Comparator {
    let lhs: Endpoint
    let rhs: Endpoint
    var changes: ChangeContainer
    let lhsParameters: [Parameter]
    let rhsParameters: [Parameter]
    
    var encoderConfiguration: EncoderConfiguration?
    
    private var configuration: EncoderConfiguration {
        guard let configuration = encoderConfiguration else {
            fatalError("Encoder configuration not set")
        }
        return configuration
    }
    
    var element: ChangeElement {
        .for(endpoint: lhs)
    }
    
    init(lhs: Endpoint, rhs: Endpoint, changes: ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.lhsParameters = lhs.parameters
        self.rhsParameters = rhs.parameters
    }
    
    func compare() {
        let matchedIds = lhsParameters.matchedIds(with: rhsParameters)
        
        let removalCandidates = lhsParameters.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhsParameters.filter { !matchedIds.contains($0.deltaIdentifier) }
        
        for matched in matchedIds {
            if let lhs = lhsParameters.firstMatch(on: \.deltaIdentifier, with: matched),
                let rhs = rhsParameters.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
        
        handle(removalCandidates: removalCandidates, additionCandidates: additionCandidates)
    }

    /// Compares parameters with same `deltaIdentifier``s (a.k.a same parameter name)
    func compare(lhs: Parameter, rhs: Parameter) {
        if lhs.sameType(with: rhs), lhs.parameterType == .lightweight {
            return compareLightweightParameters(lhs: lhs, rhs: rhs)
        }
        
        if [lhs.parameterType, rhs.parameterType].contains(.content) {
            return handleContentParameter(for: lhs, and: rhs)
        }
        
        if lhs.sameType(with: rhs) {
        }
        
        // Here we are dealing with parameters that are not of type content -> typeInformation is always .scalar or .optional(.scalar)
        // -> parameter types are always .lightweight, .path or .header
        if !lhs.sameType(with: rhs) {
            changes.add(
                ParameterChange(
                    element: element,
                    target: target(for: lhs.parameterType),
                    identifier: lhs.deltaIdentifier,
                    parameterTarget: .kind,
                    from: .string(lhs.parameterType.rawValue),
                    to: .string(lhs.parameterType.rawValue)
                )
            )
        }
    }
    
    /// Captures changes of necessity if changed to required, or changes in typeinformation of the parameters
    func compareLightweightParameters(lhs: Parameter, rhs: Parameter) {
        if lhs.necessity != rhs.necessity, rhs.necessity == .required { // necessity changed to required
            return changes.add(
                ParameterChange( /// TODO provide default value?
                    element: element,
                    target: .queryParameter,
                    identifier: lhs.deltaIdentifier,
                    parameterTarget: .necessity,
                    from: .string(lhs.necessity.rawValue),
                    to: .string(rhs.necessity.rawValue)
                )
            )
        }
        
        if lhs.typeInformation != rhs.typeInformation { // change, e.g. from Int to String
            /// TODO add convert old to new ???
            changes.add(
                ParameterChange(
                    element: element,
                    target: .queryParameter,
                    identifier: lhs.deltaIdentifier,
                    parameterTarget: .typeInformation,
                    from: .json(of: lhs.typeInformation),
                    to: .json(of: rhs.typeInformation)
                )
            )
        }
    }
    
    func handleContentParameter(for lhs: Parameter, and rhs: Parameter) {
        if lhs.sameType(with: rhs) { // if both parameters are content, changes have to be handled on their type informations
            let typeInformationComaparator = TypeInformationComparator(lhs: lhs.typeInformation, rhs: rhs.typeInformation, changes: changes)
            return typeInformationComaparator.compare()
        }
        
        if lhs.parameterType == .content { // if changed from .content to some other type -> one content parameter deletion and one addition
            changes.add(
                DeleteChange(
                    element: element,
                    target: .contentParameter,
                    deleted: .json(of: lhs),
                    fallbackValue: .value(from: lhs.typeInformation, with: configuration)
                )
            )
            
            let defaultValue = rhs.necessity == .required ? ChangeValue.value(from: rhs.typeInformation, with: configuration) : .none
            changes.add(
                AddChange(
                    element: element,
                    target: target(for: rhs.parameterType),
                    added: .json(of: rhs),
                    defaultValue: defaultValue
                )
            )
        }
        
        if rhs.parameterType == .content { // if changed from some other type to content -> one content parameter addition, and one deletion
            changes.add(
                AddChange(
                    element: element,
                    target: .contentParameter,
                    added: .json(of: rhs),
                    defaultValue: .value(from: rhs.typeInformation, with: configuration)
                )
            )
            changes.add(
                DeleteChange(
                    element: element,
                    target: target(for: lhs.parameterType),
                    deleted: .json(of: lhs),
                    fallbackValue: .none
                )
            )
        }
    }
    
    func handle(removalCandidates: [Parameter], additionCandidates: [Parameter]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        let noCommonElements = Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers())
        assert(noCommonElements, "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    RenameChange(
                        element: element,
                        target: target(for: candidate.parameterType),
                        from: candidate.name,
                        to: relaxedMatching.name
                    )
                )
                compare(lhs: candidate, rhs: relaxedMatching)
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(
                DeleteChange(
                    element: element,
                    target: target(for: removal.parameterType),
                    deleted: .json(of: removal),
                    fallbackValue: .none
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            var defaultValue: ChangeValue?
            if addition.necessity == .required {
                defaultValue = .value(from: addition.typeInformation, with: configuration)
            }
            changes.add(
                AddChange(
                    element: element,
                    target: target(for: addition.parameterType),
                    added: .json(of: addition),
                    defaultValue: defaultValue ?? .none
                )
            )
        }
    }
    
    private func target(for parameterType: ParameterType) -> ChangeTarget {
        switch parameterType {
        case .lightweight: return .queryParameter
        case .content: return .contentParameter
        case .path: return .pathParameter
        case .header: return .headerParameter
        }
    }
}

extension Parameter {
    func sameType(with other: Parameter) -> Bool {
        parameterType == other.parameterType
    }
}
