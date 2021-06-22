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
        struct MatchedPairs: Hashable {
            let candidate: Endpoint
            let relaxedMatching: Endpoint
            
            func contains(_ id: DeltaIdentifier) -> Bool {
                candidate.deltaIdentifier == id || relaxedMatching.deltaIdentifier == id
            }
        }
        
        var pairs: Set<MatchedPairs> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        if allowEndpointIdentifierUpdate {
            for candidate in removalCandidates {
                if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates, useRawValueDistance: false) {
                    changes.add(
                        UpdateChange(
                            element: .for(endpoint: candidate, target: .deltaIdentifier),
                            from: candidate.deltaIdentifier.rawValue,
                            to: relaxedMatching.deltaIdentifier.rawValue,
                            breaking: false,
                            solvable: true,
                            includeProviderSupport: includeProviderSupport
                        )
                    )
                    
                    pairs.insert(.init(candidate: candidate, relaxedMatching: relaxedMatching))
                }
            }
            
            pairs.forEach {
                let endpointComparator = EndpointComparator(lhs: $0.candidate, rhs: $0.relaxedMatching, changes: changes, configuration: configuration)
                endpointComparator.compare()
            }
        }
        
        let includeProviderSupport = allowEndpointIdentifierUpdate && self.includeProviderSupport
        for removal in removalCandidates where !pairs.contains(where: { $0.contains(removal.deltaIdentifier) }) {
            changes.add(
                DeleteChange(
                    element: .for(endpoint: removal, target: .`self`),
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: true,
                    solvable: false,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !pairs.contains(where: { $0.contains(addition.deltaIdentifier) }) {
            changes.add(
                AddChange(
                    element: .for(endpoint: addition, target: .`self`),
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