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
    var changes: ChangeContainer
    var configuration: EncoderConfiguration
    
    init(lhs: [Endpoint], rhs: [Endpoint], changes: ChangeContainer, configuration: EncoderConfiguration) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
        self.configuration = configuration
    }
    
    func compare() {
        let matchedIds = lhs.matchedIds(with: rhs)
        
        let removalCanditates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCanditates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        
        for matched in matchedIds {
            if let lhs = lhs.firstMatch(on: \.deltaIdentifier, with: matched),
               let rhs = rhs.firstMatch(on: \.deltaIdentifier, with: matched) {
                let endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
                endpointComparator.compare()
            }
        }
        
        handle(removalCandidates: removalCanditates, additionCandidates: additionCanditates)
    }
    
    func handle(removalCandidates: [Endpoint], additionCandidates: [Endpoint]) {
        var relaxedMatchings: Set<DeltaIdentifier> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates, useRawValueDistance: false) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    RenameChange(
                        element: .for(endpoint: candidate),
                        target: .`self`,
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
                    element: .for(endpoint: removal),
                    target: .`self`,
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
                    element: .for(endpoint: addition),
                    target: .`self`,
                    added: .json(of: addition),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true
                )
            )
        }
    }
}
