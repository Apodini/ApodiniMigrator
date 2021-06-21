//
//  File.swift
//  
//
//  Created by Eldi Cano on 14.06.21.
//

import Foundation

struct EnumComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContainer
    let configuration: EncoderConfiguration
    
    func element(_ target: EnumTarget) -> ChangeElement {
        .for(enum: lhs, target: target)
    }
    
    func compare() {
        let enumCasesComparator = EnumCasesComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        enumCasesComparator.compare()
        
        guard let lhsRawValue = lhs.rawValueType, let rhsRawValue = rhs.rawValueType else {
            return
        }
        
        if lhsRawValue != rhsRawValue {
            changes.add(
                UpdateChange(
                    element: element(.rawValueType),
                    from: .element(lhsRawValue),
                    to: .element(rhsRawValue),
                    breaking: true,
                    solvable: false
                )
            )
        }
    }
}


private struct EnumCasesComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContainer
    let configuration: EncoderConfiguration
    let lhsCases: [EnumCase]
    let rhsCases: [EnumCase]
    
    init(lhs: TypeInformation, rhs: TypeInformation, changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
        self.lhsCases = lhs.enumCases
        self.rhsCases = rhs.enumCases
    }
    
    func compare() {
        let matchedIds = lhsCases.matchedIds(with: rhsCases)
        let removalCandidates = lhsCases.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCanditates = rhsCases.filter { !matchedIds.contains($0.deltaIdentifier) }
        handle(removalCandidates: removalCandidates, additionCandidates: additionCanditates)
        
        for matched in matchedIds {
            if let lhs = lhsCases.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhsCases.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
    }
    
    private func compare(lhs: EnumCase, rhs: EnumCase) {
        if lhs.rawValue != rhs.rawValue {
            changes.add(
                UpdateChange(
                    element: element(.caseRawValue),
                    from: .element(lhs),
                    to: .element(rhs),
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
    
    private func element(_ target: EnumTarget) -> ChangeElement {
        .for(enum: lhs, target: target)
    }
    
    
    private func handle(removalCandidates: [EnumCase], additionCandidates: [EnumCase]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    UpdateChange(
                        element: element(.case),
                        from: candidate.name,
                        to: relaxedMatching.name,
                        breaking: false,
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
                    element: element(.case),
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: true,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(
                AddChange(
                    element: element(.case),
                    added: .element(addition),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
    }
}
