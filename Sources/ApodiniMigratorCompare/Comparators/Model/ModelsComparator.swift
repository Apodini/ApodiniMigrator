//
//  ModelsComparator.swift
//  ApodiniMigratorCompare
//
//  Created by Eldi Cano on 07.08.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

struct ModelsComparator: Comparator {
    let lhs: [TypeInformation]
    let rhs: [TypeInformation]
    let changes: ChangeContextNode
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
            
            func contains(_ id: DeltaIdentifier) -> Bool {
                [candidate, relaxedMatching].identifiers().contains(id)
            }
        }
        
        var pairs: Set<MatchedPairs> = []
        
        if allowTypeRename {
            for candidate in removalCandidates {
                let unmatched = additionCandidates.filter { addition in pairs.allSatisfy({ !$0.contains(addition.deltaIdentifier) }) }
                if let relaxedMatching = candidate.mostSimilarWithSelf(in: unmatched) {
                    changes.add(
                        UpdateChange(
                            element: candidate.isObject ? .for(object: candidate, target: .typeName) : .for(enum: candidate, target: .typeName),
                            from: candidate.deltaIdentifier.rawValue,
                            to: relaxedMatching.element.deltaIdentifier.rawValue,
                            similarity: relaxedMatching.similarity,
                            breaking: false,
                            solvable: true,
                            includeProviderSupport: includeProviderSupport
                        )
                    )
                    pairs.insert(.init(candidate: candidate, relaxedMatching: relaxedMatching.element))
                }
            }
            
            // ensuring to have registered potential type renamings before comparing
            pairs.forEach {
                let modelComparator = ModelComparator(lhs: $0.candidate, rhs: $0.relaxedMatching, changes: changes, configuration: configuration)
                modelComparator.compare()
            }
        }
        
        let includeProviderSupport = allowTypeRename && self.includeProviderSupport
        for removal in removalCandidates where !pairs.contains(where: { $0.contains(removal.deltaIdentifier) }) {
            changes.add(
                DeleteChange(
                    element: removal.isObject ? .for(object: removal, target: .`self`) : .for(enum: removal, target: .`self`),
                    deleted: .id(from: removal),
                    fallbackValue: .none,
                    breaking: false,
                    solvable: false,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
        
        for addition in additionCandidates where !pairs.contains(where: { $0.contains(addition.deltaIdentifier) }) {
            changes.add(
                AddChange(
                    element: addition.isObject ? .for(object: addition, target: .`self`) : .for(enum: addition, target: .`self`),
                    added: .element(addition.referencedProperties()),
                    defaultValue: .none,
                    breaking: false,
                    solvable: true,
                    includeProviderSupport: includeProviderSupport
                )
            )
        }
    }
}
