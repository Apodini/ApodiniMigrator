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
        let additionCanditates = rhsProperties.filter { !matchedIds.contains($0.deltaIdentifier) }
        
        for matched in matchedIds {
            if let lhs = lhsProperties.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhsProperties.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
        
        handle(removalCandidates: removalCandidates, additionCandidates: additionCanditates)
    }
    
    private func compare(lhs: TypeProperty, rhs: TypeProperty) {
        let lhsType = lhs.type
        let rhsType = rhs.type
        
        let targetID = lhs.deltaIdentifier
        
        if lhsType.unwrapped ?= rhsType.unwrapped, lhs.optionality != rhs.optionality {
            changes.add(
                UpdateChange(
                    element: element(.propertyOptionality),
                    from: .string(lhs.optionality.rawValue),
                    to: .string(rhs.optionality.rawValue),
                    targetID: targetID,
                    breaking: true,
                    solvable: true
                )
            )
        } else if !(lhsType.sameType(with: rhsType) && (lhsType ?= rhsType)) {
            changes.add(
                PropertyChange(
                    element: element(.property),
                    targetID: targetID,
                    from: reference(lhsType),
                    to: rhsType,
                    convertTo: "TODO Add js function",
                    convertFrom: "TODO Add js function",
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
                    RenameChange(
                        element: element(.property),
                        from: candidate.deltaIdentifier.rawValue,
                        to: relaxedMatching.deltaIdentifier.rawValue,
                        breaking: true,
                        solvable: true
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
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(
                AddChange(
                    element: element(.property),
                    added: .json(of: addition),
                    defaultValue: .value(from: addition.type, with: configuration),
                    breaking: false,
                    solvable: true
                )
            )
        }
    }
    
    private func element(_ target: ChangeTarget) -> ChangeElement {
        .for(model: lhs, target: target)
    }
}
