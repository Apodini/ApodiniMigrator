//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

extension Array: Value where Element: Value {}

struct EndpointsComparator: Comparator {
    let lhs: [Endpoint]
    let rhs: [Endpoint]
    let changes: ChangeContainer
    var configuration: EncoderConfiguration
    
    func compare() {
        let matchedIds = lhs.matchedIds(with: rhs)
        let removalCandidates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCandidates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        handle(removalCandidates: removalCandidates, additionCandidates: additionCandidates)
        
        for matched in matchedIds {
            if let lhs = lhs.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhs.firstMatch(on: \.deltaIdentifier, with: matched) {
                let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
                endpointComparator.compare()
            }
        }
    }
    
    private func handle(removalCandidates: [Endpoint], additionCandidates: [Endpoint]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates, useRawValueDistance: false) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    UpdateChange(
                        element: .for(endpoint: candidate, target: .`self`),
                        from: candidate.deltaIdentifier.rawValue,
                        to: relaxedMatching.deltaIdentifier.rawValue,
                        breaking: false,
                        solvable: true
                    )
                )
                
                let endpointComparator = EndpointComparator(lhs: candidate, rhs: relaxedMatching, changes: changes, configuration: configuration)
                endpointComparator.compare()
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(
                DeleteChange(
                    element: .for(endpoint: removal, target: .`self`),
                    deleted: .none,
                    fallbackValue: .none,
                    breaking: true,
                    solvable: false
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(
                AddChange(
                    element: .for(endpoint: addition, target: .`self`),
                    added: .element(addition),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true
                )
            )
        }
    }
}
