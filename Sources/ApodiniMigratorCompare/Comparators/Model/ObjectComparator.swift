//
//  File.swift
//  
//
//  Created by Eldi Cano on 14.06.21.
//

import Foundation

struct ObjectComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContainer
    let configuration: EncoderConfiguration
    let lhsProperties: [TypeProperty]
    let rhsProperties: [TypeProperty]
    
    init(lhs: TypeInformation, rhs: TypeInformation, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
        self.lhsProperties = lhs.objectProperties
        self.rhsProperties = rhs.objectProperties
    }
    
    func compare() {
        let matchedIds = lhsProperties.matchedIds(with: rhsProperties)
        let removalCandidates = lhsProperties.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhsProperties.filter { !matchedIds.contains($0.deltaIdentifier) }
        handle(removalCandidates: removalCandidates, additionCandidates: additionCandidates)
        
        for matched in matchedIds {
            if let lhs = lhsProperties.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhsProperties.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
    }
    
    private func compare(lhs: TypeProperty, rhs: TypeProperty) {
        let lhsType = lhs.type
        let rhsType = rhs.type
        
        let targetID = lhs.deltaIdentifier
        
        if sameNestedTypes(lhs: lhsType, rhs: rhsType), lhs.optionality != rhs.optionality {
            changes.add(
                UpdateChange(
                    element: element(.propertyOptionality),
                    from: .element(lhs.optionality),
                    to: .element(rhs.optionality),
                    targetID: targetID,
                    breaking: true,
                    solvable: true
                )
            )
        } else if typesNeedConvert(lhs: lhsType, rhs: rhsType) {
            let jsConverter = JSScriptBuilder(from: lhsType, to: rhsType, changes: changes, encoderConfiguration: configuration)
            changes.add(
                UpdateChange(
                    element: element(.property),
                    from: .element(reference(lhsType)),
                    to: .element(reference(rhsType)),
                    targetID: targetID,
                    convertFromTo: jsConverter.convertFromTo,
                    convertToFrom: jsConverter.convertToFrom,
                    convertionWarning: jsConverter.hint,
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
    
    private func handle(removalCandidates: [TypeProperty], additionCandidates: [TypeProperty]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    UpdateChange(
                        element: element(.property),
                        from: candidate.name,
                        to: relaxedMatching.name,
                        breaking: true,
                        solvable: true,
                        includeProviderSupport: includeProviderSupport
                    )
                )
                
                compare(lhs: candidate, rhs: relaxedMatching)
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(
                DeleteChange(
                    element: element(.property),
                    deleted: .id(from: removal),
                    fallbackValue: .value(from: removal.type, with: configuration),
                    breaking: removal.optionality == .required,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(
                AddChange(
                    element: element(.property),
                    added: .element(addition),
                    defaultValue: .value(from: addition.type, with: configuration),
                    breaking: addition.optionality == .required,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
    }
    
    private func element(_ target: ObjectTarget) -> ChangeElement {
        .for(object: lhs, target: target)
    }
}
