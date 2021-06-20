//
//  File.swift
//  
//
//  Created by Eldi Cano on 13.06.21.
//

import Foundation

struct ModelsComparator: Comparator {
    let lhs: [TypeInformation]
    let rhs: [TypeInformation]
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
                let modelComparator = ModelComparator(lhs: lhs, rhs: rhs, changes: changes, configuration: configuration)
                modelComparator.compare()
            }
        }
    }
    
    private func handle(removalCandidates: [TypeInformation], additionCandidates: [TypeInformation]) {
        struct MatchedPairs: Hashable {
            let candidate: TypeInformation
            let relaxedMatching: TypeInformation
        }
        
        var relaxedMatchings: Set<DeltaIdentifier> = []
        var pairs: Set<MatchedPairs> = []
        
        assert(Set(removalCandidates.identifiers()).isDisjoint(with: additionCandidates.identifiers()), "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = candidate.mostSimilarWithSelf(in: additionCandidates) {
                relaxedMatchings += relaxedMatching.deltaIdentifier
                relaxedMatchings += candidate.deltaIdentifier
                
                changes.add(
                    UpdateChange(
                        element: .for(object: candidate, target: .typeName),
                        from: candidate.deltaIdentifier.rawValue,
                        to: relaxedMatching.deltaIdentifier.rawValue,
                        breaking: false,
                        solvable: true
                    )
                )
                pairs.insert(.init(candidate: candidate, relaxedMatching: relaxedMatching))
            }
        }
        
        // ensuring to have registered potential type renamings before comparing
        defer {
            pairs.forEach {
                let modelComparator = ModelComparator(lhs: $0.candidate, rhs: $0.relaxedMatching, changes: changes, configuration: configuration)
                modelComparator.compare()
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(
                DeleteChange(
                    element: .for(object: removal, target: .`self`),
                    deleted: .none,
                    fallbackValue: .none,
                    breaking: false,
                    solvable: false
                )
            )
        }
        
        for addition in additionCandidates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(
                AddChange(
                    element: .for(object: addition, target: .`self`),
                    added: .element(addition),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true
                )
            )
        }
    }
}
