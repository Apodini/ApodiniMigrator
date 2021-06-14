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
    
    var element: ChangeElement {
        .for(model: lhs)
    }
    
    func compare() {
        guard let lhsRawValue = lhs.rawValueType, let rhsRawValue = rhs.rawValueType else {
            return
        }
        
        if lhsRawValue != rhsRawValue {
            changes.add(
                ValueChange(
                    element: element,
                    target: .rawValueType,
                    from: .string(lhsRawValue.rawValue),
                    to: .string(rhsRawValue.rawValue),
                    breaking: true,
                    solvable: false
                )
            )
        }
        
        let enumCasesComparator = EnumCasesComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
        enumCasesComparator.compare()
    }
}


fileprivate struct EnumCasesComparator: Comparator {
    let lhs: TypeInformation
    let rhs: TypeInformation
    let changes: ChangeContainer
    let configuration: EncoderConfiguration
    let lhsCases: [EnumCase]
    let rhsCases: [EnumCase]
    
    var element: ChangeElement {
        .for(model: lhs)
    }
    
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
        
        for matched in matchedIds {
            if let lhs = lhsCases.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhsCases.firstMatch(on: \.deltaIdentifier, with: matched) {
                compare(lhs: lhs, rhs: rhs)
            }
        }
        
        handle(removalCandidates: removalCandidates, additionCandidates: additionCanditates)
    }
    
    private func compare(lhs: EnumCase, rhs: EnumCase) {
        if lhs.rawValue != rhs.rawValue {
            changes.add(
                ValueChange(
                    element: element,
                    target: .caseRawValue,
                    from: .json(lhs.rawValue),
                    to: .json(rhs.rawValue),
                    breaking: true,
                    solvable: true
                )
            )
        }
    }
    
    
    func handle(removalCandidates: [EnumCase], additionCandidates: [EnumCase]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    RenameChange(
                        element: element,
                        target: .`case`,
                        from: candidate.deltaIdentifier.rawValue,
                        to: relaxedMatching.deltaIdentifier.rawValue,
                        breaking: false,
                        solvable: true
                    )
                )
                
                compare(lhs: candidate, rhs: relaxedMatching)
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(
                DeleteChange(
                    element: element,
                    target: .`case`,
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: true,
                    solvable: true
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(
                AddChange(
                    element: element,
                    target: .`case`,
                    added: .json(of: addition),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true
                )
            )
        }
    }
}
