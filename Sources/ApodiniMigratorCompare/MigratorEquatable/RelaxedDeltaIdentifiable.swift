//
//  File.swift
//  
//
//  Created by Eldi Cano on 23.05.21.
//

import Foundation

extension Array where Element: DeltaIdentifiable {
    func identifiers() -> [DeltaIdentifier] {
        map { $0.deltaIdentifier }
    }
}

extension Array where Element: DeltaIdentifiable & Hashable {
    func matchedIds(with other: Self) -> [DeltaIdentifier] {
        let ownIds = Set(identifiers())
        let otherIds = Set(other.identifiers())
        return ownIds.intersection(otherIds).asArray
    }
}

infix operator ?=
/// RelaxedDeltaIdentifiable protocol is an additional attempt to catch renamings of certain elements,
/// where the renameable element is used as `identifier` throughout the logic of the comparison. `RelaxedDeltaIdentifiable`
/// serves the purpose to not classify a rename as one addition and one removal.
/// Operation is always applied on compared elements that do not posses a matching `identifier` on different versions.
protocol RelaxedDeltaIdentifiable: DeltaIdentifiable {
    static func ?= (lhs: Self, rhs: Self) -> Bool
}

private struct DeltaSimilarity: Comparable {
    let similarity: Double
    let identifier: DeltaIdentifier
    
    static func < (lhs: DeltaSimilarity, rhs: DeltaSimilarity) -> Bool {
        lhs.similarity < rhs.similarity
    }
}

extension DeltaIdentifier {
    func distance(between other: DeltaIdentifier) -> Double {
        rawValue.distance(between: other.rawValue)
    }
}

extension RelaxedDeltaIdentifiable {
    func mostSimilarWithSelf(in array: [Self], useRawValueDistance: Bool = true) -> Self? {
        let mostSimilarId = array.map { deltaIdentifiable -> DeltaSimilarity in
            let currentId = deltaIdentifiable.deltaIdentifier
            let similarity = deltaIdentifier.distance(between: currentId)
            return DeltaSimilarity(similarity: similarity, identifier: currentId)
        }
        .max()?.identifier
        
        return array.first(where: { (self ?= $0) && $0.deltaIdentifier == (useRawValueDistance ? mostSimilarId : $0.deltaIdentifier) })
    }
}

/// Endpoint extension to `RelaxedDeltaIdentifiable`
extension Endpoint: RelaxedDeltaIdentifiable {
    static func ?= (lhs: Endpoint, rhs: Endpoint) -> Bool {
        lhs.operation == rhs.operation && lhs.path == rhs.path
    }
}

/// Parameter extension to `RelaxedDeltaIdentifiable`
extension Parameter: RelaxedDeltaIdentifiable {
    static func ?= (lhs: Parameter, rhs: Parameter) -> Bool {
        true
    }
}
