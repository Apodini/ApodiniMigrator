//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

struct EndpointsComparator: Comparator {
    let lhs: [Endpoint]
    let rhs: [Endpoint]
    var changes: ChangeContainer
    
    init(lhs: [Endpoint], rhs: [Endpoint], changes: inout ChangeContainer) {
        self.lhs = lhs
        self.rhs = rhs
        self.changes = changes
    }
    
    mutating func compare() {
        let matchedIds = lhs.matchedIds(with: rhs)
        
        let removalCanditates = lhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        let additionCanditates = rhs.filter { !matchedIds.contains($0.deltaIdentifier) }
        
        for matched in matchedIds {
            if let lhs = lhs.first(where: { $0.deltaIdentifier == matched }), let rhs = rhs.first(where: { $0.deltaIdentifier == matched }) {
                var endpointComparator = EndpointComparator(lhs: lhs, rhs: rhs, changes: &changes)
                endpointComparator.compare()
            }
        }
        
        handle(removalCandidates: removalCanditates, additionCanditates: additionCanditates)
    }
    
    mutating func handle(removalCandidates: [Endpoint], additionCanditates: [Endpoint]) {
        var relaxedMatchings: [DeltaIdentifier] = []
        
        let all = removalCandidates.identifiers() + additionCanditates.identifiers()
        assert(all.count == removalCandidates.count + additionCanditates.count, "Encoutered removal and addition candidates with same id")
        
        for candidate in removalCandidates {
            if let relaxedMatching = additionCanditates.first(where: { $0 ?= candidate }) {
                relaxedMatchings.append(relaxedMatching.deltaIdentifier)
                var endpointComparator = EndpointComparator(lhs: candidate, rhs: relaxedMatching, changes: &changes)
                endpointComparator.compare()
            }
        }
        
        for removal in removalCandidates where !relaxedMatchings.contains(removal.deltaIdentifier) {
            changes.add(DeleteChange(element: .endpoint(removal.deltaIdentifier), target: .`self`, deleted: .none, fallbackValue: .none))
        }
        
        for addition in additionCanditates where !relaxedMatchings.contains(addition.deltaIdentifier) {
            changes.add(AddChange(element: .endpoint(addition.deltaIdentifier), target: .`self`, added: .json(addition.json), defaultValue: .none))
        }
    }
}

extension Array where Element == Endpoint {
    func identifiers() -> [DeltaIdentifier] {
        map { $0.deltaIdentifier }
    }
}
